class ProdutoModel {
  final String codigo;
  final String descricao;
  final String fornecedor;
  final double saldoDisponivel;

  const ProdutoModel({
    required this.codigo,
    required this.descricao,
    required this.fornecedor,
    required this.saldoDisponivel,
  });

  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'descricao': descricao,
    'fornecedor': fornecedor,
    'saldoDisponivel': saldoDisponivel,
  };

  Map<String, dynamic> toApiMap() => {
    'CODIGO': codigo,
    'DESCRICAO': descricao,
    'FORNECEDOR': fornecedor,
    'SaldoDisponivel': saldoDisponivel,
  };

  factory ProdutoModel.fromMap(Map<String, dynamic> map) => ProdutoModel(
    codigo: map['codigo'] as String,
    descricao: map['descricao'] as String,
    fornecedor: map['fornecedor'] as String,
    saldoDisponivel: (map['saldoDisponivel'] as num?)?.toDouble() ?? 0.0,
  );

  // JSON da API (chaves com inicial maiúscula)
  factory ProdutoModel.fromApiMap(Map<String, dynamic> map) => ProdutoModel(
    codigo: map['CODIGO'] as String,
    descricao: map['DESCRICAO'] as String,
    fornecedor: map['FORNECEDOR'] as String,
    saldoDisponivel: (map['SaldoDisponivel'] as num?)?.toDouble() ?? 0.0,
  );
}
