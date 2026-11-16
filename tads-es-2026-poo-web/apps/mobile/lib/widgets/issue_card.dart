import 'package:flutter/material.dart';

import '../core/constants/app_dimensions.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/issue_options.dart';
import '../core/theme/app_theme.dart';
import '../models/issue.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;

  const IssueCard({super.key, required this.issue, required this.onTap});

  String _statusLabel(String status) {
    return IssueOptions.statuses.firstWhere(
      (option) => option['value'] == status,
      orElse: () => {'label': status},
    )['label']!;
  }

  String _severityLabel(String severity) {
    return IssueOptions.severities.firstWhere(
      (option) => option['value'] == severity,
      orElse: () => {'label': severity},
    )['label']!;
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'baixa':
        return AppTheme.success;
      case 'media':
        return AppTheme.warning;
      case 'critica':
        return AppTheme.danger;
      default:
        return AppTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(issue.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.spacingLG),
        onTap: onTap,
        title: Text(
          issue.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spacingSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.projectLabel}${issue.project}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSM),
              Text(
                '${AppStrings.statusLabel}${_statusLabel(issue.status)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSM),
              Row(
                children: [
                  Container(
                    width: AppDimensions.spacingSM,
                    height: AppDimensions.spacingSM,
                    decoration: BoxDecoration(
                      color: severityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSM),
                  Text(
                    '${AppStrings.severityLabel}${_severityLabel(issue.severity)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
