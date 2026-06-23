import '../database/db_helper.dart';
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

  static Future<void> seedInicial() async {
    final List<AfModel> existentes = await carregarTodos();
    if (existentes.isEmpty) {
      await inserir(
        const AfModel(
          numAF: '261544',
          descricao: 'Aço SAE 1045 — Barra Redonda',
          fornecedor: 'Aços Villares',
          pesoTotal: 1850.5,
        ),
      );
      await inserir(
        const AfModel(
          numAF: '261545',
          descricao: 'Aço SAE 4140 — Barra Sextavada',
          fornecedor: 'Gerdau Açominas',
          pesoTotal: 3240.0,
        ),
      );
    }
  }
}
