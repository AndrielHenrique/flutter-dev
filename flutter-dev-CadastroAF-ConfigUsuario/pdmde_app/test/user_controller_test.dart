import 'package:flutter_test/flutter_test.dart';
import 'package:pdmde/Usuarios/controller/userController.dart';

void main() {
  group('UserController validações', () {
    final controller = UserController();

    test('valida login admin', () {
      expect(controller.validarLogin('admin'), isNull);
    });

    test('rejeita login inválido', () {
      expect(controller.validarLogin('usuario_sem_email'), isNotNull);
    });

    test('exige senha com ao menos 4 caracteres', () {
      expect(controller.validarSenha('123'), isNotNull);
      expect(controller.validarSenha('1234'), isNull);
    });
  });
}
