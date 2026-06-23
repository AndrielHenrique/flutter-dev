class BarraModel {
  final int? id;
  final String numAF;
  final int linha;
  final String codigoMP;
  final String descricao;
  final String fornecedor;
  final int? corrida;
  final double pesoBarra;
  final String numeroBarra;
  final bool isRasurada;

  const BarraModel({
    this.id,
    required this.numAF,
    required this.linha,
    required this.codigoMP,
    required this.descricao,
    required this.fornecedor,
    this.corrida,
    required this.pesoBarra,
    required this.numeroBarra,
    required this.isRasurada,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'numAF': numAF,
    'linha': linha,
    'codigoMP': codigoMP,
    'descricao': descricao,
    'fornecedor': fornecedor,
    'corrida': corrida,
    'pesoBarra': pesoBarra,
    'numeroBarra': numeroBarra,
    'isRasurada': isRasurada ? 1 : 0,
  };

  factory BarraModel.fromMap(Map<String, dynamic> map) => BarraModel(
    id: map['id'] as int?,
    numAF: map['numAF'] as String,
    linha: map['linha'] as int,
    codigoMP: map['codigoMP'] as String? ?? '',
    descricao: map['descricao'] as String? ?? '',
    fornecedor: map['fornecedor'] as String? ?? '',
    corrida: map['corrida'] as int?,
    pesoBarra: (map['pesoBarra'] as num?)?.toDouble() ?? 0,
    numeroBarra: map['numeroBarra'] as String? ?? '',
    isRasurada: (map['isRasurada'] as int? ?? 0) == 1,
  );

  factory BarraModel.fromApiMap(Map<String, dynamic> map) => BarraModel(
    numAF: map['NumAF'] as String,
    linha: map['Linha'] as int,
    codigoMP: map['CodigoMP'] as String? ?? '',
    descricao: map['Descricao'] as String? ?? '',
    fornecedor: map['Fornecedor'] as String? ?? '',
    corrida: map['Corrida'] as int?,
    pesoBarra: (map['PesoBarra'] as num?)?.toDouble() ?? 0,
    numeroBarra: map['NumeroBarra'] as String? ?? '',
    isRasurada: map['IsRasurada'] as bool? ?? false,
  );

  BarraModel copyWith({
    int? id,
    String? codigoMP,
    String? descricao,
    String? fornecedor,
    int? corrida,
    double? pesoBarra,
    String? numeroBarra,
    bool? isRasurada,
  }) => BarraModel(
    id: id ?? this.id,
    numAF: numAF,
    linha: linha,
    codigoMP: codigoMP ?? this.codigoMP,
    descricao: descricao ?? this.descricao,
    fornecedor: fornecedor ?? this.fornecedor,
    corrida: corrida ?? this.corrida,
    pesoBarra: pesoBarra ?? this.pesoBarra,
    numeroBarra: numeroBarra ?? this.numeroBarra,
    isRasurada: isRasurada ?? this.isRasurada,
  );
}
