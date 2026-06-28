import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdmde/recebimento/views/af_cadastro_view.dart';

void main() {
  testWidgets(
    'renderiza a tela de cadastro de AF e permite adicionar um item',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AfCadastroView()));

      expect(find.text('Cadastro de AF'), findsOneWidget);
      expect(find.text('Dados gerais da AF'), findsOneWidget);

      await tester.tap(find.text('Adicionar item'));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Código MP'), findsOneWidget);
    },
  );
}
