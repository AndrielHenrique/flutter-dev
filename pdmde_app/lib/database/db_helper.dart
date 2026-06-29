import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _instance;
  static const String dbName = 'aula14.db';

  static Future<Database> getInstance() async {
    if (_instance != null) return _instance!;

    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, dbName);

    _instance = await openDatabase(path, version: 1, onCreate: _onCreate);
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
      'CREATE TABLE produto(codigo TEXT PRIMARY KEY, descricao TEXT, fornecedor TEXT, preco REAL, quantidade INTEGER)',
    );
    
    await db.execute(
      'CREATE TABLE permissao(id INTEGER PRIMARY KEY, nomePermissao TEXT, descricao TEXT)',
    );

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
      'nome': 'Administrador',
      'email': 'admin@example.com',
      'senha': '1234',
    });
  }
}
