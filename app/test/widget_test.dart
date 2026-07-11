import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/theme/app_theme.dart';
import 'package:nexo_360/core/widgets/nexo_ui.dart';

void main() {
  testWidgets('NEXO 360 brand renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: NexoLogo())),
      ),
    );

    expect(find.text('NEXO 360'), findsOneWidget);
    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
  });
}
