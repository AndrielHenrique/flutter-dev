import 'package:flutter/material.dart';

import 'login/login_page.dart';
import 'home/home_page.dart';
import 'recebimento/views/recebimento_view.dart';
import 'recebimento/views/historico_view.dart';
import 'recebimento/views/af_cadastro_view.dart';
import 'recebimento/views/af_lista_view.dart';
import 'perfil/perfil_view.dart';
import 'Usuarios/view/userCadastro_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryColor = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recebimento Genérico',

      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/recebimento': (_) => const RecebimentoView(),
        '/historico': (_) => const HistoricoView(),
        '/af-cadastro': (_) => const AfCadastroView(),
        '/af-lista': (_) => const AfListaView(),
        '/perfil': (_) => const PerfilView(),
        '/usuarios': (_) => const UserCadastroView(),
      },
    );
  }
}
