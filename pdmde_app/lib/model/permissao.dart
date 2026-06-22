class Permissao {
  final int? id;
  final String nomePermissao;
  final String descricao;

  Permissao({this.id, required this.nomePermissao, required this.descricao});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomePermissao': nomePermissao,
      'descricao': descricao,
    };
  }

  factory Permissao.fromMap(Map<String, dynamic> map) {
    return Permissao(
      id: map['id'] as int?,
      nomePermissao: map['nomePermissao'] as String,
      descricao: map['descricao'] as String,
    );
  }
}
