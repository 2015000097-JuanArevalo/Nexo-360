import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/app_session.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class Nexo360App extends StatefulWidget {
  const Nexo360App({super.key});

  @override
  State<Nexo360App> createState() => _Nexo360AppState();
}

class _Nexo360AppState extends State<Nexo360App> {
  late final AppSession _session;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _session = AppSession()..start();
    _router = createAppRouter(_session);
  }

  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEXO 360',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
