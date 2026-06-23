import '../database/db_helper.dart';
import '../model/produto_model.dart';

class ProdutoDAO {
  static const String _tableName = 'produto';

  static Future<int> inserir(ProdutoModel produto) async {
    final db = await DBHelper.getInstance();
    return await db.insert(_tableName, produto.toMap());
  }

  static Future<void> atualizar(ProdutoModel produto) async {
    final db = await DBHelper.getInstance();
    await db.update(
      _tableName,
      produto.toMap(),
      where: 'codigo = ?',
      whereArgs: [produto.codigo],
    );
  }

  static Future<void> deletar(String codigo) async {
    final db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'codigo = ?', whereArgs: [codigo]);
  }

  static Future<List<ProdutoModel>> carregarTodos() async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result.map((e) => ProdutoModel.fromMap(e)).toList();
  }

  static Future<ProdutoModel?> buscarPorCodigo(String codigo) async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
    if (result.isEmpty) return null;
    return ProdutoModel.fromMap(result.first);
  }
}
