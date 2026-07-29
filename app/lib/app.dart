import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/app_session.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class NexoBootstrap extends StatefulWidget {
  const NexoBootstrap({super.key});

  @override
  State<NexoBootstrap> createState() => _NexoBootstrapState();
}

class _NexoBootstrapState extends State<NexoBootstrap> {
  late final AppSession session;
  late final ThemeController themeController;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    session = AppSession()..start();
    themeController = ThemeController()..load();
    router = createAppRouter(session, themeController);
  }

  @override
  void dispose() {
    router.dispose();
    session.dispose();
    themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => MaterialApp.router(
        title: 'NEXO 360',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(themeController.seed),
        darkTheme: AppTheme.dark(themeController.seed),
        themeMode: themeController.mode,
        routerConfig: router,
      ),
    );
  }
}
