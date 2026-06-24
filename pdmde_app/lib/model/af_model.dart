import 'af_item_model.dart';

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
  };

  factory AfModel.fromMap(Map<String, dynamic> map) => AfModel(
    id: map['id'] as int?,
    numAF: map['numAF'] as String,
    descricao: map['descricao'] as String,
    fornecedor: map['fornecedor'] as String,
    pesoTotal: (map['pesoTotal'] as num).toDouble(),
    // itens nao ficam no SQLite, vem da API
  );

  factory AfModel.fromApiMap(Map<String, dynamic> map) => AfModel(
    numAF: map['NumAF'] as String,
    descricao: map['Descricao'] as String,
    fornecedor: map['Fornecedor'] as String,
    pesoTotal: (map['PesoTotal'] as num).toDouble(),
    itens: (map['Itens'] as List<dynamic>? ?? [])
        .map((i) => AfItemModel.fromApiMap(i as Map<String, dynamic>))
        .toList(),
  );
}
