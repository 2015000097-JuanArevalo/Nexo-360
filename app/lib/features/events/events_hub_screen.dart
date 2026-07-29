import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import 'event_operations_screen.dart';
import 'live_map_screen.dart';
import 'registration_admin_screen.dart';

class EventsHubScreen extends StatelessWidget {
  final AppUser user;
  const EventsHubScreen({super.key, required this.user});

  void open(BuildContext context, String title, Widget child) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1240), child: child)),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        final events = snapshot.data?.docs.toList() ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        events.sort(
          (a, b) => asDate(a.data()['date']).compareTo(asDate(b.data()['date'])),
        );
        final school = events.where((doc) => doc.data()['eventType'] != 'youth').toList();
        final youth = events.where((doc) => doc.data()['eventType'] == 'youth').toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Eventos',
              description: 'Eventos escolares y Movimiento Juventud en secciones independientes.',
              action: user.canManageEvents
                  ? FilledButton.icon(onPressed: () => _eventDialog(context, user), icon: const Icon(Icons.add), label: const Text('Crear evento'))
                  : null,
            ),
            const SizedBox(height: 16),
            _YouthBanner(),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 820 ? 2 : 1;
              final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
              final cards = [
                ModuleCard(icon: Icons.map_outlined, title: 'Croquis en tiempo real', description: 'Ubicación y actividad actual en los doce puntos del colegio.', color: NexoColors.royalBlue, onTap: () => open(context, 'Croquis en tiempo real', LiveMapScreen(user: user))),
                ModuleCard(icon: Icons.groups_outlined, title: 'Operaciones Juventud', description: 'Comisiones, chat, solicitudes, inventario, presupuestos, avisos, galería y ayuda.', color: NexoColors.violet, onTap: () => open(context, 'Operaciones Juventud', EventOperationsScreen(user: user))),
                if (user.canManageEvents)
                  ModuleCard(icon: Icons.how_to_reg_outlined, title: 'Administrar inscripciones', description: 'Aprobar, reservar, rechazar y registrar la llegada de participantes.', color: NexoColors.coral, onTap: () => open(context, 'Inscripciones', RegistrationAdminScreen(user: user))),
                ModuleCard(icon: Icons.public, title: 'Página pública', description: 'Abrir información, formulario, seguimiento y croquis para visitantes.', color: NexoColors.cyan, onTap: () => launchUrl(Uri.parse(AppConfig.eventsPage), mode: LaunchMode.externalApplication)),
              ];
              return Wrap(spacing: 12, runSpacing: 12, children: cards.map((card) => SizedBox(width: width, child: card)).toList());
            }),
            const SizedBox(height: 22),
            _EventSection(title: 'Eventos escolares', icon: Icons.school_outlined, events: school, user: user),
            const SizedBox(height: 22),
            _EventSection(title: 'Movimiento Juventud', icon: Icons.groups_outlined, events: youth, user: user, youth: true),
          ],
        );
      },
    );
  }
}

class _YouthBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [NexoColors.coral, NexoColors.violet], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(width: 100, height: 100, color: Colors.black12, child: Image.asset('assets/images/juventud_2026.png', fit: BoxFit.contain)),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Movimiento Juventud', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Inscripciones, eventos, comisiones, reglamentos, solicitudes, inventarios, presupuestos y comunicación en tiempo real.', style: TextStyle(color: Color(0xFFFFEAF0))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _EventSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> events;
  final AppUser user;
  final bool youth;
  const _EventSection({required this.title, required this.icon, required this.events, required this.user, this.youth = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, color: youth ? NexoColors.coral : NexoColors.royalBlue), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleLarge)]),
        const SizedBox(height: 10),
        if (events.isEmpty)
          Text('No hay eventos publicados en esta sección.', style: const TextStyle(color: NexoColors.muted))
        else
          ...events.map((doc) {
            final data = doc.data();
            final open = data['registrationOpen'] == true && data['status'] == 'active';
            return Card(
              child: ExpansionTile(
                leading: CircleAvatar(backgroundColor: (youth ? NexoColors.coral : NexoColors.royalBlue).withValues(alpha: .13), child: Icon(icon, color: youth ? NexoColors.coral : NexoColors.royalBlue)),
                title: Text(data['name'] as String? ?? 'Evento'),
                subtitle: Text('${formatDateTime(data['date'])} · ${data['location'] ?? ''}'),
                trailing: Chip(label: Text(open ? 'Inscripción abierta' : '${data['status'] ?? 'cerrado'}')),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(data['description'] as String? ?? ''),
                  const SizedBox(height: 8),
                  Text('Área: ${data['area'] ?? 'General'} · Categoría: ${data['category'] ?? 'General'} · Capacidad: ${data['capacity'] ?? 0}'),
                  if ((data['regulationLink'] as String? ?? '').isNotEmpty) Text('Reglamento: ${data['regulationLink']}'),
                  if (user.canManageEvents) ...[
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(onPressed: () => _eventDialog(context, user, existing: doc), icon: const Icon(Icons.edit_outlined), label: const Text('Editar evento'))),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}

Future<void> _eventDialog(BuildContext context, AppUser user, {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
  final data = existing?.data() ?? <String, dynamic>{};
  final name = TextEditingController(text: data['name'] as String? ?? '');
  final description = TextEditingController(text: data['description'] as String? ?? '');
  final location = TextEditingController(text: data['location'] as String? ?? '');
  final capacity = TextEditingController(text: '${data['capacity'] ?? 100}');
  final area = TextEditingController(text: data['area'] as String? ?? '');
  final category = TextEditingController(text: data['category'] as String? ?? '');
  final regulation = TextEditingController(text: data['regulationLink'] as String? ?? '');
  DateTime date = data['date'] == null ? DateTime.now().add(const Duration(days: 7)) : asDate(data['date']);
  String eventType = data['eventType'] as String? ?? 'school';
  String status = data['status'] as String? ?? 'active';
  bool isPublic = data['isPublic'] as bool? ?? true;
  bool registrationOpen = data['registrationOpen'] as bool? ?? true;
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing == null ? 'Crear evento' : 'Editar evento', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: eventType,
                  decoration: const InputDecoration(labelText: 'Sección'),
                  items: const [DropdownMenuItem(value: 'school', child: Text('Evento escolar')), DropdownMenuItem(value: 'youth', child: Text('Movimiento Juventud'))],
                  onChanged: (value) => setState(() => eventType = value ?? 'school'),
                ),
                const SizedBox(height: 10),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
                const SizedBox(height: 10),
                TextField(controller: description, maxLines: 4, decoration: const InputDecoration(labelText: 'Descripción')),
                const SizedBox(height: 10),
                TextField(controller: location, decoration: const InputDecoration(labelText: 'Ubicación')),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: TextField(controller: area, decoration: const InputDecoration(labelText: 'Área'))), const SizedBox(width: 10), Expanded(child: TextField(controller: category, decoration: const InputDecoration(labelText: 'Categoría')))]),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacidad'))), const SizedBox(width: 10), Expanded(child: TextField(controller: regulation, decoration: const InputDecoration(labelText: 'Enlace de reglamento')))]),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 1095)));
                    if (selected == null || !context.mounted) return;
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(date));
                    if (time != null) setState(() => date = DateTime(selected.year, selected.month, selected.day, time.hour, time.minute));
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(formatDateTime(date)),
                ),
                SwitchListTile(value: isPublic, onChanged: (value) => setState(() { isPublic = value; if (!value) registrationOpen = false; }), title: const Text('Visible públicamente')),
                SwitchListTile(value: registrationOpen, onChanged: isPublic ? (value) => setState(() => registrationOpen = value) : null, title: const Text('Inscripciones abiertas')),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [DropdownMenuItem(value: 'active', child: Text('Activo')), DropdownMenuItem(value: 'completed', child: Text('Finalizado')), DropdownMenuItem(value: 'cancelled', child: Text('Cancelado'))],
                  onChanged: (value) => setState(() => status = value ?? 'active'),
                ),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), const SizedBox(width: 8), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))]),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  if (saved != true || name.text.trim().length < 3) return;
  final payload = {
    'name': name.text.trim(),
    'description': description.text.trim(),
    'date': Timestamp.fromDate(date),
    'location': location.text.trim(),
    'capacity': int.tryParse(capacity.text) ?? 0,
    'area': area.text.trim(),
    'category': category.text.trim(),
    'regulationLink': regulation.text.trim(),
    'eventType': eventType,
    'isPublic': isPublic,
    'registrationOpen': isPublic && registrationOpen,
    'status': status,
    'createdBy': data['createdBy'] ?? user.uid,
    'updatedAt': FieldValue.serverTimestamp(),
    if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
  };
  if (existing == null) {
    await FirebaseFirestore.instance.collection('events').add(payload);
  } else {
    await existing.reference.set(payload, SetOptions(merge: true));
  }
  if (context.mounted) showMessage(context, 'Evento guardado.');
}
