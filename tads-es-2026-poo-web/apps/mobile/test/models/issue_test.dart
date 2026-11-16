import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/issue.dart';

void main() {
  group('Issue.fromJson', () {
    test('deve converter JSON em objeto Issue', () {
      final json = {
        'id': 1,
        'title': 'Erro no login',
        'description': 'Falha ao autenticar usuário',
        'project': 'Resolve',
        'severity': 'critica',
        'status': 'aberto',
        'created_at': '2026-11-15T10:00:00.000000Z',
        'updated_at': '2026-11-15T11:00:00.000000Z',
      };

      final issue = Issue.fromJson(json);

      expect(issue.id, 1);
      expect(issue.title, 'Erro no login');
      expect(issue.description, 'Falha ao autenticar usuário');
      expect(issue.project, 'Resolve');
      expect(issue.severity, 'critica');
      expect(issue.status, 'aberto');
      expect(issue.createdAt, DateTime.parse(json['created_at'] as String));
      expect(issue.updatedAt, DateTime.parse(json['updated_at'] as String));
    });

    test('deve aceitar descrição e datas nulas', () {
      final json = {
        'id': 2,
        'title': 'Erro na interface',
        'description': null,
        'project': 'Resolve',
        'severity': 'baixa',
        'status': 'fechado',
        'created_at': null,
        'updated_at': null,
      };

      final issue = Issue.fromJson(json);

      expect(issue.description, isNull);
      expect(issue.createdAt, isNull);
      expect(issue.updatedAt, isNull);
    });
  });

  group('Issue.toJson', () {
    test('deve converter Issue em JSON', () {
      const issue = Issue(
        id: 1,
        title: 'Erro no login',
        description: 'Falha ao autenticar usuário',
        project: 'Resolve',
        severity: 'critica',
        status: 'aberto',
      );

      final json = issue.toJson();

      expect(json['title'], 'Erro no login');
      expect(json['description'], 'Falha ao autenticar usuário');
      expect(json['project'], 'Resolve');
      expect(json['severity'], 'critica');
      expect(json['status'], 'aberto');

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });
  });
}
