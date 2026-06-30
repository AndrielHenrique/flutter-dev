  import '../dao/usuario_dao.dart';
  import '../model/usuario.dart';


class LoginController {
  bool isAdmin({required String username, required String password}) {
    return username == "admin@example.com" && password == "admin123";
  }

    Future<String?> validateLogin({required String username, required String password}) async {
    if (username.isEmpty || password.isEmpty) {
      return null;
    }
    
    Usuario? usuario = await UsuarioDAO.buscarPorEmailESenha(username, password);
    return usuario?.nome;
  }


  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 4;
  }
}
