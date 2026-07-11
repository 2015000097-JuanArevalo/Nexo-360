import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/event_record.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/event_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/nexo_ui.dart';

class EventRegistrationScreen extends StatefulWidget {
  final String? eventId;
  final EventService? service;

  const EventRegistrationScreen({super.key, this.eventId, this.service});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _documentUrlController = TextEditingController();
  late final EventService _service;
  late Future<EventRecord?> _eventFuture;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EventService();
    _eventFuture = _service.loadRegistrationEvent(widget.eventId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _documentUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit(EventRecord event) async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await showNexoConfirmationDialog(
      context,
      title: 'Confirmar inscripción',
      message:
          'La inscripción para ${event.name} se enviará con estado pendiente.',
      confirmLabel: 'Enviar',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final registrationId = await _service.submitRegistration(
        eventId: event.id,
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        organization: _organizationController.text,
        documentUrl: _documentUrlController.text,
      );
      if (!mounted) return;
      final openStatus = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.mark_email_read, color: AppColors.success),
          title: const Text('Inscripción recibida'),
          content: SelectableText(
            'Estado inicial: Pendiente\n\nCódigo de seguimiento:\n$registrationId\n\nGuarda este código para consultar el resultado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cerrar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ver estado'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _organizationController.clear();
      _documentUrlController.clear();
      if (openStatus == true) {
        context.go(AppRoutes.registrationStatusFor(registrationId));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No se pudo enviar la inscripción. Verifica el evento, la conexión y las reglas de Firestore.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrototypeScreen(
      title: 'Inscripción pública',
      showDashboardAction: false,
      child: FutureBuilder<EventRecord?>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 340,
              child: AppLoadingIndicator(message: 'Cargando evento...'),
            );
          }
          if (snapshot.hasError) {
            return AppErrorMessage(
              message: 'No se pudo cargar el evento público.',
              onRetry: () {
                setState(() {
                  _eventFuture = _service.loadRegistrationEvent(widget.eventId);
                });
              },
            );
          }
          final event = snapshot.data;
          if (event == null) {
            return AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No hay inscripciones abiertas',
              description:
                  'Un organizador debe crear un evento público con inscripciones abiertas.',
              action: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.registrationStatus),
                icon: const Icon(Icons.manage_search),
                label: const Text('Consultar una inscripción'),
              ),
            );
          }
          if (!event.registrationOpen || event.status != 'active') {
            return const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Inscripción cerrada',
              description: 'Este evento ya no acepta nuevas inscripciones.',
            );
          }
          return _registrationForm(event);
        },
      ),
    );
  }

  Widget _registrationForm(EventRecord event) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(
            title: event.name,
            description:
                '${formatSchoolDateTime(event.date)} · ${event.location} · ${event.capacity} cupos',
            accentColor: AppColors.youthCoral,
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          NexoTextFormField(
            controller: _nameController,
            label: 'Nombre completo',
            icon: Icons.person_outline,
            validator: (value) => value == null || value.trim().length < 3
                ? 'Ingresa tu nombre completo.'
                : null,
          ),
          const SizedBox(height: 14),
          NexoTextFormField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value == null ||
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())
                ? 'Ingresa un correo válido.'
                : null,
          ),
          const SizedBox(height: 14),
          NexoTextFormField(
            controller: _phoneController,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.trim().length < 8
                ? 'Ingresa un teléfono válido.'
                : null,
          ),
          const SizedBox(height: 14),
          NexoTextFormField(
            controller: _organizationController,
            label: 'Institución u organización',
            icon: Icons.school_outlined,
            validator: (value) => value == null || value.trim().length < 2
                ? 'Ingresa tu institución.'
                : null,
          ),
          const SizedBox(height: 14),
          NexoTextFormField(
            controller: _documentUrlController,
            label: 'URL de documento (opcional)',
            icon: Icons.link_outlined,
            keyboardType: TextInputType.url,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              final uri = Uri.tryParse(text);
              return uri != null &&
                      (uri.scheme == 'https' || uri.scheme == 'http')
                  ? null
                  : 'Usa una URL http o https.';
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Para este prototipo se usa una URL. Firebase Storage no es obligatorio.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            AppErrorMessage(message: _error!),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : () => _submit(event),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_saving ? 'Enviando...' : 'Enviar inscripción'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.registrationStatus),
            icon: const Icon(Icons.manage_search),
            label: const Text('Ya me inscribí: consultar estado'),
          ),
        ],
      ),
    );
  }
}
