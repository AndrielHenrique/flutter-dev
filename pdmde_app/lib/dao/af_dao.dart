import 'package:dio/dio.dart';

import '../database/db_helper.dart';
import '../http/dio_client.dart';
import '../model/af_item_model.dart';
import '../model/af_model.dart';

class AfDAO {
  static const String _tableName = 'af';

  static Future<int> inserir(AfModel af) async {
    final db = await DBHelper.getInstance();
    return await db.insert(_tableName, af.toMap());
  }

  static Future<void> atualizar(AfModel af) async {
    final db = await DBHelper.getInstance();
    await db.update(
      _tableName,
      af.toMap(),
      where: 'id = ?',
      whereArgs: [af.id],
    );
  }

  static Future<void> deletar(AfModel af) async {
    final db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [af.id]);
  }

  static Future<List<AfModel>> carregarTodos() async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result.map((e) => AfModel.fromMap(e)).toList();
  }

  static Future<AfModel?> buscarPorNumero(String numAF) async {
    final db = await DBHelper.getInstance();
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'numAF = ?',
      whereArgs: [numAF],
    );
    if (result.isEmpty) return null;
    return AfModel.fromMap(result.first);
  }

  static Future<void> salvarViaApi(AfModel af, {required bool editar}) async {
    final dio = DioClient.getInstance();
    try {
      final payload = af.toApiMap();
      if (editar) {
        await dio.put('/af/${af.numAF}', data: payload);
        return;
      }
      await dio.post('/af', data: payload);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return;
      }
      if (e.response?.statusCode == 409) {
        return;
      }
      rethrow;
    }
  }

  static Future<void> seedInicial() async {
    final List<AfModel> existentes = await carregarTodos();
    if (existentes.isEmpty) {
      await inserir(
        const AfModel(
          numAF: '261544',
          descricao: 'Aço SAE 1045 — Barra Redonda',
          fornecedor: 'Aços Villares',
          pesoTotal: 1850.5,
          itens: [
            AfItemModel(
              codigoMP: 'MP-1045-RD50',
              descricao: 'SAE 1045 — Ø50mm',
              quantidadePedida: 2,
              pesoUnitario: 520.0,
            ),
            AfItemModel(
              codigoMP: 'MP-1045-RD75',
              descricao: 'SAE 1045 — Ø75mm',
              quantidadePedida: 2,
              pesoUnitario: 498.5,
            ),
          ],
        ),
      );
      await inserir(
        const AfModel(
          numAF: '261545',
          descricao: 'Aço SAE 4140 — Barra Sextavada',
          fornecedor: 'Gerdau Açominas',
          pesoTotal: 3240.0,
          itens: [
            AfItemModel(
              codigoMP: 'MP-4140-SX36',
              descricao: 'SAE 4140 — SW36mm',
              quantidadePedida: 3,
              pesoUnitario: 600.0,
            ),
          ],
        ),
      );
    }
  }
}
