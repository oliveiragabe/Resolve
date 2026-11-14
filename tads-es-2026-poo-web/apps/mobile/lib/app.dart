import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class ResolveApp extends StatelessWidget {
  const ResolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Resolve',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
