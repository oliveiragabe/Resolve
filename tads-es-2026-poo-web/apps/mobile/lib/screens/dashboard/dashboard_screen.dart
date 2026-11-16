import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';
import '../../widgets/issue_card.dart';

class DashboardScreen extends StatefulWidget {
  final IssueService? service;

  const DashboardScreen({super.key, this.service});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final IssueService _service = widget.service ?? IssueService();

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
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _refreshIssues,
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
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
                  const Text(AppStrings.loadIssuesError),
                  const SizedBox(height: AppDimensions.spacingMD),
                  ElevatedButton(
                    onPressed: _refreshIssues,
                    child: const Text(AppStrings.tryAgain),
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
                    AppStrings.dashboardTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingSM),
                  Text(
                    AppStrings.dashboardDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  _sectionTitle(AppStrings.overview),

                  const SizedBox(height: AppDimensions.spacingMD),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth >= 1100
                          ? 4
                          : constraints.maxWidth >= 600
                          ? 2
                          : 1;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppDimensions.spacingMD,
                        mainAxisSpacing: AppDimensions.spacingMD,
                        childAspectRatio: 2.4,
                        children: [
                          _statCard(
                            AppStrings.total,
                            issues.length,
                            Icons.bug_report_outlined,
                          ),
                          _statCard(
                            AppStrings.openIssues,
                            openIssues,
                            Icons.error_outline,
                          ),
                          _statCard(
                            AppStrings.resolvingIssues,
                            resolvingIssues,
                            Icons.pending_actions,
                          ),
                          _statCard(
                            AppStrings.closedIssues,
                            closedIssues,
                            Icons.check_circle_outline,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  _sectionTitle(AppStrings.severity),

                  const SizedBox(height: AppDimensions.spacingMD),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingLG),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.danger,
                            size: AppDimensions.iconLG,
                          ),
                          const SizedBox(width: AppDimensions.spacingMD),
                          const Expanded(
                            child: Text(AppStrings.criticalIssues),
                          ),
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
                      _sectionTitle(AppStrings.recentIssues),
                      TextButton(
                        onPressed: () {
                          context.goNamed(AppRoutes.issues);
                        },
                        child: const Text(AppStrings.viewAll),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingMD),

                  if (recentIssues.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXL),
                        child: Center(
                          child: Text(AppStrings.noIssuesRegistered),
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
                      label: const Text(AppStrings.newIssue),
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
                      label: const Text(AppStrings.viewAllIssues),
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
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: AppDimensions.iconLG),
            const SizedBox(width: AppDimensions.spacingLG),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
