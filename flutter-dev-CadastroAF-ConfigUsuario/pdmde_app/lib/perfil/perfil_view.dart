import 'package:flutter/material.dart';

import '../dao/usuario_dao.dart';
import '../model/usuario.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _accentColor = Color(0xFF2771C2);

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _carregando = false;
  Usuario? _usuarioAtual;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuario() async {
    final usuarios = await UsuarioDAO.carregarUsuarios();
    if (!mounted) return;
    if (usuarios.isNotEmpty) {
      final usuario = usuarios.first;
      _usuarioAtual = usuario;
      _nomeController.text = usuario.nome;
      _emailController.text = usuario.email;
    }
    setState(() {});
  }

  String? _validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome de usuário.';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail.';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha.';
    }
    if (value.length < 4) {
      return 'A senha deve ter pelo menos 4 caracteres.';
    }
    return null;
  }

  String? _validarConfirmacaoSenha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirme a nova senha.';
    }
    if (value != _senhaController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final usuario = Usuario(
        id: _usuarioAtual?.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (_usuarioAtual == null) {
        await UsuarioDAO.inserir(usuario);
      } else {
        await UsuarioDAO.atualizar(usuario);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar perfil: $e')));
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dados do usuário',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome de usuário',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validarNome,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: _validarSenha,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: _validarConfirmacaoSenha,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _carregando ? null : _salvar,
                icon: _carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Salvar alterações'),
                style: FilledButton.styleFrom(
                  backgroundColor: _accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
