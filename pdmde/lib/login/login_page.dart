import 'package:flutter/material.dart';

import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = LoginController();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  bool showPassword = false;

  void handleLogin() {
    final username = usernameController.text;

    final password = passwordController.text;

    final valid = controller.validateLogin(
      username: username,
      password: password,
    );

    if (!valid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha usuário e senha")));

      return;
    }

    final isAdmin = controller.isAdmin(username: username, password: password);

    Navigator.pushReplacementNamed(context, '/home', arguments: isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: primary,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),

            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),

              borderRadius: BorderRadius.circular(36),
            ),

            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Recebimento Genérico",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Faça login para acessar o sistema",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: usernameController,

                  decoration: InputDecoration(
                    hintText: "Login",

                    filled: true,

                    fillColor: Colors.white,

                    prefixIcon: const Icon(Icons.person),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,

                  obscureText: !showPassword,

                  decoration: InputDecoration(
                    hintText: "Senha",

                    filled: true,

                    fillColor: Colors.white,

                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },

                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    onPressed: handleLogin,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: primary,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    child: const Text(
                      "Entrar",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
