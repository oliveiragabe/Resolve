import 'package:flutter/material.dart';

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
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(issue.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
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
              const SizedBox(height: 6),
              Text('Status: ${_statusLabel(issue.status)}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: severityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Severidade: ${_severityLabel(issue.severity)}'),
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
