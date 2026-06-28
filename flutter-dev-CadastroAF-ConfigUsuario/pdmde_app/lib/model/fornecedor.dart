class Fornecedor {
  final int? id;
  final String nome;
  final String cnpj;

  Fornecedor({this.id, required this.nome, required this.cnpj});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
    };
  }

  factory Fornecedor.fromMap(Map<String, dynamic> map) {
    return Fornecedor(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      cnpj: map['cnpj'] as String,
    );
  }
}
