import 'af_item_model.dart';

import 'dart:convert';

class AfModel {
  final int? id;
  final String numAF;
  final String descricao;
  final String fornecedor;
  final double pesoTotal;
  final List<AfItemModel> itens;

  const AfModel({
    this.id,
    required this.numAF,
    required this.descricao,
    required this.fornecedor,
    required this.pesoTotal,
    this.itens = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'numAF': numAF,
    'descricao': descricao,
    'fornecedor': fornecedor,
    'pesoTotal': pesoTotal,
    // Itens são salvos como JSON dentro da própria linha mesmo padrão
    // já usado em RecebimentoModel.barrasJson.
    'itensJson': jsonEncode(itens.map((i) => i.toMap()).toList()),
  };

  Map<String, dynamic> toApiMap() => {
    'NumAF': numAF,
    'Descricao': descricao,
    'Fornecedor': fornecedor,
    'PesoTotal': pesoTotal,
    'Itens': itens.map((i) => i.toMap()).toList(),
  };

  factory AfModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic> itensRaw =
        jsonDecode(map['itensJson'] as String? ?? '[]') as List<dynamic>;
    return AfModel(
      id: map['id'] as int?,
      numAF: map['numAF'] as String,
      descricao: map['descricao'] as String,
      fornecedor: map['fornecedor'] as String,
      pesoTotal: (map['pesoTotal'] as num).toDouble(),
      itens: itensRaw
          .map((i) => AfItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList(),
    );
  }

  factory AfModel.fromApiMap(Map<String, dynamic> map) => AfModel(
    numAF: map['NumAF'] as String,
    descricao: map['Descricao'] as String,
    fornecedor: map['Fornecedor'] as String,
    pesoTotal: (map['PesoTotal'] as num).toDouble(),
    itens: (map['Itens'] as List<dynamic>? ?? [])
        .map((i) => AfItemModel.fromApiMap(i as Map<String, dynamic>))
        .toList(),
  );

  AfModel copyWith({
    int? id,
    String? numAF,
    String? descricao,
    String? fornecedor,
    double? pesoTotal,
    List<AfItemModel>? itens,
  }) => AfModel(
    id: id ?? this.id,
    numAF: numAF ?? this.numAF,
    descricao: descricao ?? this.descricao,
    fornecedor: fornecedor ?? this.fornecedor,
    pesoTotal: pesoTotal ?? this.pesoTotal,
    itens: itens ?? this.itens,
  );
}
