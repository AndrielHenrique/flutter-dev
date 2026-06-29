class ProdutoModel {
  final String codigo;
  final String descricao;
  final String fornecedor;
  final double preco;
  final int quantidade;

  const ProdutoModel({
    required this.codigo,
    required this.descricao,
    required this.fornecedor,
    required this.preco,
    required this.quantidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'fornecedor': fornecedor,
      'preco': preco,
      'quantidade': quantidade,
    };
  }

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      codigo: map['codigo'] as String,
      descricao: map['descricao'] as String,
      fornecedor: map['fornecedor'] as String,
      preco: (map['preco'] as num).toDouble(),
      quantidade: map['quantidade'] as int,
    );
  }

  factory ProdutoModel.fromApiMap(Map<String, dynamic> map) {
    return ProdutoModel(
      codigo: map['CODIGO'] as String,
      descricao: map['DESCRICAO'] as String,
      fornecedor: map['FORNECEDOR'] as String,
      preco: 0.0,
      quantidade: 0,
    );
  }
}
