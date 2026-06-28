import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdmde/login/login_page.dart';

void main() {
  testWidgets('renderiza a tela de login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Recebimento Genérico'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
