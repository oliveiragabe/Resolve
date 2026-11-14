import 'package:flutter/material.dart';

import '../core/constants/app_dimensions.dart';
import '../core/theme/app_theme.dart';
import '../models/issue.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;

  const IssueCard({super.key, required this.issue, required this.onTap});

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

  Color _severityColor(String severity) {
    switch (severity) {
      case 'baixa':
        return Colors.green;
      case 'media':
        return Colors.orange;
      case 'critica':
        return Colors.redAccent;
      default:
        return AppTheme.textSecondary;
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
                'Projeto: ${issue.project}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSM),
              Text(
                'Status: ${_statusLabel(issue.status)}',
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
                    'Severidade: ${_severityLabel(issue.severity)}',
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
