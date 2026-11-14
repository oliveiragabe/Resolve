import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';
import '../../widgets/issue_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final IssueService _service = IssueService();

  late Future<List<Issue>> _issuesFuture;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    _issuesFuture = _service.getAll();
  }

  Future<void> _refreshIssues() async {
    setState(() {
      _loadIssues();
    });

    await _issuesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resolve',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _refreshIssues,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: AppDimensions.spacingMD),
                  const Text('Erro ao carregar as ocorrências.'),
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

          final openIssues = issues
              .where((issue) => issue.status == 'aberto')
              .length;

          final resolvingIssues = issues
              .where((issue) => issue.status == 'em_resolucao')
              .length;

          final closedIssues = issues
              .where((issue) => issue.status == 'fechado')
              .length;

          final criticalIssues = issues
              .where((issue) => issue.severity == 'critica')
              .length;

          final recentIssues = issues.take(3).toList();

          return RefreshIndicator(
            onRefresh: _refreshIssues,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel geral',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingSM),
                  Text(
                    'Acompanhe as ocorrências dos seus projetos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  _sectionTitle('Visão geral'),

                  const SizedBox(height: AppDimensions.spacingMD),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppDimensions.spacingMD,
                    mainAxisSpacing: AppDimensions.spacingMD,
                    childAspectRatio: 1.7,
                    children: [
                      _statCard(
                        'Total',
                        issues.length,
                        Icons.bug_report_outlined,
                      ),
                      _statCard('Abertas', openIssues, Icons.error_outline),
                      _statCard(
                        'Em resolução',
                        resolvingIssues,
                        Icons.pending_actions,
                      ),
                      _statCard(
                        'Fechadas',
                        closedIssues,
                        Icons.check_circle_outline,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  _sectionTitle('Severidade'),

                  const SizedBox(height: AppDimensions.spacingMD),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingLG),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: AppDimensions.iconLG,
                          ),
                          const SizedBox(width: AppDimensions.spacingMD),
                          const Expanded(child: Text('Ocorrências críticas')),
                          Text(
                            criticalIssues.toString(),
                            style: const TextStyle(
                              fontSize: AppDimensions.fontXL,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('Ocorrências recentes'),
                      TextButton(
                        onPressed: () {
                          context.goNamed(AppRoutes.issues);
                        },
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingMD),

                  if (recentIssues.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXL),
                        child: Center(
                          child: Text('Nenhuma ocorrência cadastrada.'),
                        ),
                      ),
                    )
                  else
                    ...recentIssues.map(
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

                  const SizedBox(height: AppDimensions.spacingXXL),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.goNamed(AppRoutes.issueForm);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nova ocorrência'),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMD),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.goNamed(AppRoutes.issues);
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver todas as ocorrências'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _statCard(String title, int value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppTheme.primary, size: AppDimensions.iconMD),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
