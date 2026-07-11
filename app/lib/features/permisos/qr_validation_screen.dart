import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class QrValidationScreen extends StatefulWidget {
  const QrValidationScreen({super.key});

  @override
  State<QrValidationScreen> createState() => _QrValidationScreenState();
}

class _QrValidationScreenState extends State<QrValidationScreen> {
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Consultar QR',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            title: 'Consulta de permiso',
            description: 'Escanea el QR o escribe el código como respaldo.',
          ),
          const SizedBox(height: 18),
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 90),
                SizedBox(height: 12),
                Text('Vista de cámara', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Código del permiso',
              prefixIcon: Icon(Icons.keyboard_outlined),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => setState(() => _showResult = true),
            child: const Text('Consultar'),
          ),
          if (_showResult) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(Icons.verified, color: AppColors.success, size: 48),
                    const SizedBox(height: 8),
                    Text('Permiso válido', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    const Text('Ana López · válido hasta las 12:00 p. m.'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          const PrototypeNotice(),
        ],
      ),
    );
  }
}
