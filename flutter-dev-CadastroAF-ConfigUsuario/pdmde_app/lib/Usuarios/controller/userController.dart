import 'package:flutter/material.dart';

import '../../dao/usuario_dao.dart';
import '../../model/usuario.dart';

class UserController extends ChangeNotifier {
  static const String adminLogin = 'admin';
  static const String adminSenha = 'admin';

  final List<Usuario> usuarios = [];
  Usuario? usuarioEmEdicao;
  bool carregando = false;
  String? erro;

  bool get emEdicao => usuarioEmEdicao != null;

  bool isAdminUsuario(Usuario usuario) {
    return usuario.nome.toLowerCase() == adminLogin ||
        usuario.email.toLowerCase() == adminLogin;
  }

  Future<void> carregarUsuarios() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      usuarios
        ..clear()
        ..addAll(await UsuarioDAO.carregarUsuarios());
    } catch (_) {
      erro = 'Erro ao carregar usuários.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void iniciarEdicao(Usuario usuario) {
    if (isAdminUsuario(usuario)) {
      erro = 'O usuário admin não pode ser editado por esta tela.';
      notifyListeners();
      return;
    }

    usuarioEmEdicao = usuario;
    erro = null;
    notifyListeners();
  }

  void cancelarEdicao() {
    usuarioEmEdicao = null;
    erro = null;
    notifyListeners();
  }

  String? validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome.';
    }
    return null;
  }

  String? validarLogin(String? value) {
    final login = value?.trim() ?? '';
    if (login.isEmpty) {
      return 'Informe o login.';
    }
    if (login.toLowerCase() == adminLogin) {
      return null;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(login)) {
      return 'Informe um login/e-mail válido.';
    }
    return null;
  }

  String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha.';
    }
    if (value.length < 4) {
      return 'A senha deve ter pelo menos 4 caracteres.';
    }
    return null;
  }

  Future<bool> salvarUsuario({
    int? id,
    required String nome,
    required String login,
    required String senha,
  }) async {
    final normalizedLogin = login.trim().toLowerCase();
    final existing = await UsuarioDAO.buscarPorLogin(login.trim());

    if (normalizedLogin == adminLogin &&
        (id == null || existing == null || existing.id != id)) {
      erro = 'O login admin é reservado.';
      notifyListeners();
      return false;
    }

    if (existing != null && existing.id != id) {
      erro = 'Já existe um usuário com esse login.';
      notifyListeners();
      return false;
    }

    final usuario = Usuario(
      id: id,
      nome: nome.trim(),
      email: login.trim(),
      senha: senha,
    );

    carregando = true;
    erro = null;
    notifyListeners();

    try {
      if (id == null) {
        await UsuarioDAO.inserir(usuario);
      } else {
        await UsuarioDAO.atualizar(usuario);
      }
      await carregarUsuarios();
      usuarioEmEdicao = null;
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao salvar usuário: $e';
      carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirUsuario(Usuario usuario) async {
    if (isAdminUsuario(usuario)) {
      erro = 'O usuário admin não pode ser excluído.';
      notifyListeners();
      return false;
    }

    carregando = true;
    erro = null;
    notifyListeners();

    try {
      await UsuarioDAO.deletar(usuario);
      await carregarUsuarios();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir usuário: $e';
      carregando = false;
      notifyListeners();
      return false;
    }
  }
}
