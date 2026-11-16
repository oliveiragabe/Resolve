import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/issue.dart';
import 'package:mobile/screens/issues/issues_screen.dart';
import 'package:mobile/services/issue_service.dart';

class FakeIssueService extends IssueService {
  final List<Issue> issues;

  FakeIssueService(this.issues)
    : super(client: MockClient((_) async => http.Response('[]', 200)));

  @override
  Future<List<Issue>> getAll() async {
    return issues;
  }

  @override
  void dispose() {}
}

void main() {
  final issues = [
    const Issue(
      id: 1,
      title: 'Erro no login',
      project: 'Resolve',
      severity: 'critica',
      status: 'aberto',
    ),
    const Issue(
      id: 2,
      title: 'Botão não funciona',
      project: 'Cardápio Online',
      severity: 'baixa',
      status: 'em_resolucao',
    ),
    const Issue(
      id: 3,
      title: 'Falha no cadastro',
      project: 'Resolve',
      severity: 'media',
      status: 'fechado',
    ),
  ];

  Future<void> openScreen(WidgetTester tester, FakeIssueService service) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: IssuesScreen(service: service)));

    await tester.pumpAndSettle();
  }

  group('IssuesScreen', () {
    testWidgets('deve exibir todas as ocorrências', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      expect(find.text('Ocorrências'), findsOneWidget);
      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Botão não funciona'), findsOneWidget);
      expect(find.text('Falha no cadastro'), findsOneWidget);
      expect(find.text('3 ocorrência(s) encontrada(s)'), findsOneWidget);
    });

    testWidgets('deve pesquisar pelo título', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      await tester.enterText(find.byType(TextField), 'login');

      await tester.pumpAndSettle();

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Botão não funciona'), findsNothing);
      expect(find.text('1 ocorrência(s) encontrada(s)'), findsOneWidget);
    });

    testWidgets('deve pesquisar pelo nome do projeto', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      await tester.enterText(find.byType(TextField), 'Cardápio Online');

      await tester.pumpAndSettle();

      expect(find.text('Botão não funciona'), findsOneWidget);
      expect(find.text('Erro no login'), findsNothing);
      expect(find.text('1 ocorrência(s) encontrada(s)'), findsOneWidget);
    });

    testWidgets('deve filtrar por status', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aberto').last);
      await tester.pumpAndSettle();

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Botão não funciona'), findsNothing);
      expect(find.text('Falha no cadastro'), findsNothing);
      expect(find.text('1 ocorrência(s) encontrada(s)'), findsOneWidget);
    });

    testWidgets('deve filtrar por severidade', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crítica').last);
      await tester.pumpAndSettle();

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Botão não funciona'), findsNothing);
      expect(find.text('Falha no cadastro'), findsNothing);
      expect(find.text('1 ocorrência(s) encontrada(s)'), findsOneWidget);
    });

    testWidgets('deve combinar filtros de status e severidade', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aberto').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crítica').last);
      await tester.pumpAndSettle();

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Botão não funciona'), findsNothing);
      expect(find.text('Falha no cadastro'), findsNothing);
      expect(find.text('1 ocorrência(s) encontrada(s)'), findsOneWidget);
    });

    testWidgets('deve limpar todos os filtros', (tester) async {
      await openScreen(tester, FakeIssueService(issues));

      await tester.enterText(find.byType(TextField), 'login');

      await tester.pumpAndSettle();

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Erro no login'), findsOneWidget);
      expect(find.text('Botão não funciona'), findsOneWidget);
      expect(find.text('Falha no cadastro'), findsOneWidget);
      expect(find.text('3 ocorrência(s) encontrada(s)'), findsOneWidget);
    });
  });
}
