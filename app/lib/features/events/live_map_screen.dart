import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class LiveMapScreen extends StatelessWidget {
  final AppUser user;
  const LiveMapScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final canEdit = user.canManageEvents;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('event_live_locations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final points = snapshot.data!.docs.toList()
          ..sort((a, b) => (a.data()['pointNumber'] as int? ?? 0).compareTo(b.data()['pointNumber'] as int? ?? 0));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Croquis en tiempo real',
              description: 'Consulta qué evento se realiza en cada ubicación del Colegio Salesiano Don Bosco.',
              action: canEdit
                  ? FilledButton.icon(
                      onPressed: () => _locationDialog(context),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Actualizar punto'),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final map = AspectRatio(
                  aspectRatio: 816 / 515,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, size) => Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/images/croquis_evento.png', fit: BoxFit.cover),
                          ...points.map((point) {
                            final data = point.data();
                            final x = ((data['xPercent'] as num?)?.toDouble() ?? 50) / 100 * size.maxWidth;
                            final y = ((data['yPercent'] as num?)?.toDouble() ?? 50) / 100 * size.maxHeight;
                            final active = data['status'] == 'active';
                            return Positioned(
                              left: x - 18,
                              top: y - 18,
                              child: Tooltip(
                                message: data['eventName'] as String? ?? 'Ubicación',
                                child: InkWell(
                                  onTap: () => _showLocation(context, point, canEdit),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: active ? Colors.green : data['status'] == 'upcoming' ? Colors.orange : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black38)],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('${data['pointNumber'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
                final panel = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 8), Text('Actividades actuales', style: Theme.of(context).textTheme.titleMedium)]),
                        const SizedBox(height: 10),
                        if (points.isEmpty)
                          const Text('No hay ubicaciones activas.')
                        else
                          ...points.map((point) {
                            final data = point.data();
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(radius: 15, child: Text('${data['pointNumber'] ?? ''}')),
                              title: Text(data['eventName'] as String? ?? 'Sin evento'),
                              subtitle: Text('${data['locationName'] ?? ''} · ${data['status'] ?? ''}'),
                              onTap: () => _showLocation(context, point, canEdit),
                            );
                          }),
                      ],
                    ),
                  ),
                );
                if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: map), const SizedBox(width: 14), Expanded(child: panel)]);
                return Column(children: [map, const SizedBox(height: 12), panel]);
              },
            ),
          ],
        );
      },
    );
  }
}

void _showLocation(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> point, bool canEdit) {
  final data = point.data();
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Punto ${data['pointNumber']} · ${data['locationName'] ?? ''}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['eventName'] as String? ?? 'Sin actividad', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(data['description'] as String? ?? ''),
          const SizedBox(height: 8),
          Text('Estado: ${data['status'] ?? ''}'),
          if (data['startsAt'] != null) Text('Inicio: ${formatDateTime(data['startsAt'])}'),
          if (data['endsAt'] != null) Text('Fin: ${formatDateTime(data['endsAt'])}'),
        ],
      ),
      actions: [
        if (canEdit) TextButton(onPressed: () { Navigator.pop(context); _locationDialog(context, existing: point); }, child: const Text('Editar')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
      ],
    ),
  );
}

Future<void> _locationDialog(BuildContext context, {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
  final data = existing?.data() ?? <String, dynamic>{};
  final pointNumber = TextEditingController(text: '${data['pointNumber'] ?? 1}');
  final locationName = TextEditingController(text: data['locationName'] as String? ?? '');
  final eventId = TextEditingController(text: data['eventId'] as String? ?? '');
  final eventName = TextEditingController(text: data['eventName'] as String? ?? '');
  final description = TextEditingController(text: data['description'] as String? ?? '');
  final x = TextEditingController(text: '${data['xPercent'] ?? 50}');
  final y = TextEditingController(text: '${data['yPercent'] ?? 50}');
  String status = data['status'] as String? ?? 'active';
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'Actualizar punto del croquis' : 'Editar ubicación'),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(children: [Expanded(child: TextField(controller: pointNumber, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Punto del croquis (1–12)'))), const SizedBox(width: 10), Expanded(child: TextField(controller: locationName, decoration: const InputDecoration(labelText: 'Nombre de ubicación')))]),
                const SizedBox(height: 10),
                TextField(controller: eventId, decoration: const InputDecoration(labelText: 'ID del evento')),
                const SizedBox(height: 10),
                TextField(controller: eventName, decoration: const InputDecoration(labelText: 'Evento actual')),
                const SizedBox(height: 10),
                TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción')),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: TextField(controller: x, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'X %'))), const SizedBox(width: 10), Expanded(child: TextField(controller: y, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Y %')))]),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [DropdownMenuItem(value: 'active', child: Text('En curso')), DropdownMenuItem(value: 'upcoming', child: Text('Próximo')), DropdownMenuItem(value: 'finished', child: Text('Finalizado'))],
                  onChanged: (value) => setState(() => status = value ?? 'active'),
                ),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
      ),
    ),
  );
  if (saved != true) return;
  final payload = {
    'pointNumber': int.tryParse(pointNumber.text) ?? 1,
    'locationName': locationName.text.trim(),
    'eventId': eventId.text.trim(),
    'eventName': eventName.text.trim(),
    'description': description.text.trim(),
    'xPercent': double.tryParse(x.text) ?? 50,
    'yPercent': double.tryParse(y.text) ?? 50,
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  if (existing == null) {
    await FirebaseFirestore.instance.collection('event_live_locations').add(payload);
  } else {
    await existing.reference.set(payload, SetOptions(merge: true));
  }
  if (context.mounted) showMessage(context, 'Croquis actualizado.');
}
