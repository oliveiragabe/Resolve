import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/issue_options.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';

class IssueDetailsScreen extends StatefulWidget {
  final int issueId;
  final IssueService? service;

  const IssueDetailsScreen({super.key, required this.issueId, this.service});

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  late final IssueService _issueService = widget.service ?? IssueService();

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
    if (widget.service == null) {
      _issueService.dispose();
    }

    super.dispose();
  }

  String _severityLabel(String severity) {
    return IssueOptions.severities.firstWhere(
      (option) => option['value'] == severity,
      orElse: () => {'label': severity},
    )['label']!;
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
        const SnackBar(content: Text(AppStrings.updateStatusSuccess)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.updateStatusError}$e')),
      );
    }
  }

  Future<void> _deleteIssue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteIssue),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _issueService.delete(widget.issueId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.deleteSuccess)));

      context.goNamed(AppRoutes.issues);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${AppStrings.deleteError}$e')));
    }
  }

  Widget _infoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar ao painel',
        ),
        title: const Text(AppStrings.issueDetailsTitle),
      ),
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
                  const Text(AppStrings.loadIssueDetailsError),
                  const SizedBox(height: AppDimensions.spacingMD),
                  ElevatedButton(
                    onPressed: () {
                      setState(_loadIssue);
                    },
                    child: const Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            );
          }

          final issue = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spacingLG),
            children: [
              Text(
                issue.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spacingLG),

              _infoCard(AppStrings.project, issue.project),
              _infoCard(AppStrings.severity, _severityLabel(issue.severity)),
              _infoCard(
                AppStrings.description,
                issue.description?.isNotEmpty == true
                    ? issue.description!
                    : AppStrings.noDescription,
              ),

              const SizedBox(height: AppDimensions.spacingLG),

              Text(
                AppStrings.issueStatus,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSM),

              DropdownButtonFormField<String>(
                initialValue: issue.status,
                decoration: const InputDecoration(labelText: AppStrings.status),
                items: IssueOptions.statuses.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
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
                  padding: EdgeInsets.only(top: AppDimensions.spacingMD),
                  child: LinearProgressIndicator(),
                ),

              const SizedBox(height: AppDimensions.spacingLG),

              FilledButton.icon(
                onPressed: () {
                  context.goNamed(
                    AppRoutes.issueEdit,
                    pathParameters: {'id': issue.id.toString()},
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text(AppStrings.editIssue),
              ),

              const SizedBox(height: AppDimensions.spacingXXL),

              OutlinedButton.icon(
                onPressed: _deleteIssue,
                icon: const Icon(Icons.delete_outline),
                label: const Text(AppStrings.deleteIssue),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
