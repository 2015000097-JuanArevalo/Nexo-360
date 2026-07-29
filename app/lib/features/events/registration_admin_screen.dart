import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/app_user.dart';
import '../../core/services/email_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class RegistrationAdminScreen extends StatefulWidget {
  final AppUser user;
  const RegistrationAdminScreen({super.key, required this.user});

  @override
  State<RegistrationAdminScreen> createState() => _RegistrationAdminScreenState();
}

class _RegistrationAdminScreenState extends State<RegistrationAdminScreen> {
  String status = 'all';
  final emailService = EmailService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('event_registration_requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return FirestoreError(snapshot.error);
        final docs = snapshot.data!.docs.where((doc) => status == 'all' || doc.data()['status'] == status).toList()
          ..sort((a, b) => asDate(b.data()['createdAt']).compareTo(asDate(a.data()['createdAt'])));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Administrar inscripciones',
              description: 'Revisa datos, aprueba, deja en reserva, rechaza, registra llegada y prepara el correo de respuesta.',
              action: DropdownButton<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Todas')),
                  DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                  DropdownMenuItem(value: 'approved', child: Text('Aprobadas')),
                  DropdownMenuItem(value: 'reserved', child: Text('En reserva')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rechazadas')),
                ],
                onChanged: (value) => setState(() => status = value ?? 'all'),
              ),
            ),
            const SizedBox(height: 16),
            if (!emailService.configured)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.email_outlined, color: Colors.orange),
                  title: Text('Correo automático pendiente de configuración'),
                  subtitle: Text('La app abrirá un correo prellenado. Para envío automático gratuito, configura el Google Apps Script incluido.'),
                ),
              ),
            if (docs.isEmpty)
              const EmptyState(icon: Icons.how_to_reg_outlined, title: 'Sin inscripciones', message: 'No hay registros con el filtro seleccionado.')
            else
              ...docs.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RegistrationCard(
                      doc: doc,
                      user: widget.user,
                      emailService: emailService,
                    ),
                  )),
          ],
        );
      },
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final AppUser user;
  final EmailService emailService;
  const _RegistrationCard({required this.doc, required this.user, required this.emailService});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final status = data['status'] as String? ?? 'pending';
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _color(status).withValues(alpha: .14),
          child: Icon(_icon(status), color: _color(status)),
        ),
        title: Text(data['fullName'] as String? ?? 'Participante'),
        subtitle: Text('${data['eventName'] ?? data['eventId'] ?? 'Evento'} · ${data['organization'] ?? ''} · ${data['email'] ?? ''}'),
        trailing: Chip(label: Text(_label(status))),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row('Teléfono', data['phone']),
          _row('Área', data['area']),
          _row('Categoría', data['category']),
          _row('Código', data['trackingCode'] ?? doc.id),
          _row('Fecha', formatDateTime(data['createdAt'])),
          _row('PDF', data['authorizationFileUrl'] ?? 'Storage en mantenimiento; no se adjuntó archivo.'),
          if ((data['reviewComment'] as String? ?? '').isNotEmpty) _row('Comentario', data['reviewComment']),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (status == 'pending' || status == 'reserved')
                FilledButton.tonalIcon(onPressed: () => _changeStatus(context, doc, user, emailService, 'approved'), icon: const Icon(Icons.check), label: const Text('Aprobar')),
              if (status == 'pending')
                OutlinedButton.icon(onPressed: () => _changeStatus(context, doc, user, emailService, 'reserved'), icon: const Icon(Icons.pause_circle_outline), label: const Text('Reserva')),
              if (status == 'pending' || status == 'reserved')
                OutlinedButton.icon(onPressed: () => _changeStatus(context, doc, user, emailService, 'rejected'), icon: const Icon(Icons.close), label: const Text('Rechazar')),
              if (status == 'approved' && data['checkedIn'] != true)
                FilledButton.icon(onPressed: () => _checkIn(context, doc, user), icon: const Icon(Icons.login), label: const Text('Marcar llegada')),
              if (status == 'approved' && data['checkedIn'] == true)
                const Chip(avatar: Icon(Icons.check_circle, color: Colors.green), label: Text('Ya llegó')),
              TextButton.icon(onPressed: () => _contact(context, data), icon: const Icon(Icons.email_outlined), label: const Text('Contactar')),
              if (user.isTechnical)
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await confirmDialog(context, title: 'Eliminar inscripción', message: 'Se eliminará la solicitud para que el participante pueda enviarla de nuevo.', confirm: 'Eliminar');
                    if (!confirmed) return;
                    final batch = FirebaseFirestore.instance.batch();
                    batch.delete(doc.reference);
                    batch.delete(FirebaseFirestore.instance.collection('public_registration_status').doc(doc.id));
                    await batch.commit();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 120, child: Text(label, style: const TextStyle(color: NexoColors.muted))), Expanded(child: SelectableText('${value ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)))]),
      );

  static Color _color(String status) => switch (status) {'approved' => Colors.green, 'reserved' => Colors.orange, 'rejected' => Colors.red, _ => NexoColors.violet};
  static IconData _icon(String status) => switch (status) {'approved' => Icons.check_circle_outline, 'reserved' => Icons.pause_circle_outline, 'rejected' => Icons.cancel_outlined, _ => Icons.pending_actions};
  static String _label(String status) => switch (status) {'approved' => 'Aprobada', 'reserved' => 'Reserva', 'rejected' => 'Rechazada', _ => 'Pendiente'};
}

Future<void> _changeStatus(
  BuildContext context,
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
  AppUser user,
  EmailService emailService,
  String status,
) async {
  final comment = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cambiar estado a $status'),
      content: TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Comentario para el participante')),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
    ),
  );
  if (saved != true) return;
  final batch = FirebaseFirestore.instance.batch();
  batch.update(doc.reference, {
    'status': status,
    'reviewComment': comment.text.trim(),
    'reviewedBy': user.uid,
    'reviewedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  batch.set(FirebaseFirestore.instance.collection('public_registration_status').doc(doc.id), {
    'eventId': doc.data()['eventId'],
    'eventName': doc.data()['eventName'],
    'status': status,
    'checkedIn': doc.data()['checkedIn'] == true,
    'publicComment': comment.text.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  await batch.commit();

  final data = doc.data();
  try {
    if (emailService.configured) {
      await emailService.sendRegistrationDecision(
        email: data['email'] as String? ?? '',
        name: data['fullName'] as String? ?? '',
        eventName: data['eventName'] as String? ?? data['eventId'] as String? ?? '',
        status: status,
        trackingCode: data['trackingCode'] as String? ?? doc.id,
      );
    } else {
      await _openMail(data, status, comment.text.trim());
    }
    if (context.mounted) showMessage(context, 'Estado actualizado y respuesta preparada.');
  } catch (exception) {
    if (context.mounted) showMessage(context, 'El estado se actualizó, pero el correo falló: $exception', error: true);
  }
}

Future<void> _checkIn(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc, AppUser user) async {
  final batch = FirebaseFirestore.instance.batch();
  batch.update(doc.reference, {
    'checkedIn': true,
    'checkedInAt': FieldValue.serverTimestamp(),
    'checkedInBy': user.uid,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  batch.set(FirebaseFirestore.instance.collection('public_registration_status').doc(doc.id), {
    'checkedIn': true,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  await batch.commit();
  if (context.mounted) showMessage(context, 'Llegada registrada.');
}

Future<void> _contact(BuildContext context, Map<String, dynamic> data) async {
  final email = data['email'] as String? ?? '';
  final uri = Uri(scheme: 'mailto', path: email, queryParameters: {'subject': 'Inscripción NEXO 360', 'body': 'Hola ${data['fullName']},\n\nNos comunicamos respecto a tu inscripción en ${data['eventName'] ?? 'el evento'}.'});
  if (!await launchUrl(uri)) {
    if (context.mounted) showMessage(context, 'No fue posible abrir el cliente de correo.', error: true);
  }
}

Future<void> _openMail(Map<String, dynamic> data, String status, String comment) async {
  final label = switch (status) {'approved' => 'aprobada', 'reserved' => 'colocada en reserva', _ => 'rechazada'};
  final uri = Uri(
    scheme: 'mailto',
    path: data['email'] as String? ?? '',
    queryParameters: {
      'subject': 'Estado de inscripción · ${data['eventName'] ?? 'NEXO 360'}',
      'body': 'Hola ${data['fullName']},\n\nTu inscripción fue $label.\n${comment.isEmpty ? '' : '\nComentario: $comment'}\n\nCódigo: ${data['trackingCode'] ?? ''}\n\nNEXO 360',
    },
  );
  await launchUrl(uri);
}
