import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/models/permission_record.dart';
import '../../core/services/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class QrValidationScreen extends StatefulWidget {
  final PermissionService? service;

  const QrValidationScreen({super.key, this.service});

  @override
  State<QrValidationScreen> createState() => _QrValidationScreenState();
}

class _QrValidationScreenState extends State<QrValidationScreen> {
  final _manualController = TextEditingController();
  final _scannerController = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late final PermissionService _service;
  PermissionValidationResult? _result;
  bool _processing = false;
  bool _scannerEnabled = false;
  String? _error;

  bool get _cameraSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PermissionService();
  }

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _validate(String rawValue) async {
    if (_processing || rawValue.trim().isEmpty) return;
    setState(() {
      _processing = true;
      _result = null;
      _error = null;
    });
    try {
      final result = await _service.validate(rawValue);
      if (!mounted) return;
      setState(() => _result = result);
      if (_scannerEnabled) {
        await _scannerController.stop();
        if (mounted) setState(() => _scannerEnabled = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No se pudo consultar Firestore. Revisa la conexión y las reglas.';
      });
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        _manualController.text = value;
        _validate(value);
        return;
      }
    }
  }

  void _enableScanner() {
    setState(() {
      _result = null;
      _error = null;
      _scannerEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await _scannerController.start();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _scannerEnabled = false;
          _error =
              'No se pudo abrir la cámara. Concede el permiso o usa el código manual.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Validar permiso QR',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            title: 'Consulta de permiso',
            description: 'Escanea el QR o pega el código manual como respaldo.',
            accentColor: AppColors.cyan,
          ),
          const SizedBox(height: 18),
          if (_cameraSupported) ...[
            if (_scannerEnabled)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                      Center(
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.cyan, width: 4),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _processing ? null : _enableScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Activar cámara y escanear'),
              ),
            const SizedBox(height: 14),
          ],
          NexoTextFormField(
            controller: _manualController,
            label: 'Código manual: permissionId|qrToken',
            icon: Icons.keyboard_outlined,
            onFieldSubmitted: _validate,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _processing
                ? null
                : () => _validate(_manualController.text),
            icon: _processing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.fact_check_outlined),
            label: Text(_processing ? 'Validando...' : 'Validar permiso'),
          ),
          if (!_cameraSupported) ...[
            const SizedBox(height: 12),
            const PrototypeNotice(
              message:
                  'La cámara no está disponible en esta plataforma. Usa el código manual de respaldo.',
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            AppErrorMessage(message: _error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 18),
            _ValidationResultCard(result: _result!),
          ],
        ],
      ),
    );
  }
}

class _ValidationResultCard extends StatelessWidget {
  final PermissionValidationResult result;

  const _ValidationResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(result.status);
    final permission = result.permission;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: presentation.background,
        border: Border.all(color: presentation.color, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(presentation.icon, color: presentation.color, size: 72),
          const SizedBox(height: 10),
          Text(
            presentation.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: presentation.color,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(result.message, textAlign: TextAlign.center),
          if (permission != null) ...[
            const Divider(height: 30),
            Text(
              permission.studentName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text('${permission.reason} · ${permission.destination}'),
            const SizedBox(height: 5),
            Text(
              '${formatSchoolDateTime(permission.validFrom)} — ${formatSchoolDateTime(permission.validUntil)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  _ResultPresentation _presentation(PermissionValidationStatus status) {
    return switch (status) {
      PermissionValidationStatus.valid => const _ResultPresentation(
        title: 'VÁLIDO',
        icon: Icons.verified,
        color: AppColors.success,
        background: AppColors.successSurface,
      ),
      PermissionValidationStatus.expired => const _ResultPresentation(
        title: 'EXPIRADO',
        icon: Icons.timer_off_outlined,
        color: AppColors.danger,
        background: AppColors.dangerSurface,
      ),
      PermissionValidationStatus.unauthorized => const _ResultPresentation(
        title: 'NO AUTORIZADO',
        icon: Icons.gpp_bad_outlined,
        color: AppColors.danger,
        background: AppColors.dangerSurface,
      ),
      PermissionValidationStatus.notFound => const _ResultPresentation(
        title: 'NO ENCONTRADO',
        icon: Icons.search_off_outlined,
        color: AppColors.danger,
        background: AppColors.dangerSurface,
      ),
      PermissionValidationStatus.notYetValid => const _ResultPresentation(
        title: 'AÚN NO INICIA',
        icon: Icons.schedule,
        color: AppColors.pending,
        background: AppColors.pendingSurface,
      ),
      PermissionValidationStatus.invalid => const _ResultPresentation(
        title: 'INVÁLIDO',
        icon: Icons.cancel_outlined,
        color: AppColors.danger,
        background: AppColors.dangerSurface,
      ),
    };
  }
}

class _ResultPresentation {
  final String title;
  final IconData icon;
  final Color color;
  final Color background;

  const _ResultPresentation({
    required this.title,
    required this.icon,
    required this.color,
    required this.background,
  });
}
