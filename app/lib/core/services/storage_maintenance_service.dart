import 'package:flutter/material.dart';

import '../config/app_config.dart';

abstract final class StorageMaintenanceService {
  static Future<void> show(BuildContext context, {String? feature}) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_off_outlined),
        title: const Text('Nube en mantenimiento'),
        content: Text(
          '${feature ?? 'La carga de archivos'} no está disponible porque el proyecto funciona sin Firebase Storage. '
          'Los enlaces externos sí se pueden guardar. Cuando actives almacenamiento, compila con '
          '--dart-define=STORAGE_ENABLED=true.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  static bool get enabled => AppConfig.storageEnabled;
}
