import '../database/db_helper.dart';
import '../model/usuario.dart';

class UsuarioDAO {
  static const String _tableName = 'usuario';

  static Future<int> inserir(Usuario usuario) async {
    final db = await DBHelper.getInstance();
    return await db.insert(_tableName, usuario.toMap());
  }

  static Future<void> atualizar(Usuario usuario) async {
    final db = await DBHelper.getInstance();
    await db.update(
      _tableName,
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  static Future<void> deletar(Usuario usuario) async {
    final db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [usuario.id]);
  }

  static Future<List<Usuario>> carregarUsuarios() async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      orderBy: 'CASE WHEN LOWER(nome) = \'admin\' OR LOWER(email) = \'admin\' THEN 0 ELSE 1 END, nome COLLATE NOCASE ASC',
    );
    return result.map((e) => Usuario.fromMap(e)).toList();
  }

  static Future<Usuario?> buscarPorLogin(String login) async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'LOWER(nome) = ? OR LOWER(email) = ?',
      whereArgs: [login.toLowerCase(), login.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Usuario.fromMap(result.first);
  }

  static Future<Usuario?> autenticar({
    required String login,
    required String senha,
  }) async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: '(LOWER(nome) = ? OR LOWER(email) = ?) AND senha = ?',
      whereArgs: [login.toLowerCase(), login.toLowerCase(), senha],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Usuario.fromMap(result.first);
  }
}
