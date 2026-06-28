import '../database/db_helper.dart';
import '../model/barra_model.dart';

class BarraDAO {
  static const String _tableName = 'barra';

  static Future<int> inserir(BarraModel barra) async {
    final db = await DBHelper.getInstance();
    return await db.insert(_tableName, barra.toMap());
  }

  static Future<void> atualizar(BarraModel barra) async {
    final db = await DBHelper.getInstance();
    await db.update(
      _tableName,
      barra.toMap(),
      where: 'id = ?',
      whereArgs: [barra.id],
    );
  }

  static Future<void> deletar(int id) async {
    final db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deletarPorAF(String numAF) async {
    final db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'numAF = ?', whereArgs: [numAF]);
  }

  static Future<List<BarraModel>> carregarPorAF(String numAF) async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'numAF = ?',
      whereArgs: [numAF],
      orderBy: 'linha ASC',
    );
    return result.map((e) => BarraModel.fromMap(e)).toList();
  }
}
