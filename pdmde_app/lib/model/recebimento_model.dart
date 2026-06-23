import 'dart:convert';
import 'barra_model.dart';

class RecebimentoModel {
  final int? id;
  final String numAF;
  final String descricao;
  final String fornecedor;
  final int totalBarras;
  final double pesoTotal;
  final String? obs;
  final String dataHora;
  final List<BarraModel> barras;

  const RecebimentoModel({
    this.id,
    required this.numAF,
    required this.descricao,
    required this.fornecedor,
    required this.totalBarras,
    required this.pesoTotal,
    this.obs,
    required this.dataHora,
    required this.barras,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'numAF': numAF,
    'descricao': descricao,
    'fornecedor': fornecedor,
    'totalBarras': totalBarras,
    'pesoTotal': pesoTotal,
    'obs': obs,
    'dataHora': dataHora,
    'barrasJson': jsonEncode(barras.map((b) => b.toMap()).toList()),
  };

  factory RecebimentoModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic> barrasRaw =
        jsonDecode(map['barrasJson'] as String? ?? '[]') as List<dynamic>;
    return RecebimentoModel(
      id: map['id'] as int?,
      numAF: map['numAF'] as String,
      descricao: map['descricao'] as String,
      fornecedor: map['fornecedor'] as String,
      totalBarras: map['totalBarras'] as int,
      pesoTotal: (map['pesoTotal'] as num).toDouble(),
      obs: map['obs'] as String?,
      dataHora: map['dataHora'] as String,
      barras: barrasRaw
          .map((b) => BarraModel.fromMap(Map<String, dynamic>.from(b as Map)))
          .toList(),
    );
  }
}
