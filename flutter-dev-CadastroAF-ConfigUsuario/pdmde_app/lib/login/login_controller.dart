import '../dao/usuario_dao.dart';
import '../model/usuario.dart';

class LoginController {
  static const String adminLogin = 'admin';
  static const String adminPassword = 'admin';

  bool validateLogin({required String username, required String password}) {
    return username.trim().isNotEmpty && password.isNotEmpty;
  }

  bool isValidUsername(String username) {
    final value = username.trim();
    if (value.toLowerCase() == adminLogin) {
      return true;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value);
  }

  bool isValidPassword(String password) {
    return password.length >= 4;
  }

  bool isAdmin({required String username, required String password}) {
    return username.trim().toLowerCase() == adminLogin &&
        password == adminPassword;
  }

  Future<Usuario?> autenticar({
    required String username,
    required String password,
  }) async {
    final usuario = await UsuarioDAO.autenticar(
      login: username.trim(),
      senha: password,
    );
    if (usuario != null) {
      return usuario;
    }

    if (isAdmin(username: username, password: password)) {
      return Usuario(
        nome: adminLogin,
        email: adminLogin,
        senha: adminPassword,
      );
    }

    return null;
  }
}
