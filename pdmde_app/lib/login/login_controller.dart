  import '../dao/usuario_dao.dart';
  import '../model/usuario.dart';


class LoginController {
  bool isAdmin({required String username, required String password}) {
    return username == "admin@example.com" && password == "admin123";
  }

   Future<bool> validateLogin({required String username, required String password}) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }
    
    // Busca o usuário direto no banco de dados local
    Usuario? usuario = await UsuarioDAO.buscarPorEmailESenha(username, password);
    
    // Retorna verdadeiro se encontrou o usuário, falso se não encontrou
    return usuario != null;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 4;
  }
}
