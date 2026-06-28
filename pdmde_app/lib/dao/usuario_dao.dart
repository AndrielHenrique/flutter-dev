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
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result.map((e) => Usuario.fromMap(e)).toList();
  }
}
