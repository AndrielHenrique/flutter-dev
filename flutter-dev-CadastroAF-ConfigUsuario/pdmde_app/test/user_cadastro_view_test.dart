import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdmde/Usuarios/view/userCadastro_view.dart';

void main() {
  testWidgets('bloqueia o acesso para usuário não-admin', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserCadastroView()));

    expect(find.text('Cadastro de usuários'), findsOneWidget);
    expect(find.text('Acesso restrito ao administrador.'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);
  });
}
