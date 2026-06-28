class LoginController {
  bool isAdmin({required String username, required String password}) {
    return username == "admin" && password == "admin";
  }

  bool validateLogin({required String username, required String password}) {
    return username.isNotEmpty && password.isNotEmpty;
  }
}
