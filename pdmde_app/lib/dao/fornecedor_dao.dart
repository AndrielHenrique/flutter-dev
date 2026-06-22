import '../database/db_helper.dart';
import '../model/fornecedor.dart';

class FornecedorDAO {
  static const String _tableName = 'fornecedor';

  static Future<int> inserir(Fornecedor fornecedor) async {
    var db = await DBHelper.getInstance();
    return await db.insert(_tableName, fornecedor.toMap());
  }

  static Future<void> atualizar(Fornecedor fornecedor) async {
    var db = await DBHelper.getInstance();
    await db.update(_tableName, fornecedor.toMap(), where: 'id = ?', whereArgs: [fornecedor.id]);
  }

  static Future<void> deletar(Fornecedor fornecedor) async {
    var db = await DBHelper.getInstance();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [fornecedor.id]);
  }

  static Future<List<Fornecedor>> carregarFornecedores() async {
    var db = await DBHelper.getInstance();
    List<Map<String, dynamic>> result = await db.query(_tableName);
    return result.map((e) => Fornecedor.fromMap(e)).toList();
  }
}
