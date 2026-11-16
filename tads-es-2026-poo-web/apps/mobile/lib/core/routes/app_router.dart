import 'package:go_router/go_router.dart';

import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/issues/issues_screen.dart';
import '../../screens/issue_details/issue_details_screen.dart';
import '../../screens/issue_form/issue_form_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/issues',
      name: AppRoutes.issues,
      builder: (context, state) => const IssuesScreen(),
    ),
    // Nova ocorrência deve vir antes da rota dinâmica.
    GoRoute(
      path: '/issues/new',
      name: AppRoutes.issueForm,
      builder: (context, state) => const IssueFormScreen(),
    ),
    GoRoute(
      path: '/issues/:id',
      name: AppRoutes.issueDetails,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return IssueDetailsScreen(issueId: id);
      },
    ),
    GoRoute(
      path: '/issues/:id/edit',
      name: AppRoutes.issueEdit,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return IssueFormScreen(issueId: id);
      },
    ),
  ],
);
