import 'package:flutter/material.dart';

class HomeController {
  List<Map<String, dynamic>> getActions(bool isAdmin) {
    final actions = [
      {
        "title": "Registrar Recebimento",

        "subtitle": "Criar novo recebimento",

        "icon": Icons.add,

        "color": const Color(0xFF22C55E),

        "admin": false,
      },
      {
        "title": "Revisar Recebimento",

        "subtitle": "Consultar registros",

        "icon": Icons.description,

        "color": const Color(0xFF1E3A8A),

        "admin": false,
      },
      {
        "title": "Cadastrar AF",

        "subtitle": "Criar ou editar uma AF",

        "icon": Icons.assignment_add,

        "color": const Color(0xFF8B5CF6),

        "admin": false,
      },
      {
        "title": "Cadastrar Usuários",

        "subtitle": "Gerenciar acessos",

        "icon": Icons.people,

        "color": const Color(0xFFEF4444),

        "admin": true,
      },
    ];

    return actions.where((item) {
      return !(item["admin"] as bool) || isAdmin;
    }).toList();
  }
}
