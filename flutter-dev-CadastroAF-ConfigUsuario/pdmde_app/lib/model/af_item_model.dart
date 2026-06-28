class AfItemModel {
  final String codigoMP;
  final String descricao;
  final int quantidadePedida;
  final double pesoUnitario;

  const AfItemModel({
    required this.codigoMP,
    required this.descricao,
    required this.quantidadePedida,
    required this.pesoUnitario,
  });

  factory AfItemModel.fromApiMap(Map<String, dynamic> map) => AfItemModel(
    codigoMP: map['CodigoMP'] as String,
    descricao: map['Descricao'] as String,
    quantidadePedida: map['QuantidadePedida'] as int,
    pesoUnitario: (map['PesoUnitario'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'codigoMP': codigoMP,
    'descricao': descricao,
    'quantidadePedida': quantidadePedida,
    'pesoUnitario': pesoUnitario,
  };

  // Reconstrói a partir do JSON salvo dentro da coluna itensJson do SQLite
  factory AfItemModel.fromMap(Map<String, dynamic> map) => AfItemModel(
    codigoMP: map['codigoMP'] as String,
    descricao: map['descricao'] as String,
    quantidadePedida: map['quantidadePedida'] as int,
    pesoUnitario: (map['pesoUnitario'] as num).toDouble(),
  );
}