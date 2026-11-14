import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolve')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Painel de ocorrências'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.issues),
              child: const Text('Ver ocorrências'),
            ),
          ],
        ),
      ),
    );
  }
}
