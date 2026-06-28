import 'package:flutter/material.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isAdmin;
  late HomeController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isAdmin = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
    controller = HomeController();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair"),
        content: const Text("Deseja realmente sair do sistema?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text("Sair"),
          ),
        ],
      ),
    );
  }

  void _handleActionTap(String actionTitle) {
    switch (actionTitle) {
      case 'Registrar Recebimento':
        Navigator.pushNamed(context, '/recebimento');
        break;
      case 'Revisar Recebimento':
        Navigator.pushNamed(context, '/historico');
        break;
      case 'Cadastrar AF':
        Navigator.pushNamed(context, '/af-lista');
        break;
      case 'Cadastrar Usuários':
        Navigator.pushNamed(context, '/usuarios', arguments: isAdmin);
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Você tocou em: $actionTitle')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = controller.getActions(isAdmin);
    const primary = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Recebimento Genérico"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/perfil'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Editar perfil',
          ),
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2771C2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bem-vindo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Acesse rapidamente as funcionalidades do sistema.",
                  style: TextStyle(color: Color(0xFFBFD4FF), fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E5FA8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "Sistema operacional",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ações rápidas",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final item = actions[index];
                return GestureDetector(
                  onTap: () => _handleActionTap(item["title"]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: item["color"],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(item["icon"], color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(item["subtitle"]),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
