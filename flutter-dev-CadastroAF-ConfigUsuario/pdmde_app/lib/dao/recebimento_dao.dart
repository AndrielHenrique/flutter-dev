import '../database/db_helper.dart';
import '../model/recebimento_model.dart';

class RecebimentoDAO {
  static const String _tableName = 'recebimento';

  static Future<int> inserir(RecebimentoModel rec) async {
    final db = await DBHelper.getInstance();
    return await db.insert(_tableName, rec.toMap());
  }

  static Future<void> atualizar(RecebimentoModel rec) async {
    final db = await DBHelper.getInstance();
    await db.update(
      _tableName,
      rec.toMap(),
      where: 'id = ?',
      whereArgs: [rec.id],
    );
  }

  static Future<void> deletar(int id) async {
    final db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<RecebimentoModel>> carregarTodos() async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      orderBy: 'dataHora DESC',
    );
    return result.map((e) => RecebimentoModel.fromMap(e)).toList();
  }

  static Future<RecebimentoModel?> buscarPorId(int id) async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return RecebimentoModel.fromMap(result.first);
  }
}
