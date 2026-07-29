import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/services/storage_maintenance_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class AnnouncementsScreen extends StatelessWidget {
  final AppUser user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('school_announcements').snapshots(),
      builder: (context, announcementSnapshot) {
        if (!announcementSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (announcementSnapshot.hasError) return FirestoreError(announcementSnapshot.error);
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('announcement_reads')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, readSnapshot) {
            final readIds = readSnapshot.data?.docs
                    .map((doc) => doc.data()['announcementId'] as String? ?? '')
                    .toSet() ??
                <String>{};
            final docs = announcementSnapshot.data!.docs
                .where((doc) => _visibleFor(doc.data(), user))
                .toList()
              ..sort((a, b) => asDate(b.data()['createdAt']).compareTo(asDate(a.data()['createdAt'])));
            final unread = docs.where((doc) => !readIds.contains(doc.id)).toList();
            final read = docs.where((doc) => readIds.contains(doc.id)).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeading(
                  title: 'Avisos',
                  description: 'Los avisos leídos y no leídos se muestran en apartados separados.',
                  action: user.canPublishSchool
                      ? FilledButton.icon(
                          onPressed: () => _createAnnouncement(context, user),
                          icon: const Icon(Icons.add_alert_outlined),
                          label: const Text('Nuevo aviso'),
                        )
                      : null,
                ),
                const SizedBox(height: 18),
                _Section(
                  title: 'No leídos',
                  icon: Icons.mark_email_unread_outlined,
                  docs: unread,
                  user: user,
                  unread: true,
                ),
                const SizedBox(height: 22),
                _Section(
                  title: 'Leídos',
                  icon: Icons.drafts_outlined,
                  docs: read,
                  user: user,
                  unread: false,
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _visibleFor(Map<String, dynamic> data, AppUser user) {
    if (user.isTechnical) return true;
    final scope = data['scope'] as String? ?? 'general';
    if (scope == 'general') return true;
    if (scope == 'class') return data['classId'] == user.classId;
    if (scope == 'course') return user.courseIds.contains(data['courseId']);
    return true;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final AppUser user;
  final bool unread;
  const _Section({
    required this.title,
    required this.icon,
    required this.docs,
    required this.user,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, color: NexoColors.coral), const SizedBox(width: 8), Text('$title (${docs.length})', style: Theme.of(context).textTheme.titleLarge)]),
        const SizedBox(height: 10),
        if (docs.isEmpty)
          Text(unread ? 'No tienes avisos pendientes.' : 'Todavía no has leído avisos.')
        else
          ...docs.map((doc) {
            final data = doc.data();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: unread ? NexoColors.coral.withValues(alpha: .12) : NexoColors.muted.withValues(alpha: .12),
                    child: Icon(unread ? Icons.notifications_active_outlined : Icons.notifications_none, color: unread ? NexoColors.coral : NexoColors.muted),
                  ),
                  title: Text(data['title'] as String? ?? 'Aviso', style: TextStyle(fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                  subtitle: Text('${data['message'] ?? ''}\n${data['authorName'] ?? ''} · ${formatDateTime(data['createdAt'])}'),
                  isThreeLine: true,
                  trailing: unread
                      ? TextButton(
                          onPressed: () => _markRead(doc.id, user.uid),
                          child: const Text('Marcar leído'),
                        )
                      : null,
                  onTap: () => _showDetails(context, doc, user, unread),
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _markRead(String announcementId, String userId) => FirebaseFirestore.instance
      .collection('announcement_reads')
      .doc('${announcementId}_$userId')
      .set({
        'announcementId': announcementId,
        'userId': userId,
        'readAt': FieldValue.serverTimestamp(),
      });

  void _showDetails(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    AppUser user,
    bool unread,
  ) {
    if (unread) _markRead(doc.id, user.uid);
    final data = doc.data();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title'] as String? ?? 'Aviso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['message'] as String? ?? ''),
            if ((data['linkUrl'] as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectableText('Enlace: ${data['linkUrl']}'),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }
}

Future<void> _createAnnouncement(BuildContext context, AppUser user) async {
  final title = TextEditingController();
  final message = TextEditingController();
  final classId = TextEditingController(text: user.classId);
  final courseId = TextEditingController();
  final link = TextEditingController();
  String scope = 'general';
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Nuevo aviso'),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 12),
                TextField(controller: message, maxLines: 4, decoration: const InputDecoration(labelText: 'Mensaje')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: scope,
                  decoration: const InputDecoration(labelText: 'Destinatarios'),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'class', child: Text('Grado y sección')),
                    DropdownMenuItem(value: 'course', child: Text('Curso')),
                  ],
                  onChanged: (value) => setState(() => scope = value ?? 'general'),
                ),
                if (scope == 'class') ...[const SizedBox(height: 12), TextField(controller: classId, decoration: const InputDecoration(labelText: 'Grado/sección'))],
                if (scope == 'course') ...[const SizedBox(height: 12), TextField(controller: courseId, decoration: const InputDecoration(labelText: 'ID del curso'))],
                const SizedBox(height: 12),
                TextField(controller: link, decoration: const InputDecoration(labelText: 'Enlace opcional')),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => StorageMaintenanceService.show(context, feature: 'La carga de archivos en avisos'),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Adjuntar archivo'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (title.text.trim().length < 3 || message.text.trim().length < 3) {
                showMessage(context, 'Completa el título y el mensaje.', error: true);
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    ),
  );
  if (saved != true) return;
  await FirebaseFirestore.instance.collection('school_announcements').add({
    'title': title.text.trim(),
    'message': message.text.trim(),
    'scope': scope,
    'classId': scope == 'class' ? classId.text.trim() : '',
    'courseId': scope == 'course' ? courseId.text.trim() : '',
    'linkUrl': link.text.trim(),
    'fileAttachments': <dynamic>[],
    'authorId': user.uid,
    'authorName': user.displayName,
    'createdAt': FieldValue.serverTimestamp(),
  });
  if (context.mounted) showMessage(context, 'Aviso publicado.');
}
