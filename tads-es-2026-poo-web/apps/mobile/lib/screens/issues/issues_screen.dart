import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocorrências')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.goNamed(AppRoutes.issueForm),
          child: const Text('Nova ocorrência'),
        ),
      ),
    );
  }
}
