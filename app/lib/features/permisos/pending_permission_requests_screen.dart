import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/models/permission_request.dart';
import '../../core/services/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class PendingPermissionRequestsScreen extends StatefulWidget {
  final AppUser user;
  final PermissionService? service;

  const PendingPermissionRequestsScreen({
    super.key,
    required this.user,
    this.service,
  });

  @override
  State<PendingPermissionRequestsScreen> createState() =>
      _PendingPermissionRequestsScreenState();
}

class _PendingPermissionRequestsScreenState
    extends State<PendingPermissionRequestsScreen> {
  late final PermissionService _service;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PermissionService();
  }

  Future<void> _approve(PermissionRequest request) async {
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Aprobar solicitud',
      message:
          'Se creará un permiso activo para ${request.studentName}. ¿Deseas continuar?',
      confirmLabel: 'Aprobar y crear permiso',
    );
    if (!confirmed || !mounted) return;
    setState(() => _processingId = request.id);
    try {
      await _service.approvePermissionRequest(
        request: request,
        reviewer: widget.user,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aprobada y permiso creado.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo aprobar. Revisa que siga pendiente y publica las reglas nuevas.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _deny(PermissionRequest request) async {
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Denegar solicitud',
      message:
          'La solicitud de ${request.studentName} quedará denegada y no se creará ningún permiso.',
      confirmLabel: 'Denegar',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _processingId = request.id);
    try {
      await _service.denyPermissionRequest(
        request: request,
        reviewer: widget.user,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud denegada.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo denegar la solicitud.')),
      );
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Solicitudes pendientes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeading(
            title: 'Bandeja técnica',
            description:
                'Aprueba para crear el permiso real o deniega la solicitud.',
            accentColor: AppColors.youthCoral,
          ),
          const SizedBox(height: 18),
          StreamBuilder<List<PermissionRequest>>(
            stream: _service.watchPendingPermissionRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 260,
                  child: AppLoadingIndicator(
                    message: 'Cargando solicitudes...',
                  ),
                );
              }
              if (snapshot.hasError) {
                return const AppErrorMessage(
                  message:
                      'No se pudieron consultar las solicitudes. Publica las reglas de Firestore actualizadas.',
                );
              }
              final requests = snapshot.data ?? const <PermissionRequest>[];
              if (requests.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No hay solicitudes pendientes',
                  description:
                      'Las solicitudes enviadas por docentes aparecerán aquí.',
                );
              }
              return Column(
                children: requests
                    .map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RequestCard(
                          request: request,
                          processing: _processingId == request.id,
                          disabled: _processingId != null,
                          onApprove: () => _approve(request),
                          onDeny: () => _deny(request),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final PermissionRequest request;
  final bool processing;
  final bool disabled;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  const _RequestCard({
    required this.request,
    required this.processing,
    required this.disabled,
    required this.onApprove,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.studentName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const StatusBadge.pending('Pendiente'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.classId ?? 'Sin clase asignada',
              style: const TextStyle(color: AppColors.muted),
            ),
            const Divider(height: 28),
            _RequestDetail(label: 'Motivo', value: request.reason),
            _RequestDetail(label: 'Destino', value: request.destination),
            _RequestDetail(
              label: 'Vigencia',
              value:
                  '${formatSchoolDateTime(request.validFrom)} — ${formatSchoolDateTime(request.validUntil)}',
            ),
            _RequestDetail(
              label: 'Solicitada',
              value: formatSchoolDateTime(request.createdAt),
            ),
            const SizedBox(height: 16),
            if (processing)
              const Center(
                child: CircularProgressIndicator(color: AppColors.violet),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: disabled ? null : onDeny,
                      icon: const Icon(Icons.close),
                      label: const Text('Denegar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: disabled ? null : onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Aprobar'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestDetail extends StatelessWidget {
  final String label;
  final String value;

  const _RequestDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
