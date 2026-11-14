import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/issue_options.dart';
import '../../core/routes/app_routes.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';
import '../../widgets/issue_card.dart';

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
        const SizedBox(height: AppDimensions.spacingMD),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                  ...IssueOptions.statuses.map(
                    (option) => DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']!),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSeverity,
                decoration: const InputDecoration(labelText: 'Severidade'),
                items: [
                  const DropdownMenuItem(value: 'todas', child: Text('Todas')),
                  ...IssueOptions.severities.map(
                    (option) => DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']!),
                    ),
                  ),
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
                  const SizedBox(height: AppDimensions.spacingMD),
                  const Text('Não foi possível carregar as ocorrências.'),
                  const SizedBox(height: AppDimensions.spacingMD),
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
              padding: const EdgeInsets.all(AppDimensions.spacingLG),
              children: [
                _buildFilters(),
                const SizedBox(height: AppDimensions.spacingMD),
                Text(
                  '${filteredIssues.length} ocorrência(s) encontrada(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.spacingMD),
                if (filteredIssues.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingXXXL + 20,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 44,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: AppDimensions.spacingMD),
                        Text(
                          issues.isEmpty ? 'Nenhuma ocorrência cadastrada.' : 'Nenhuma ocorrência encontrada com esses filtros.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredIssues.map(
                    (issue) => IssueCard(
                      issue: issue,
                      onTap: () {
                        context.goNamed(
                          AppRoutes.issueDetails,
                          pathParameters: {'id': issue.id.toString()},
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
