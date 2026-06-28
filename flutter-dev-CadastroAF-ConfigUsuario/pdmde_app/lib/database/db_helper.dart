import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _instance;
  static const String dbName = 'aula14.db';

  static Future<Database> getInstance() async {
    if (_instance != null) return _instance!;

    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, dbName);

    _instance = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _instance!;
  }

  static Future<void> _onCreate(Database db, int ver) async {
    await db.execute(
      'CREATE TABLE usuario(id INTEGER PRIMARY KEY, nome TEXT, email TEXT, senha TEXT)',
    );
    await db.execute(
      'CREATE TABLE fornecedor(id INTEGER PRIMARY KEY, nome TEXT, cnpj TEXT)',
    );
    await db.execute(
      'CREATE TABLE produto(codigo TEXT PRIMARY KEY, descricao TEXT, fornecedor TEXT, saldoDisponivel REAL)',
    );
    await db.execute(
      'CREATE TABLE permissao(id INTEGER PRIMARY KEY, nomePermissao TEXT, descricao TEXT)',
    );

    // Itens do pedido são persistidos junto com a AF,
    // serializados como JSON na coluna itensJson.
    await db.execute('''
      CREATE TABLE af(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numAF TEXT,
        descricao TEXT,
        fornecedor TEXT,
        pesoTotal REAL,
        itensJson TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE barra(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numAF TEXT,
        linha INTEGER,
        codigoMP TEXT,
        descricao TEXT,
        fornecedor TEXT,
        corrida INTEGER,
        pesoBarra REAL,
        numeroBarra TEXT,
        isRasurada INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE recebimento(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numAF TEXT,
        descricao TEXT,
        fornecedor TEXT,
        totalBarras INTEGER,
        pesoTotal REAL,
        obs TEXT,
        dataHora TEXT,
        barrasJson TEXT
      )
    ''');

    await db.insert('usuario', {
      'nome': 'admin',
      'email': 'admin',
      'senha': 'admin',
    });
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(usuario)');
      final hasSenha = columns.any((column) => column['name'] == 'senha');
      if (!hasSenha) {
        await db.execute('ALTER TABLE usuario ADD COLUMN senha TEXT');
      }
    }

    if (oldVersion < 3) {
      final existing = await db.query(
        'usuario',
        where: 'LOWER(nome) = ? OR LOWER(email) = ?',
        whereArgs: const ['admin', 'admin'],
      );
      if (existing.isEmpty) {
        await db.insert('usuario', {
          'nome': 'admin',
          'email': 'admin',
          'senha': 'admin',
        });
      } else {
        final admin = existing.first;
        final id = admin['id'] as int?;
        if (id != null &&
            (admin['nome'] != 'admin' ||
                admin['email'] != 'admin' ||
                admin['senha'] != 'admin')) {
          await db.update(
            'usuario',
            {'nome': 'admin', 'email': 'admin', 'senha': 'admin'},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    }
  }
}
