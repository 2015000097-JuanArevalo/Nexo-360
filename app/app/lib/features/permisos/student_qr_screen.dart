import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/models/app_user.dart';
import '../../core/models/permission_record.dart';
import '../../core/services/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/utils/permission_qr_payload.dart';
import '../../core/widgets/nexo_ui.dart';

class StudentQrScreen extends StatefulWidget {
  final AppUser user;
  final PermissionService? service;

  const StudentQrScreen({super.key, required this.user, this.service});

  @override
  State<StudentQrScreen> createState() => _StudentQrScreenState();
}

class _StudentQrScreenState extends State<StudentQrScreen> {
  late final PermissionService _service;
  String? _selectedPermissionId;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PermissionService();
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Mi permiso y QR',
      child: StreamBuilder<List<PermissionRecord>>(
        stream: _service.watchStudentPermissions(widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 320,
              child: AppLoadingIndicator(message: 'Cargando permisos...'),
            );
          }
          if (snapshot.hasError) {
            return const AppErrorMessage(
              message:
                  'No se pudieron consultar los permisos. Verifica la consulta studentId y las reglas.',
            );
          }

          final permissions = snapshot.data ?? const <PermissionRecord>[];
          if (permissions.isEmpty) {
            return const AppEmptyState(
              icon: Icons.qr_code_2,
              title: 'No tienes permisos',
              description:
                  'Cuando el personal técnico cree un permiso aparecerá aquí.',
            );
          }

          final permission = _selectedPermission(permissions);
          final payload = PermissionQrPayload(
            permissionId: permission.id,
            qrToken: permission.qrToken,
          );
          final presentation = _presentation(permission);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                title: 'Permiso estudiantil',
                description: 'Presenta este código para validar tu autorización.',
                accentColor: AppColors.cyan,
              ),
              if (permissions.length > 1) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: permission.id,
                  decoration: const InputDecoration(
                    labelText: 'Permiso mostrado',
                    prefixIcon: Icon(Icons.history),
                  ),
                  items: permissions
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            '${item.reason} · ${formatSchoolDate(item.validUntil)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPermissionId = value);
                  },
                ),
              ],
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      StatusBadge(
                        label: presentation.label,
                        tone: presentation.tone,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        permission.studentName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        permission.classId ?? widget.user.schoolCode ?? 'Estudiante',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: QrImageView(
                          data: payload.encode(),
                          version: QrVersions.auto,
                          size: 220,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _InfoRow(label: 'Motivo', value: permission.reason),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Destino', value: permission.destination),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Vigencia',
                        value:
                            '${formatSchoolDateTime(permission.validFrom)} — ${formatSchoolDateTime(permission.validUntil)}',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: payload.encodeManual()),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código manual copiado.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copiar código manual'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PermissionRecord _selectedPermission(List<PermissionRecord> permissions) {
    if (_selectedPermissionId != null) {
      for (final permission in permissions) {
        if (permission.id == _selectedPermissionId) return permission;
      }
    }
    final now = DateTime.now();
    for (final permission in permissions) {
      if (permission.isCurrentlyValid(now)) return permission;
    }
    return permissions.first;
  }

  _PermissionPresentation _presentation(PermissionRecord permission) {
    final now = DateTime.now();
    if (permission.status == 'cancelled') {
      return const _PermissionPresentation('Cancelado', StatusTone.danger);
    }
    if (permission.status == 'used') {
      return const _PermissionPresentation('Utilizado', StatusTone.danger);
    }
    if (!now.isBefore(permission.validUntil) || permission.status == 'expired') {
      return const _PermissionPresentation('Expirado', StatusTone.danger);
    }
    if (now.isBefore(permission.validFrom)) {
      return const _PermissionPresentation('Aún no inicia', StatusTone.pending);
    }
    return const _PermissionPresentation('Permiso activo', StatusTone.success);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _PermissionPresentation {
  final String label;
  final StatusTone tone;

  const _PermissionPresentation(this.label, this.tone);
}
