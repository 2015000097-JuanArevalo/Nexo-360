import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/app_user.dart';
import '../../core/services/presentation_seed_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class PresentationSetupScreen extends StatefulWidget {
  final AppUser user;
  final PresentationSeedService? service;

  const PresentationSetupScreen({super.key, required this.user, this.service});

  @override
  State<PresentationSetupScreen> createState() =>
      _PresentationSetupScreenState();
}

class _PresentationSetupScreenState extends State<PresentationSetupScreen> {
  late final PresentationSeedService _service;
  PresentationSeedResult? _result;
  bool _seeding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PresentationSeedService();
  }

  Future<void> _seed() async {
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Preparar datos de presentación',
      message:
          'Se crearán o actualizarán únicamente documentos con prefijo presentation-.',
      confirmLabel: 'Preparar demo',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _seeding = true;
      _error = null;
    });
    try {
      final result = await _service.seed(widget.user);
      if (!mounted) return;
      setState(() => _result = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de presentación preparados.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No se pudo completar la preparación. Verifica que exista un estudiante activo y que las reglas estén publicadas.';
      });
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Código copiado.')));
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Preparar presentación',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            title: 'Datos integrados de demostración',
            description:
                'Actualiza los casos críticos sin guardar contraseñas en el repositorio.',
            accentColor: AppColors.violet,
          ),
          const SizedBox(height: 18),
          const _SeedChecklist(),
          if (_error != null) ...[
            const SizedBox(height: 14),
            AppErrorMessage(message: _error!),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _seeding ? null : _seed,
            icon: _seeding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: Text(
              _seeding ? 'Preparando...' : 'Crear o refrescar datos demo',
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 18),
            _SeedResultCard(result: _result!, onCopy: _copy),
          ],
        ],
      ),
    );
  }
}

class _SeedChecklist extends StatelessWidget {
  const _SeedChecklist();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Aviso y actividad escolar',
      'Permiso válido por 8 horas',
      'Permiso expirado',
      'Evento público con inscripciones abiertas',
      'Inscripción pendiente para aprobar y hacer check-in',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: items
              .map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                  title: Text(item),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SeedResultCard extends StatelessWidget {
  final PresentationSeedResult result;
  final ValueChanged<String> onCopy;

  const _SeedResultCard({required this.result, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StatusBadge.success('Demo lista'),
            const SizedBox(height: 12),
            Text('Estudiante: ${result.studentName}'),
            const SizedBox(height: 12),
            _CodeRow(
              label: 'Código válido',
              value: result.validPermissionCode,
              onCopy: onCopy,
            ),
            const SizedBox(height: 10),
            _CodeRow(
              label: 'Código expirado',
              value: result.expiredPermissionCode,
              onCopy: onCopy,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onCopy;

  const _CodeRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 4),
                SelectableText(value),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onCopy(value),
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
    );
  }
}
