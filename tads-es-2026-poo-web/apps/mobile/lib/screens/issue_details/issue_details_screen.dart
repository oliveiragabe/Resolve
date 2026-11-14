import 'package:flutter/material.dart';

class IssueDetailsScreen extends StatelessWidget {
  final int issueId;

  const IssueDetailsScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: Center(child: Text('Ocorrência #$issueId')),
    );
  }
}
