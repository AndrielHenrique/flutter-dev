import 'package:flutter/material.dart';

import '../controller/userController.dart';
import '../../model/usuario.dart';

class UserCadastroView extends StatefulWidget {
  const UserCadastroView({super.key});

  @override
  State<UserCadastroView> createState() => _UserCadastroViewState();
}

class _UserCadastroViewState extends State<UserCadastroView> {
  final UserController _controller = UserController();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isAdmin = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;
    _isAdmin = ModalRoute.of(context)?.settings.arguments as bool? ?? false;

    if (_isAdmin) {
      _controller.carregarUsuarios();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nomeController.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _preencherFormulario(Usuario usuario) {
    _nomeController.text = usuario.nome;
    _loginController.text = usuario.email;
    _senhaController.text = usuario.senha;
    _confirmarSenhaController.text = usuario.senha;
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _loginController.clear();
    _senhaController.clear();
    _confirmarSenhaController.clear();
    _controller.cancelarEdicao();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final emEdicao = _controller.emEdicao;

    final salvo = await _controller.salvarUsuario(
      id: _controller.usuarioEmEdicao?.id,
      nome: _nomeController.text,
      login: _loginController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;
    if (!salvo) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          emEdicao
              ? 'Usuário atualizado com sucesso.'
              : 'Usuário cadastrado com sucesso.',
        ),
      ),
    );
    _limparFormulario();
  }

  Future<void> _confirmarExclusao(Usuario usuario) async {
    final excluir = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir usuário'),
          content: Text('Deseja realmente excluir ${usuario.nome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (excluir != true) return;

    final ok = await _controller.excluirUsuario(usuario);
    if (!mounted || !ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário excluído com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de usuários'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 56,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Acesso restrito ao administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de usuários'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.emEdicao
                              ? 'Editar usuário'
                              : 'Novo usuário',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: _controller.validarNome,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _loginController,
                          decoration: const InputDecoration(
                            labelText: 'Login (admin ou e-mail)',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: _controller.validarLogin,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _senhaController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: _controller.validarSenha,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _confirmarSenhaController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme a senha.';
                            }
                            if (value != _senhaController.text) {
                              return 'As senhas não coincidem.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _controller.carregando
                                    ? null
                                    : _salvar,
                                icon: _controller.carregando
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        _controller.emEdicao
                                            ? Icons.save_outlined
                                            : Icons.person_add_alt_1,
                                      ),
                                label: Text(
                                  _controller.emEdicao ? 'Salvar' : 'Cadastrar',
                                ),
                              ),
                            ),
                            if (_controller.emEdicao) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _controller.carregando
                                      ? null
                                      : _limparFormulario,
                                  child: const Text('Cancelar edição'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_controller.erro != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    _controller.erro!,
                    style: const TextStyle(color: Color(0xFFB91C1C)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Usuários cadastrados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (_controller.carregando && _controller.usuarios.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_controller.usuarios.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Nenhum usuário cadastrado.')),
                )
              else
                ..._controller.usuarios.map((usuario) {
                  final isAdminUsuario = _controller.isAdminUsuario(usuario);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAdminUsuario
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF2771C2),
                        child: Icon(
                          isAdminUsuario ? Icons.shield : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(usuario.nome),
                      subtitle: Text(usuario.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: isAdminUsuario
                                ? 'Admin não pode ser editado'
                                : 'Editar',
                            onPressed: isAdminUsuario
                                ? null
                                : () {
                                    _controller.iniciarEdicao(usuario);
                                    _preencherFormulario(usuario);
                                  },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: isAdminUsuario
                                ? 'Admin não pode ser excluído'
                                : 'Excluir',
                            onPressed: isAdminUsuario
                                ? null
                                : () => _confirmarExclusao(usuario),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
