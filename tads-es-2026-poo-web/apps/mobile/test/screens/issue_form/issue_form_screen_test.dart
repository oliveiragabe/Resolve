import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/models/issue.dart';
import 'package:mobile/screens/issue_form/issue_form_screen.dart';
import 'package:mobile/services/issue_service.dart';

class FakeIssueService extends IssueService {
  FakeIssueService()
    : super(client: MockClient((_) async => http.Response('{}', 200)));

  Issue issue = const Issue(
    id: 1,
    title: 'Erro no login',
    description: 'Erro ao autenticar usuário.',
    project: 'Resolve',
    severity: 'critica',
    status: 'aberto',
  );

  Issue? createdIssue;
  Issue? updatedIssue;

  bool failLoad = false;
  bool failCreate = false;
  bool failUpdate = false;

  @override
  Future<Issue> getById(int id) async {
    if (failLoad) {
      throw Exception('Erro ao carregar ocorrência.');
    }

    return issue;
  }

  @override
  Future<Issue> create(Issue newIssue) async {
    if (failCreate) {
      throw Exception('Erro ao criar ocorrência.');
    }

    createdIssue = Issue(
      id: 2,
      title: newIssue.title,
      description: newIssue.description,
      project: newIssue.project,
      severity: newIssue.severity,
      status: newIssue.status,
    );

    return createdIssue!;
  }

  @override
  Future<Issue> update(int id, Issue newIssue) async {
    if (failUpdate) {
      throw Exception('Erro ao atualizar ocorrência.');
    }

    updatedIssue = Issue(
      id: id,
      title: newIssue.title,
      description: newIssue.description,
      project: newIssue.project,
      severity: newIssue.severity,
      status: newIssue.status,
    );

    return updatedIssue!;
  }
}

GoRouter createRouter({
  required FakeIssueService service,
  String initialLocation = '/issues/new',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/issues/new',
        name: AppRoutes.issueForm,
        builder: (context, state) {
          return IssueFormScreen(service: service);
        },
      ),
      GoRoute(
        path: '/issues/:id/edit',
        name: AppRoutes.issueEdit,
        builder: (context, state) {
          return IssueFormScreen(
            issueId: int.parse(state.pathParameters['id']!),
            service: service,
          );
        },
      ),
      GoRoute(
        path: '/issues/:id',
        name: AppRoutes.issueDetails,
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: Text(
                'Detalhes da ocorrência ${state.pathParameters['id']}',
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/',
        name: AppRoutes.dashboard,
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Dashboard')));
        },
      ),
    ],
  );
}

Future<void> pumpForm(
  WidgetTester tester, {
  required FakeIssueService service,
  String initialLocation = '/issues/new',
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final router = createRouter(
    service: service,
    initialLocation: initialLocation,
  );

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));

  await tester.pumpAndSettle();

  addTearDown(router.dispose);
}

void main() {
  group('IssueFormScreen', () {
    testWidgets('deve exibir os campos do formulário', (tester) async {
      final service = FakeIssueService();

      await pumpForm(tester, service: service);

      expect(find.text('Nova ocorrência'), findsNWidgets(2));
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Descrição'), findsOneWidget);
      expect(find.text('Projeto'), findsOneWidget);
      expect(find.text('Severidade'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Cadastrar ocorrência'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('deve validar os campos obrigatórios', (tester) async {
      final service = FakeIssueService();

      await pumpForm(tester, service: service);

      await tester.tap(find.text('Cadastrar ocorrência'));
      await tester.pumpAndSettle();

      expect(find.text('Este campo é obrigatório.'), findsNWidgets(2));

      expect(service.createdIssue, isNull);
    });

    testWidgets('deve criar uma ocorrência com sucesso', (tester) async {
      final service = FakeIssueService();

      await pumpForm(tester, service: service);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Erro ao cadastrar usuário',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        'O sistema apresenta erro ao cadastrar.',
      );

      await tester.enterText(find.byType(TextFormField).at(2), 'Resolve');

      await tester.tap(find.text('Cadastrar ocorrência'));
      await tester.pumpAndSettle();

      expect(service.createdIssue, isNotNull);
      expect(service.createdIssue!.title, 'Erro ao cadastrar usuário');
      expect(service.createdIssue!.project, 'Resolve');

      // Após cadastrar, deve retornar ao dashboard.
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('deve carregar os dados ao editar uma ocorrência', (
      tester,
    ) async {
      final service = FakeIssueService();

      await pumpForm(
        tester,
        service: service,
        initialLocation: '/issues/1/edit',
      );

      expect(find.text('Editar ocorrência'), findsNWidgets(2));
      expect(find.text('Salvar alterações'), findsOneWidget);

      final titleField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(0),
      );

      final projectField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(2),
      );

      expect(titleField.controller!.text, 'Erro no login');
      expect(projectField.controller!.text, 'Resolve');
    });

    testWidgets('deve atualizar uma ocorrência com sucesso', (tester) async {
      final service = FakeIssueService();

      await pumpForm(
        tester,
        service: service,
        initialLocation: '/issues/1/edit',
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Erro no cadastro',
      );

      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(service.updatedIssue, isNotNull);
      expect(service.updatedIssue!.id, 1);
      expect(service.updatedIssue!.title, 'Erro no cadastro');

      // Após editar, deve retornar ao dashboard.
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando falhar ao carregar', (
      tester,
    ) async {
      final service = FakeIssueService()..failLoad = true;

      await pumpForm(
        tester,
        service: service,
        initialLocation: '/issues/1/edit',
      );

      expect(
        find.text('Não foi possível carregar a ocorrência.'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir mensagem quando falhar ao criar', (tester) async {
      final service = FakeIssueService()..failCreate = true;

      await pumpForm(tester, service: service);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Erro ao cadastrar usuário',
      );

      await tester.enterText(find.byType(TextFormField).at(2), 'Resolve');

      await tester.tap(find.text('Cadastrar ocorrência'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erro ao salvar ocorrência:'), findsOneWidget);

      expect(find.text('Nova ocorrência'), findsNWidgets(2));
    });

    testWidgets('deve exibir mensagem quando falhar ao atualizar', (
      tester,
    ) async {
      final service = FakeIssueService()..failUpdate = true;

      await pumpForm(
        tester,
        service: service,
        initialLocation: '/issues/1/edit',
      );

      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erro ao salvar ocorrência:'), findsOneWidget);

      expect(find.text('Editar ocorrência'), findsNWidgets(2));
    });
  });
}
