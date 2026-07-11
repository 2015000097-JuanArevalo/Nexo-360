import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/app_user.dart';
import '../../core/services/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class PermissionFormScreen extends StatefulWidget {
  final AppUser user;
  final PermissionService? service;

  const PermissionFormScreen({super.key, required this.user, this.service});

  @override
  State<PermissionFormScreen> createState() => _PermissionFormScreenState();
}

class _PermissionFormScreenState extends State<PermissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _destinationController = TextEditingController();
  late final PermissionService _service;
  late Future<List<AppUser>> _studentsFuture;
  AppUser? _student;
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(hours: 2));
  bool _saving = false;
  String? _error;

  bool get _direct => widget.user.isTechnical;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PermissionService();
    _studentsFuture = _service.loadActiveStudents();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool start}) async {
    final current = start ? _validFrom : _validUntil;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    final selectedTime = time ?? TimeOfDay.fromDateTime(current);
    final result = DateTime(
      date.year,
      date.month,
      date.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    setState(() {
      if (start) {
        _validFrom = result;
        if (!_validUntil.isAfter(_validFrom)) {
          _validUntil = _validFrom.add(const Duration(hours: 2));
        }
      } else {
        _validUntil = result;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_student == null) {
      setState(() => _error = 'Selecciona un estudiante.');
      return;
    }
    if (!_validUntil.isAfter(_validFrom)) {
      setState(() => _error = 'El vencimiento debe ser posterior al inicio.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_direct) {
        final payload = await _service.createPermission(
          creator: widget.user,
          student: _student!,
          reason: _reasonController.text,
          destination: _destinationController.text,
          validFrom: _validFrom,
          validUntil: _validUntil,
        );
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.verified, color: AppColors.success),
            title: const Text('Permiso creado'),
            content: SelectableText(
              'Código manual de respaldo:\n\n${payload.encodeManual()}',
            ),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: payload.encodeManual()),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        await _service.createPermissionRequest(
          requester: widget.user,
          student: _student!,
          reason: _reasonController.text,
          destination: _destinationController.text,
          validFrom: _validFrom,
          validUntil: _validUntil,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada para aprobación técnica.'),
          ),
        );
      }

      if (!mounted) return;
      _formKey.currentState!.reset();
      _reasonController.clear();
      _destinationController.clear();
      setState(() => _student = null);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _direct
            ? 'No se pudo crear el permiso. Revisa las reglas y los campos.'
            : 'No se pudo enviar la solicitud. Revisa las reglas de Firestore.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: _direct ? 'Crear permiso' : 'Solicitar permiso',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeading(
              title: _direct ? 'Nuevo permiso estudiantil' : 'Nueva solicitud',
              description: _direct
                  ? 'El permiso real se guardará en Firestore y generará un QR.'
                  : 'El personal técnico deberá aprobar esta solicitud.',
              accentColor: AppColors.violet,
            ),
            const SizedBox(height: 20),
            _studentSelector(),
            const SizedBox(height: 14),
            NexoTextFormField(
              controller: _reasonController,
              label: 'Motivo',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) => value == null || value.trim().length < 3
                  ? 'Escribe el motivo del permiso.'
                  : null,
            ),
            const SizedBox(height: 14),
            NexoTextFormField(
              controller: _destinationController,
              label: 'Destino o actividad',
              icon: Icons.place_outlined,
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Escribe el destino.'
                  : null,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final vertical = constraints.maxWidth < 560;
                final buttons = [
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _pickDateTime(start: true),
                    icon: const Icon(Icons.schedule),
                    label: Text('Inicio: ${formatSchoolDateTime(_validFrom)}'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _pickDateTime(start: false),
                    icon: const Icon(Icons.timer_off_outlined),
                    label: Text('Vence: ${formatSchoolDateTime(_validUntil)}'),
                  ),
                ];
                if (vertical) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buttons.first,
                      const SizedBox(height: 10),
                      buttons.last,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: buttons.first),
                    const SizedBox(width: 12),
                    Expanded(child: buttons.last),
                  ],
                );
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              AppErrorMessage(message: _error!),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.qr_code_2),
              label: Text(
                _saving
                    ? 'Guardando...'
                    : (_direct ? 'Crear permiso y QR' : 'Enviar solicitud'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentSelector() {
    return FutureBuilder<List<AppUser>>(
      future: _studentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: AppLoadingIndicator(message: 'Cargando estudiantes...'),
          );
        }
        if (snapshot.hasError) {
          return AppErrorMessage(
            message: 'No se pudieron consultar los estudiantes.',
            onRetry: () {
              setState(() => _studentsFuture = _service.loadActiveStudents());
            },
          );
        }

        final students = snapshot.data ?? const <AppUser>[];
        if (students.isEmpty) {
          return const AppEmptyState(
            icon: Icons.person_search_outlined,
            title: 'No hay estudiantes activos',
            description: 'Verifica los perfiles users/{uid} en Firestore.',
          );
        }
        return DropdownButtonFormField<AppUser>(
          initialValue: _student,
          decoration: const InputDecoration(
            labelText: 'Estudiante',
            prefixIcon: Icon(Icons.person_search_outlined),
          ),
          items: students
              .map(
                (student) => DropdownMenuItem(
                  value: student,
                  child: Text(
                    '${student.displayName} · ${student.classId ?? 'Sin clase'}',
                  ),
                ),
              )
              .toList(),
          onChanged: _saving
              ? null
              : (value) => setState(() => _student = value),
          validator: (value) =>
              value == null ? 'Selecciona un estudiante.' : null,
        );
      },
    );
  }
}
