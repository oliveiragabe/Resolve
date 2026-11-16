import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/issue.dart';
import 'package:mobile/services/issue_service.dart';

void main() {
  final issueJson = <String, dynamic>{
    'id': 1,
    'title': 'Erro no login',
    'description': 'Falha ao autenticar usuário',
    'project': 'Resolve',
    'severity': 'critica',
    'status': 'aberto',
    'created_at': '2026-11-15T10:00:00.000000Z',
    'updated_at': '2026-11-15T11:00:00.000000Z',
  };

  group('IssueService', () {
    test('deve listar ocorrências', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');

        return http.Response(jsonEncode([issueJson]), 200);
      });

      final service = IssueService(client: client);

      final issues = await service.getAll();

      expect(issues, isA<List<Issue>>());
      expect(issues.length, 1);
      expect(issues.first.title, 'Erro no login');

      service.dispose();
    });

    test('deve buscar ocorrência pelo ID', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path.endsWith('/1'), isTrue);

        return http.Response(jsonEncode(issueJson), 200);
      });

      final service = IssueService(client: client);

      final issue = await service.getById(1);

      expect(issue.id, 1);
      expect(issue.title, 'Erro no login');

      service.dispose();
    });

    test('deve criar uma ocorrência', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');

        final body = jsonDecode(request.body);

        expect(body['title'], 'Erro no login');

        return http.Response(jsonEncode(issueJson), 201);
      });

      final service = IssueService(client: client);

      const issue = Issue(
        title: 'Erro no login',
        description: 'Falha ao autenticar usuário',
        project: 'Resolve',
        severity: 'critica',
        status: 'aberto',
      );

      final createdIssue = await service.create(issue);

      expect(createdIssue.id, 1);
      expect(createdIssue.title, 'Erro no login');

      service.dispose();
    });

    test('deve atualizar uma ocorrência', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path.endsWith('/1'), isTrue);

        return http.Response(jsonEncode(issueJson), 200);
      });

      final service = IssueService(client: client);

      const issue = Issue(
        title: 'Erro no login',
        description: 'Falha ao autenticar usuário',
        project: 'Resolve',
        severity: 'critica',
        status: 'aberto',
      );

      final updatedIssue = await service.update(1, issue);

      expect(updatedIssue.id, 1);
      expect(updatedIssue.title, 'Erro no login');

      service.dispose();
    });

    test('deve excluir uma ocorrência', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path.endsWith('/1'), isTrue);

        return http.Response(
          jsonEncode({'message': 'Ocorrência excluída.'}),
          200,
        );
      });

      final service = IssueService(client: client);

      expect(() => service.delete(1), returnsNormally);

      await service.delete(1);

      service.dispose();
    });
  });
}
