import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdmde/perfil/perfil_view.dart';

void main() {
  testWidgets('renderiza a tela de perfil e os campos de edição', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilView()));

    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Nome de usuário'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Nova senha'), findsOneWidget);
    expect(find.text('Confirmar nova senha'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });
}
