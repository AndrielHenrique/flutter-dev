class ProdutoModel {
  final String codigo;
  final String descricao;
  final String fornecedor;

  const ProdutoModel({
    required this.codigo,
    required this.descricao,
    required this.fornecedor,
  });

  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'descricao': descricao,
    'fornecedor': fornecedor,
  };

  factory ProdutoModel.fromMap(Map<String, dynamic> map) => ProdutoModel(
    codigo: map['codigo'] as String,
    descricao: map['descricao'] as String,
    fornecedor: map['fornecedor'] as String,
  );

  // JSON da API (chaves com inicial maiúscula)
  factory ProdutoModel.fromApiMap(Map<String, dynamic> map) => ProdutoModel(
    codigo: map['CODIGO'] as String,
    descricao: map['DESCRICAO'] as String,
    fornecedor: map['FORNECEDOR'] as String,
  );
}
