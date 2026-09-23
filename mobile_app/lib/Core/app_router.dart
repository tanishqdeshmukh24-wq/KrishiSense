import 'package:go_router/go_router.dart';

import '../screens/login/login_screen.dart';
import '../screens/main/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/main',
      builder: (context, state) => const MainShell(),
    ),
  ],
);