import 'package:flutter/material.dart';

import 'features/login/login_screen.dart';

class Nexo360App extends StatelessWidget {
  const Nexo360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXO 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
