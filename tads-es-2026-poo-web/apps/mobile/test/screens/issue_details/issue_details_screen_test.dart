import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/models/issue.dart';
import 'package:mobile/screens/issue_details/issue_details_screen.dart';
import 'package:mobile/screens/issues/issues_screen.dart';
import 'package:mobile/services/issue_service.dart';

class FakeIssueService extends IssueService {
  Issue issue;
  bool shouldFail;
  bool shouldFailUpdate;
  bool shouldFailDelete;

  int updateCalls = 0;
  int deleteCalls = 0;
  String? updatedStatus;

  FakeIssueService({
    required this.issue,
    this.shouldFail = false,
    this.shouldFailUpdate = false,
    this.shouldFailDelete = false,
  }) : super(client: MockClient((_) async => http.Response('{}', 200)));

  @override
  Future<Issue> getById(int id) async {
    if (shouldFail) {
      throw Exception('Erro simulado');
    }

    return issue;
  }

  @override
  Future<Issue> update(int id, Issue updatedIssue) async {
    updateCalls++;

    if (shouldFailUpdate) {
      throw Exception('Erro ao atualizar');
    }

    issue = updatedIssue;
    updatedStatus = updatedIssue.status;

    return issue;
  }

  @override
  Future<void> delete(int id) async {
    deleteCalls++;

    if (shouldFailDelete) {
      throw Exception('Erro ao excluir');
    }
  }

  @override
  void dispose() {}
}

void main() {
  final initialIssue = const Issue(
    id: 1,
    title: 'Erro no login',
    description: 'Falha ao autenticar usuário',
    project: 'Resolve',
    severity: 'critica',
    status: 'aberto',
  );

  late FakeIssueService service;
  late GoRouter router;

  Future<void> openScreen(
    WidgetTester tester, {
    bool shouldFail = false,
    bool shouldFailUpdate = false,
    bool shouldFailDelete = false,
  }) async {
    service = FakeIssueService(
      issue: initialIssue,
      shouldFail: shouldFail,
      shouldFailUpdate: shouldFailUpdate,
      shouldFailDelete: shouldFailDelete,
    );

    router = GoRouter(
      initialLocation: '/issues/1',
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.dashboard,
          builder: (context, state) => const Scaffold(body: Text('Dashboard')),
        ),
        GoRoute(
          path: '/issues',
          name: AppRoutes.issues,
          builder: (context, state) => IssuesScreen(service: service),
        ),
        GoRoute(
          path: '/issues/:id',
          name: AppRoutes.issueDetails,
          builder: (context, state) =>
              IssueDetailsScreen(issueId: 1, service: service),
        ),
        GoRoute(
          path: '/issues/:id/edit',
          name: AppRoutes.issueEdit,
          builder: (context, state) =>
              const Scaffold(body: Text('Tela de edição')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.pumpAndSettle();

    addTearDown(router.dispose);
  }

  group('IssueDetailsScreen', () {
    testWidgets('deve exibir os dados da ocorrência', (tester) async {
      await openScreen(tester);

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Resolve'), findsOneWidget);
      expect(find.text('Falha ao autenticar usuário'), findsOneWidget);
      expect(find.text('Crítica'), findsOneWidget);
      expect(find.text('Status da ocorrência'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando ocorrer erro ao carregar', (
      tester,
    ) async {
      await openScreen(tester, shouldFail: true);

      expect(
        find.text('Não foi possível carregar a ocorrência.'),
        findsOneWidget,
      );

      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('deve atualizar o status da ocorrência', (tester) async {
      await openScreen(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Em resolução').last);
      await tester.pumpAndSettle();

      expect(service.updateCalls, 1);
      expect(service.updatedStatus, 'em_resolucao');
      expect(find.text('Status atualizado com sucesso!'), findsOneWidget);
    });

    testWidgets('deve exibir erro ao atualizar status', (tester) async {
      await openScreen(tester, shouldFailUpdate: true);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Em resolução').last);
      await tester.pumpAndSettle();

      expect(service.updateCalls, 1);
      expect(find.textContaining('Erro ao atualizar status:'), findsOneWidget);
    });

    testWidgets('deve navegar para a tela de edição', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('Editar ocorrência'));
      await tester.pumpAndSettle();

      expect(find.text('Tela de edição'), findsOneWidget);
    });

    testWidgets('deve cancelar a exclusão', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('Excluir ocorrência'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(service.deleteCalls, 0);
      expect(find.text('Erro no login'), findsOneWidget);
    });

    testWidgets('deve confirmar a exclusão', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('Excluir ocorrência'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(service.deleteCalls, 1);
      expect(find.text('Ocorrências'), findsOneWidget);
    });

    testWidgets('deve exibir erro ao excluir', (tester) async {
      await openScreen(tester, shouldFailDelete: true);

      await tester.tap(find.text('Excluir ocorrência'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(service.deleteCalls, 1);
      expect(
        find.textContaining('Erro ao excluir ocorrência:'),
        findsOneWidget,
      );
    });
  });
}
