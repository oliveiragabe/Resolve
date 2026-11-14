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
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Issue>> _issuesFuture;

  String _selectedStatus = 'todos';
  String _selectedSeverity = 'todas';

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    _issuesFuture = _issueService.getAll();
  }

  Future<void> _refreshIssues() async {
    setState(_loadIssues);
    await _issuesFuture;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'todos';
      _selectedSeverity = 'todas';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  List<Issue> _filterIssues(List<Issue> issues) {
    final search = _searchController.text.trim().toLowerCase();

    return issues.where((issue) {
      final matchesSearch =
          issue.title.toLowerCase().contains(search) ||
          issue.project.toLowerCase().contains(search);

      final matchesStatus =
          _selectedStatus == 'todos' || issue.status == _selectedStatus;

      final matchesSeverity =
          _selectedSeverity == 'todas' || issue.severity == _selectedSeverity;

      return matchesSearch && matchesStatus && matchesSeverity;
    }).toList();
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Pesquisar ocorrência ou projeto...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'todos', child: Text('Todos')),
                  DropdownMenuItem(value: 'aberto', child: Text('Aberto')),
                  DropdownMenuItem(
                    value: 'em_resolucao',
                    child: Text('Em resolução'),
                  ),
                  DropdownMenuItem(value: 'fechado', child: Text('Fechado')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSeverity,
                decoration: const InputDecoration(labelText: 'Severidade'),
                items: const [
                  DropdownMenuItem(value: 'todas', child: Text('Todas')),
                  DropdownMenuItem(value: 'baixa', child: Text('Baixa')),
                  DropdownMenuItem(value: 'media', child: Text('Média')),
                  DropdownMenuItem(value: 'critica', child: Text('Crítica')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSeverity = value);
                  }
                },
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Limpar filtros'),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueCard(Issue issue) {
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
          final filteredIssues = _filterIssues(issues);

          return RefreshIndicator(
            onRefresh: _refreshIssues,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilters(),
                const SizedBox(height: 12),
                Text(
                  '${filteredIssues.length} ocorrência(s) encontrada(s)',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (filteredIssues.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 44,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          issues.isEmpty ? 'Nenhuma ocorrência cadastrada.' : 'Nenhuma ocorrência encontrada com esses filtros.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredIssues.map(_buildIssueCard),
              ],
            ),
          );
        },
      ),
    );
  }
}
