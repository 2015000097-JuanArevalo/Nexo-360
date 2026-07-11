import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/services/school_portal_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

Future<bool> showCreateAssignmentSheet(
  BuildContext context, {
  required AppUser user,
  required SchoolPortalService service,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    builder: (context) => CreateAssignmentSheet(user: user, service: service),
  );
  return result ?? false;
}

class CreateAssignmentSheet extends StatefulWidget {
  final AppUser user;
  final SchoolPortalService service;

  const CreateAssignmentSheet({
    super.key,
    required this.user,
    required this.service,
  });

  @override
  State<CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState extends State<CreateAssignmentSheet> {
  static const _courses = [
    'Matemática',
    'Ciencias',
    'Comunicación y Lenguaje',
    'Tecnología',
    'Formación Humana',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attachmentController = TextEditingController();
  String _course = _courses.first;
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (!mounted) return;

    final selectedTime = time ?? const TimeOfDay(hour: 8, minute: 0);
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      setState(() => _error = 'Selecciona la fecha y hora de entrega.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.service.createAssignment(
        teacher: widget.user,
        title: _titleController.text,
        description: _descriptionController.text,
        course: _course,
        dueDate: _dueDate!,
        attachmentUrl: _attachmentController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No se pudo guardar. Revisa tu conexión y las reglas de Firestore.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nueva actividad',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Text(
                  'La actividad será visible para docentes y estudiantes.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                NexoTextFormField(
                  controller: _titleController,
                  label: 'Título',
                  icon: Icons.title,
                  validator: (value) => value == null || value.trim().length < 3
                      ? 'Escribe un título de al menos 3 caracteres.'
                      : null,
                ),
                const SizedBox(height: 14),
                NexoTextFormField(
                  controller: _descriptionController,
                  label: 'Instrucciones',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) => value == null || value.trim().length < 5
                      ? 'Escribe las instrucciones de la actividad.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _course,
                  decoration: const InputDecoration(
                    labelText: 'Curso',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: _courses
                      .map(
                        (course) => DropdownMenuItem(
                          value: course,
                          child: Text(course),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _course = value ?? _course),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickDueDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    _dueDate == null
                        ? 'Seleccionar fecha de entrega'
                        : 'Entrega: ${formatSchoolDateTime(_dueDate!)}',
                  ),
                ),
                const SizedBox(height: 14),
                NexoTextFormField(
                  controller: _attachmentController,
                  label: 'Enlace adjunto (opcional)',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final uri = Uri.tryParse(text);
                    return uri == null || !uri.hasScheme
                        ? 'Escribe un enlace completo, por ejemplo https://...'
                        : null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  AppErrorMessage(message: _error!),
                ],
                const SizedBox(height: 20),
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
                      : const Icon(Icons.publish_outlined),
                  label: Text(_saving ? 'Guardando...' : 'Publicar actividad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
