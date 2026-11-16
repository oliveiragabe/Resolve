import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/validators.dart';

void main() {
  group('Validators.requiredField', () {
    test('deve retornar erro quando o valor for nulo', () {
      expect(Validators.requiredField(null), 'Este campo é obrigatório.');
    });

    test('deve retornar erro quando o campo estiver vazio', () {
      expect(Validators.requiredField(''), 'Este campo é obrigatório.');
    });

    test('deve retornar erro quando houver apenas espaços', () {
      expect(Validators.requiredField('   '), 'Este campo é obrigatório.');
    });

    test('deve retornar null quando o campo estiver preenchido', () {
      expect(Validators.requiredField('Resolve'), isNull);
    });
  });

  group('Validators.title', () {
    test('deve retornar erro quando o título estiver vazio', () {
      expect(Validators.title(''), 'Este campo é obrigatório.');
    });

    test('deve retornar erro quando o título tiver menos de 3 caracteres', () {
      expect(
        Validators.title('AB'),
        'O título deve ter pelo menos 3 caracteres.',
      );
    });

    test('deve considerar espaços antes e depois do título', () {
      expect(
        Validators.title('  AB  '),
        'O título deve ter pelo menos 3 caracteres.',
      );
    });

    test('deve aceitar títulos com pelo menos 3 caracteres', () {
      expect(Validators.title('Erro no login'), isNull);
    });
  });
}
