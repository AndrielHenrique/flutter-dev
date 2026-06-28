import 'package:dio/dio.dart';

import '../database/db_helper.dart';
import '../http/dio_client.dart';
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

  static Future<void> salvarViaApi(
    ProdutoModel produto, {
    required bool editar,
  }) async {
    final dio = DioClient.getInstance();
    try {
      if (editar) {
        await dio.put('/produtos/${produto.codigo}', data: produto.toApiMap());
        return;
      }
      await dio.post('/produtos', data: produto.toApiMap());
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return;
      }
      rethrow;
    }
  }
}
