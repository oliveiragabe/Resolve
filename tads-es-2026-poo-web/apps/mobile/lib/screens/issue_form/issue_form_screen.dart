import 'package:flutter/material.dart';

class IssueFormScreen extends StatelessWidget {
  const IssueFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova ocorrência')),
      body: const Center(child: Text('Formulário de ocorrência')),
    );
  }
}
