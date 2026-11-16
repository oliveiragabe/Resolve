import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/issue.dart';
import 'package:mobile/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/services/issue_service.dart';

class FakeIssueService extends IssueService {
  final List<Issue> issues;
  final bool shouldFail;

  FakeIssueService({this.issues = const [], this.shouldFail = false});

  @override
  Future<List<Issue>> getAll() async {
    if (shouldFail) {
      throw Exception('Erro simulado');
    }

    return issues;
  }
}

void main() {
  group('DashboardScreen', () {
    testWidgets('deve exibir indicadores e ocorrências', (tester) async {
      final service = FakeIssueService(
        issues: [
          const Issue(
            id: 1,
            title: 'Erro no login',
            project: 'Resolve',
            severity: 'critica',
            status: 'aberto',
          ),
          const Issue(
            id: 2,
            title: 'Erro na interface',
            project: 'Resolve',
            severity: 'baixa',
            status: 'em_resolucao',
          ),
          const Issue(
            id: 3,
            title: 'Erro no cadastro',
            project: 'Resolve',
            severity: 'media',
            status: 'fechado',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(service: service)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Painel geral'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Abertas'), findsOneWidget);
      expect(find.text('Em resolução'), findsOneWidget);
      expect(find.text('Fechadas'), findsOneWidget);
      expect(find.text('Ocorrências críticas'), findsOneWidget);

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Erro na interface'), findsOneWidget);
      expect(find.text('Erro no cadastro'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando não houver ocorrências', (
      tester,
    ) async {
      final service = FakeIssueService();

      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(service: service)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nenhuma ocorrência cadastrada.'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando ocorrer erro na API', (
      tester,
    ) async {
      final service = FakeIssueService(shouldFail: true);

      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(service: service)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar as ocorrências.'), findsOneWidget);

      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
}
