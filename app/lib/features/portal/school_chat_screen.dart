import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class SchoolChatScreen extends StatefulWidget {
  final AppUser user;
  const SchoolChatScreen({super.key, required this.user});

  @override
  State<SchoolChatScreen> createState() => _SchoolChatScreenState();
}

class _SchoolChatScreenState extends State<SchoolChatScreen> {
  final message = TextEditingController();
  String channel = 'class';

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  bool get canSend => widget.user.isTeacher || widget.user.isTechnical || widget.user.eventPermissions.contains('class_representative');

  Future<void> send() async {
    final text = message.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance.collection('school_messages').add({
      'channel': channel,
      'classId': widget.user.classId,
      'courseId': channel == 'course' ? (widget.user.courseIds.isEmpty ? '' : widget.user.courseIds.first) : '',
      'authorId': widget.user.uid,
      'authorName': widget.user.displayName,
      'authorRole': widget.user.accountType,
      'message': text,
      'createdAt': FieldValue.serverTimestamp(),
      'moderated': false,
    });
    message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Chat escolar',
          description: 'Canal en tiempo real para dudas generales entre el encargado de clase, estudiantes y docentes.',
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: channel,
          decoration: const InputDecoration(labelText: 'Canal'),
          items: const [
            DropdownMenuItem(value: 'class', child: Text('Chat de la sección')),
            DropdownMenuItem(value: 'course', child: Text('Chat del primer curso asignado')),
          ],
          onChanged: (value) => setState(() => channel = value ?? 'class'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 510,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: widget.user.isTechnical
                ? FirebaseFirestore.instance.collection('school_messages').snapshots()
                : channel == 'class'
                    ? FirebaseFirestore.instance
                        .collection('school_messages')
                        .where('classId', isEqualTo: widget.user.classId)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('school_messages')
                        .where(
                          'courseId',
                          isEqualTo: widget.user.courseIds.isEmpty
                              ? '__none__'
                              : widget.user.courseIds.first,
                        )
                        .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data();
                if (widget.user.isTechnical) return data['channel'] == channel;
                if (data['channel'] != channel) return false;
                if (channel == 'class') return data['classId'] == widget.user.classId;
                return widget.user.courseIds.contains(data['courseId']);
              }).toList()
                ..sort((a, b) => asDate(a.data()['createdAt']).compareTo(asDate(b.data()['createdAt'])));
              if (docs.isEmpty) return const EmptyState(icon: Icons.chat_bubble_outline, title: 'Sin mensajes', message: 'Todavía no se ha iniciado esta conversación.');
              return Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final mine = data['authorId'] == widget.user.uid;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 580),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mine ? NexoColors.royalBlue.withValues(alpha: .14) : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(data['authorName'] as String? ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (widget.user.isTechnical) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () async {
                                      final confirmed = await confirmDialog(context, title: 'Eliminar mensaje', message: '¿Deseas retirar este mensaje del chat?', confirm: 'Eliminar');
                                      if (confirmed) await doc.reference.delete();
                                    },
                                    child: const Icon(Icons.delete_outline, size: 17),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(data['message'] as String? ?? ''),
                            const SizedBox(height: 4),
                            Text(formatDateTime(data['createdAt']), style: const TextStyle(fontSize: 10, color: NexoColors.muted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        if (canSend)
          Row(
            children: [
              Expanded(child: TextField(controller: message, minLines: 1, maxLines: 4, onSubmitted: (_) => send(), decoration: const InputDecoration(labelText: 'Escribe un mensaje', prefixIcon: Icon(Icons.message_outlined)))),
              const SizedBox(width: 10),
              FilledButton.icon(onPressed: send, icon: const Icon(Icons.send), label: const Text('Enviar')),
            ],
          )
        else
          const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Solo el encargado de clase y los docentes pueden iniciar mensajes.'), subtitle: Text('La conversación sigue siendo visible para toda la sección.'))),
      ],
    );
  }
}
