import 'package:flutter/material.dart';

import '../../../dao/recebimento_dao.dart';
import '../../../model/recebimento_model.dart';

/// Controller MVC para [HistoricoView].
///
/// Responsabilidades:
///  - Carregar, deletar e atualizar recebimentos via [RecebimentoDAO].
///  - Expor estado (lista, carregando, erro) para a View consumir.
///  - Nunca importar widgets.. toda interação com UI ocorre via callbacks.
class HistoricoController extends ChangeNotifier {
  List<RecebimentoModel> recebimentos = [];
  bool carregando = false;
  String? erro;
  // Carregar
  Future<void> carregar() async {
    _setCarregando(true);
    erro = null;
    try {
      recebimentos = await RecebimentoDAO.carregarTodos();
    } catch (_) {
      erro = 'Erro ao carregar recebimentos.';
    } finally {
      _setCarregando(false);
    }
  }

  // Deletar
  /// Retorna `true` se deletado com sucesso, `false` caso contrário.
  Future<bool> deletar(RecebimentoModel rec) async {
    if (rec.id == null) return false;
    try {
      await RecebimentoDAO.deletar(rec.id!);
      recebimentos.removeWhere((r) => r.id == rec.id);
      notifyListeners();
      return true;
    } catch (_) {
      erro = 'Erro ao remover recebimento.';
      notifyListeners();
      return false;
    }
  }

  // Editar observação
  /// Retorna `true` se atualizado com sucesso.
  Future<bool> atualizarObs(RecebimentoModel rec, String novaObs) async {
    if (rec.id == null) return false;
    try {
      final RecebimentoModel atualizado = RecebimentoModel(
        id: rec.id,
        numAF: rec.numAF,
        descricao: rec.descricao,
        fornecedor: rec.fornecedor,
        totalBarras: rec.totalBarras,
        pesoTotal: rec.pesoTotal,
        obs: novaObs.trim(),
        dataHora: rec.dataHora,
        barras: rec.barras,
      );
      await RecebimentoDAO.atualizar(atualizado);
      await carregar();
      return true;
    } catch (_) {
      erro = 'Erro ao atualizar recebimento.';
      notifyListeners();
      return false;
    }
  }

  // Internos
  void _setCarregando(bool valor) {
    carregando = valor;
    notifyListeners();
  }
}
