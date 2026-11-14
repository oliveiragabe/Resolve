import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  Future<void> _refreshDashboard() async {
    setState(_loadIssues);
    await _issuesFuture;
  }

  @override
  void dispose() {
    _issueService.dispose();
    super.dispose();
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 16),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDashboard(List<Issue> issues) {
    final total = issues.length;

    final open = issues.where((issue) => issue.status == 'aberto').length;

    final inProgress = issues
        .where((issue) => issue.status == 'em_resolucao')
        .length;

    final closed = issues.where((issue) => issue.status == 'fechado').length;

    final low = issues.where((issue) => issue.severity == 'baixa').length;

    final medium = issues.where((issue) => issue.severity == 'media').length;

    final critical = issues
        .where((issue) => issue.severity == 'critica')
        .length;

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Visão geral',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Acompanhe as ocorrências dos seus projetos.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _sectionTitle('Resumo'),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _statCard(
                title: 'Total de ocorrências',
                value: total,
                icon: Icons.assignment_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              _statCard(
                title: 'Abertas',
                value: open,
                icon: Icons.error_outline,
                color: Colors.orange,
              ),
              _statCard(
                title: 'Em resolução',
                value: inProgress,
                icon: Icons.pending_actions,
                color: Colors.blue,
              ),
              _statCard(
                title: 'Fechadas',
                value: closed,
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _sectionTitle('Por severidade'),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _severityRow('Baixa', low, Colors.green),
                  const Divider(height: 24),
                  _severityRow('Média', medium, Colors.orange),
                  const Divider(height: 24),
                  _severityRow('Crítica', critical, Colors.redAccent),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: () => context.goNamed(AppRoutes.issues),
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver todas as ocorrências'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.goNamed(AppRoutes.issueForm),
            icon: const Icon(Icons.add),
            label: const Text('Nova ocorrência'),
          ),
        ],
      ),
    );
  }

  Widget _severityRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve'),
        actions: [
          IconButton(
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar painel',
          ),
        ],
      ),
      body: FutureBuilder<List<Issue>>(
        future: _issuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 42),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar o painel.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshDashboard,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildDashboard(snapshot.data ?? []);
        },
      ),
    );
  }
}
