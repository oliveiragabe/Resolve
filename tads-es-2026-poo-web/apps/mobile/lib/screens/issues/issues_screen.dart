import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final IssueService _issueService = IssueService();

  late Future<List<Issue>> _issuesFuture;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    _issuesFuture = _issueService.getAll();
  }

  Future<void> _refreshIssues() async {
    setState(() {
      _loadIssues();
    });

    await _issuesFuture;
  }

  @override
  void dispose() {
    _issueService.dispose();
    super.dispose();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aberto':
        return 'Aberto';
      case 'em_resolucao':
        return 'Em resolução';
      case 'fechado':
        return 'Fechado';
      default:
        return status;
    }
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'baixa':
        return 'Baixa';
      case 'media':
        return 'Média';
      case 'critica':
        return 'Crítica';
      default:
        return severity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências'),
        actions: [
          IconButton(
            onPressed: _refreshIssues,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(AppRoutes.issueForm),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Issue>>(
        future: _issuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  const Text('Não foi possível carregar as ocorrências.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refreshIssues,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final issues = snapshot.data ?? [];

          if (issues.isEmpty) {
            return const Center(child: Text('Nenhuma ocorrência cadastrada.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshIssues,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue = issues[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      issue.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Projeto: ${issue.project}'),
                          const SizedBox(height: 4),
                          Text('Status: ${_statusLabel(issue.status)}'),
                          Text('Severidade: ${_severityLabel(issue.severity)}'),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.goNamed(
                        AppRoutes.issueDetails,
                        pathParameters: {'id': issue.id.toString()},
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
