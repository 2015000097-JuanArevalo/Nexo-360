import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/services/event_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class CreateEventScreen extends StatefulWidget {
  final AppUser user;
  final EventService? service;

  const CreateEventScreen({super.key, required this.user, this.service});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController(text: '100');
  late final EventService _service;
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  bool _isPublic = true;
  bool _registrationOpen = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EventService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3, 12, 31),
    );
    if (selectedDate == null || !mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;
    final time = selectedTime ?? TimeOfDay.fromDateTime(_date);
    setState(() {
      _date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final capacity = int.tryParse(_capacityController.text.trim());
    if (capacity == null) return;

    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Crear evento',
      message:
          'Se publicará ${_nameController.text.trim()} para ${formatSchoolDateTime(_date)}.',
      confirmLabel: 'Crear evento',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.createEvent(
        creator: widget.user,
        name: _nameController.text,
        date: _date,
        location: _locationController.text,
        description: _descriptionController.text,
        capacity: capacity,
        isPublic: _isPublic,
        registrationOpen: _registrationOpen,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento creado correctamente.')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No se pudo crear el evento. Revisa tu rol, los campos y las reglas de Firestore.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Crear evento',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeading(
              title: 'Nuevo evento',
              description:
                  '${widget.user.accountLabel} · ${widget.user.eventRoleLabel}',
              accentColor: AppColors.youthCoral,
            ),
            const SizedBox(height: 20),
            NexoTextFormField(
              controller: _nameController,
              label: 'Nombre del evento',
              icon: Icons.event_outlined,
              validator: (value) => value == null || value.trim().length < 3
                  ? 'Escribe un nombre de al menos 3 caracteres.'
                  : value.trim().length > 160
                  ? 'El nombre no puede superar 160 caracteres.'
                  : null,
            ),
            const SizedBox(height: 14),
            NexoTextFormField(
              controller: _locationController,
              label: 'Ubicación',
              icon: Icons.place_outlined,
              validator: (value) => value == null || value.trim().length < 3
                  ? 'Escribe la ubicación.'
                  : null,
            ),
            const SizedBox(height: 14),
            NexoTextFormField(
              controller: _descriptionController,
              label: 'Descripción',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (value) => value == null || value.trim().length < 5
                  ? 'Escribe una descripción de al menos 5 caracteres.'
                  : value.trim().length > 3000
                  ? 'La descripción no puede superar 3000 caracteres.'
                  : null,
            ),
            const SizedBox(height: 14),
            NexoTextFormField(
              controller: _capacityController,
              label: 'Capacidad disponible',
              icon: Icons.groups_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                final capacity = int.tryParse(value?.trim() ?? '');
                if (capacity == null || capacity <= 0) {
                  return 'Ingresa una capacidad mayor que cero.';
                }
                return capacity > 10000
                    ? 'La capacidad máxima permitida es 10000.'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDateTime,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('Fecha: ${formatSchoolDateTime(_date)}'),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _isPublic,
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _isPublic = value;
                              if (!value) _registrationOpen = false;
                            });
                          },
                    secondary: const Icon(Icons.public_outlined),
                    title: const Text('Evento público'),
                    subtitle: const Text(
                      'Los eventos privados solo aparecen para usuarios autenticados.',
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _registrationOpen,
                    onChanged: !_isPublic || _saving
                        ? null
                        : (value) {
                            setState(() => _registrationOpen = value);
                          },
                    secondary: const Icon(Icons.how_to_reg_outlined),
                    title: const Text('Inscripciones abiertas'),
                    subtitle: const Text(
                      'Habilita el formulario público para este evento.',
                    ),
                  ),
                ],
              ),
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
                  : const Icon(Icons.add_circle_outline),
              label: Text(_saving ? 'Creando...' : 'Crear evento'),
            ),
          ],
        ),
      ),
    );
  }
}
