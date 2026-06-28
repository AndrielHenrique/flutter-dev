class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha;

  Usuario({this.id, required this.nome, required this.email, this.senha = ''});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'email': email, 'senha': senha};
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String? ?? '',
    );
  }

  Usuario copyWith({int? id, String? nome, String? email, String? senha}) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
    );
  }
}
