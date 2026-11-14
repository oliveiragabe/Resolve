import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';

class IssueDetailsScreen extends StatefulWidget {
  final int issueId;

  const IssueDetailsScreen({super.key, required this.issueId});

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  final IssueService _issueService = IssueService();

  late Future<Issue> _issueFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadIssue();
  }

  void _loadIssue() {
    _issueFuture = _issueService.getById(widget.issueId);
  }

  @override
  void dispose() {
    _issueService.dispose();
    super.dispose();
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

  Future<void> _updateStatus(Issue issue, String status) async {
    setState(() => _isUpdating = true);

    try {
      final updatedIssue = Issue(
        id: issue.id,
        title: issue.title,
        description: issue.description,
        project: issue.project,
        severity: issue.severity,
        status: status,
        createdAt: issue.createdAt,
        updatedAt: issue.updatedAt,
      );

      await _issueService.update(issue.id!, updatedIssue);

      if (!mounted) return;

      setState(() {
        _loadIssue();
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status atualizado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar status: $e')));
    }
  }

  Future<void> _deleteIssue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir ocorrência'),
        content: const Text('Tem certeza que deseja excluir esta ocorrência?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _issueService.delete(widget.issueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorrência excluída com sucesso!')),
      );

      context.goNamed(AppRoutes.issues);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir ocorrência: $e')));
    }
  }

  Widget _infoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da ocorrência')),
      body: FutureBuilder<Issue>(
        future: _issueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar a ocorrência.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(_loadIssue);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final issue = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                issue.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _infoCard('Projeto', issue.project),
              _infoCard('Severidade', _severityLabel(issue.severity)),
              _infoCard(
                'Descrição',
                issue.description?.isNotEmpty == true
                    ? issue.description!
                    : 'Sem descrição informada.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Status da ocorrência',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: issue.status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'aberto', child: Text('Aberto')),
                  DropdownMenuItem(
                    value: 'em_resolucao',
                    child: Text('Em resolução'),
                  ),
                  DropdownMenuItem(value: 'fechado', child: Text('Fechado')),
                ],
                onChanged: _isUpdating
                    ? null
                    : (status) {
                        if (status != null && status != issue.status) {
                          _updateStatus(issue, status);
                        }
                      },
              ),
              if (_isUpdating)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),

              FilledButton.icon(
                onPressed: () {
                  context.goNamed(
                    AppRoutes.issueEdit,
                    pathParameters: {'id': issue.id.toString()},
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar ocorrência'),
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _deleteIssue,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir ocorrência'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
