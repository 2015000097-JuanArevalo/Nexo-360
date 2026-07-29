import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  String palette = 'nexo';

  Color get seed => switch (palette) {
        'juventud' => NexoColors.coral,
        'azul' => NexoColors.royalBlue,
        'violeta' => NexoColors.violet,
        _ => NexoColors.primary,
      };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString('themeMode') ?? 'system';
    mode = ThemeMode.values.firstWhere(
      (value) => value.name == modeName,
      orElse: () => ThemeMode.system,
    );
    palette = prefs.getString('palette') ?? 'nexo';
    notifyListeners();
  }

  Future<void> setMode(ThemeMode value) async {
    mode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', value.name);
    notifyListeners();
  }

  Future<void> setPalette(String value) async {
    palette = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('palette', value);
    notifyListeners();
  }
}
