import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/services/storage_maintenance_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class EventOperationsScreen extends StatelessWidget {
  final AppUser user;
  const EventOperationsScreen({super.key, required this.user});

  void open(BuildContext context, String title, Widget child) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: child)),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _Operation(Icons.info_outline, 'Información y avisos', 'Calendario, reglamentos, avisos, enlaces y recursos organizados.', NexoColors.coral, () => open(context, 'Información y avisos', YouthContentScreen(user: user))),
      _Operation(Icons.smart_toy_outlined, 'Chat de ayuda', 'Asistente basado en preguntas frecuentes y contactos de los encargados.', NexoColors.violet, () => open(context, 'Chat de ayuda', EventHelpScreen(user: user))),
      _Operation(Icons.groups_outlined, 'Comisiones y chats', 'Integrantes, grupos por comisión y conversación regulada en tiempo real.', NexoColors.cyan, () => open(context, 'Comisiones y chats', CommitteesScreen(user: user))),
      _Operation(Icons.campaign_outlined, 'Solicitudes globales', 'Peticiones de materiales, apoyo y coordinación entre comisiones.', NexoColors.coral, () => open(context, 'Solicitudes', CommitteeRequestsScreen(user: user))),
      _Operation(Icons.inventory_2_outlined, 'Inventarios', 'Materiales disponibles, responsables y recursos utilizados por evento.', NexoColors.royalBlue, () => open(context, 'Inventarios', InventoryScreen(user: user))),
      _Operation(Icons.account_balance_wallet_outlined, 'Presupuestos', 'Partidas aprobadas y envío automático al inventario cuando se marca una compra.', NexoColors.violet, () => open(context, 'Presupuestos', BudgetsScreen(user: user))),
      _Operation(Icons.photo_library_outlined, 'Galería y archivos', 'Logos, fotografías, posters, reglamentos y autorizaciones por enlace.', NexoColors.coral, () => open(context, 'Galería y archivos', GalleryFilesScreen(user: user))),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(title: 'Operaciones de Movimiento Juventud', description: 'Herramientas completas para coordinación, comunicación, recursos y contenido.'),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 820 ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(spacing: 12, runSpacing: 12, children: cards.map((card) => SizedBox(width: width, child: ModuleCard(icon: card.icon, title: card.title, description: card.description, color: card.color, onTap: card.onTap))).toList());
        }),
      ],
    );
  }
}

class _Operation {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const _Operation(this.icon, this.title, this.description, this.color, this.onTap);
}

class YouthContentScreen extends StatelessWidget {
  final AppUser user;
  const YouthContentScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return _SimpleContentList(
      user: user,
      collection: 'event_announcements',
      title: 'Información y avisos',
      description: 'Avisos de Movimiento Juventud y eventos escolares con enlaces y alcance público.',
      icon: Icons.campaign_outlined,
      canEdit: user.canManageEvents,
      extraFields: const ['eventType', 'linkUrl'],
    );
  }
}

class GalleryFilesScreen extends StatelessWidget {
  final AppUser user;
  const GalleryFilesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.cloud_off_outlined, color: Colors.orange),
            title: Text('Almacenamiento en mantenimiento'),
            subtitle: Text('Puedes publicar enlaces externos. La subida directa de imágenes, PDF, DOCX y videos se habilitará cuando exista un servicio de almacenamiento.'),
          ),
        ),
        const SizedBox(height: 12),
        _SimpleContentList(
          user: user,
          collection: 'event_gallery_items',
          title: 'Galería, archivos y recursos',
          description: 'Contenido organizado por categoría mediante enlaces externos.',
          icon: Icons.photo_library_outlined,
          canEdit: user.canManageEvents || user.isCommissioner,
          extraFields: const ['category', 'linkUrl', 'year'],
          showStorageButton: true,
        ),
      ],
    );
  }
}

class _SimpleContentList extends StatelessWidget {
  final AppUser user;
  final String collection;
  final String title;
  final String description;
  final IconData icon;
  final bool canEdit;
  final List<String> extraFields;
  final bool showStorageButton;
  const _SimpleContentList({
    required this.user,
    required this.collection,
    required this.title,
    required this.description,
    required this.icon,
    required this.canEdit,
    this.extraFields = const [],
    this.showStorageButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.toList()..sort((a, b) => asDate(b.data()['createdAt']).compareTo(asDate(a.data()['createdAt'])));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: title,
              description: description,
              action: canEdit
                  ? FilledButton.icon(
                      onPressed: () => _contentDialog(context, collection, user, extraFields, showStorageButton),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              EmptyState(icon: icon, title: 'Sin contenido', message: 'Todavía no hay publicaciones en este apartado.')
            else
              ...docs.map((doc) {
                final data = doc.data();
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(icon)),
                    title: Text(data['title'] as String? ?? 'Publicación'),
                    subtitle: Text('${data['message'] ?? data['description'] ?? ''}\n${data['linkUrl'] ?? ''}'),
                    isThreeLine: true,
                    trailing: canEdit
                        ? PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') await _contentDialog(context, collection, user, extraFields, showStorageButton, existing: doc);
                              if (value == 'delete') await doc.reference.delete();
                            },
                            itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))],
                          )
                        : null,
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

Future<void> _contentDialog(
  BuildContext context,
  String collection,
  AppUser user,
  List<String> extraFields,
  bool showStorageButton, {
  QueryDocumentSnapshot<Map<String, dynamic>>? existing,
}) async {
  final data = existing?.data() ?? <String, dynamic>{};
  final title = TextEditingController(text: data['title'] as String? ?? '');
  final message = TextEditingController(text: (data['message'] ?? data['description']) as String? ?? '');
  final controllers = {for (final field in extraFields) field: TextEditingController(text: '${data[field] ?? ''}')};
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existing == null ? 'Agregar contenido' : 'Editar contenido'),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 10),
              TextField(controller: message, maxLines: 4, decoration: const InputDecoration(labelText: 'Mensaje o descripción')),
              ...extraFields.expand((field) => [const SizedBox(height: 10), TextField(controller: controllers[field], decoration: InputDecoration(labelText: _fieldLabel(field)))]),
              if (showStorageButton) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () => StorageMaintenanceService.show(context, feature: 'La subida directa de contenido de la galería'), icon: const Icon(Icons.upload_file), label: const Text('Subir archivo o imagen')),
              ],
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
    ),
  );
  if (saved != true || title.text.trim().isEmpty) return;
  final payload = <String, dynamic>{
    'title': title.text.trim(),
    'message': message.text.trim(),
    'authorId': user.uid,
    'authorName': user.displayName,
    'updatedAt': FieldValue.serverTimestamp(),
    if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
  };
  for (final field in extraFields) payload[field] = controllers[field]!.text.trim();
  if (existing == null) {
    await FirebaseFirestore.instance.collection(collection).add(payload);
  } else {
    await existing.reference.set(payload, SetOptions(merge: true));
  }
}

String _fieldLabel(String field) => switch (field) {
      'eventType' => 'Tipo de evento: school o youth',
      'linkUrl' => 'Enlace externo',
      'category' => 'Categoría',
      'year' => 'Año',
      _ => field,
    };

class EventHelpScreen extends StatefulWidget {
  final AppUser user;
  const EventHelpScreen({super.key, required this.user});

  @override
  State<EventHelpScreen> createState() => _EventHelpScreenState();
}

class _EventHelpScreenState extends State<EventHelpScreen> {
  final question = TextEditingController();
  String answer = 'Escribe una pregunta sobre fechas, categorías, reglamentos, ubicaciones o inscripciones.';

  @override
  void dispose() {
    question.dispose();
    super.dispose();
  }

  Future<void> search() async {
    final query = question.text.trim().toLowerCase();
    if (query.isEmpty) return;
    final snapshot = await FirebaseFirestore.instance.collection('event_faqs').get();
    QueryDocumentSnapshot<Map<String, dynamic>>? best;
    var bestScore = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final haystack = '${data['question']} ${List<String>.from(data['keywords'] as List? ?? const []).join(' ')}'.toLowerCase();
      final score = query.split(RegExp(r'\s+')).where((word) => word.length > 2 && haystack.contains(word)).length;
      if (score > bestScore) {
        bestScore = score;
        best = doc;
      }
    }
    setState(() {
      if (best != null && bestScore > 0) {
        answer = best!.data()['answer'] as String? ?? 'No hay una respuesta registrada.';
      } else {
        answer = 'No encontré una respuesta suficiente. Contacta a ${snapshot.docs.isNotEmpty ? snapshot.docs.first.data()['contactEmail'] ?? 'los encargados del movimiento' : 'los encargados del movimiento'}.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Chat de ayuda',
          description: 'Asistente local basado en la información verificada por los organizadores; no necesita una API de IA pagada.',
          action: widget.user.canManageEvents
              ? FilledButton.tonalIcon(onPressed: () => _faqDialog(context, widget.user), icon: const Icon(Icons.add), label: const Text('Agregar respuesta'))
              : null,
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: NexoColors.violet.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.smart_toy_outlined, color: NexoColors.violet), const SizedBox(width: 12), Expanded(child: Text(answer))]),
                ),
                const SizedBox(height: 14),
                TextField(controller: question, onSubmitted: (_) => search(), decoration: const InputDecoration(labelText: '¿Qué deseas saber?', prefixIcon: Icon(Icons.help_outline))),
                const SizedBox(height: 10),
                FilledButton.icon(onPressed: search, icon: const Icon(Icons.search), label: const Text('Buscar respuesta')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _faqDialog(BuildContext context, AppUser user) async {
  final question = TextEditingController();
  final answer = TextEditingController();
  final keywords = TextEditingController();
  final email = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Agregar pregunta frecuente'),
      content: SizedBox(
        width: 650,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: question, decoration: const InputDecoration(labelText: 'Pregunta')),
          const SizedBox(height: 10),
          TextField(controller: answer, maxLines: 4, decoration: const InputDecoration(labelText: 'Respuesta')),
          const SizedBox(height: 10),
          TextField(controller: keywords, decoration: const InputDecoration(labelText: 'Palabras clave separadas por coma')),
          const SizedBox(height: 10),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Correo de contacto')),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
    ),
  );
  if (saved != true) return;
  await FirebaseFirestore.instance.collection('event_faqs').add({
    'question': question.text.trim(),
    'answer': answer.text.trim(),
    'keywords': keywords.text.split(',').map((value) => value.trim().toLowerCase()).where((value) => value.isNotEmpty).toList(),
    'contactEmail': email.text.trim(),
    'createdBy': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

class CommitteesScreen extends StatefulWidget {
  final AppUser user;
  const CommitteesScreen({super.key, required this.user});

  @override
  State<CommitteesScreen> createState() => _CommitteesScreenState();
}

class _CommitteesScreenState extends State<CommitteesScreen> {
  String? selectedCommittee;
  final message = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('committees').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final committees = snapshot.data!.docs;
        selectedCommittee ??= committees.isEmpty ? null : committees.first.id;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Comisiones y comunicación',
              description: 'Cada comisión tiene su propio grupo; integrantes autorizados de otras comisiones también pueden participar.',
              action: widget.user.canManageEvents
                  ? FilledButton.icon(onPressed: () => _committeeDialog(context, widget.user), icon: const Icon(Icons.group_add_outlined), label: const Text('Crear comisión'))
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedCommittee,
              decoration: const InputDecoration(labelText: 'Comisión'),
              items: committees.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc.data()['name'] as String? ?? doc.id))).toList(),
              onChanged: (value) => setState(() => selectedCommittee = value),
            ),
            const SizedBox(height: 12),
            if (selectedCommittee == null)
              const EmptyState(icon: Icons.groups_outlined, title: 'Sin comisiones', message: 'Los organizadores deben crear las comisiones.')
            else ...[
              _CommitteeMembers(committeeId: selectedCommittee!, user: widget.user),
              if (widget.user.isTechnical || widget.user.isTeacher) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _DirectMessageModerationScreen(user: widget.user)),
                    ),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Moderar mensajes directos'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(height: 430, child: _CommitteeChat(committeeId: selectedCommittee!, user: widget.user)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: message, decoration: const InputDecoration(labelText: 'Mensaje para la comisión'))),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    if (message.text.trim().isEmpty) return;
                    await FirebaseFirestore.instance.collection('committee_messages').add({
                      'committeeId': selectedCommittee,
                      'authorId': widget.user.uid,
                      'authorName': widget.user.displayName,
                      'authorCommitteeId': widget.user.committeeId,
                      'message': message.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    message.clear();
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                ),
              ]),
            ],
          ],
        );
      },
    );
  }
}

class _CommitteeMembers extends StatelessWidget {
  final String committeeId;
  final AppUser user;
  const _CommitteeMembers({required this.committeeId, required this.user});

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('directory_profiles')
            .where('committeeId', isEqualTo: committeeId)
            .snapshots(),
        builder: (context, snapshot) {
          final members = snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Integrantes: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...members.map((doc) {
                    final data = doc.data();
                    final name = data['displayName'] as String? ?? 'Integrante';
                    if (doc.id == user.uid) return Chip(label: Text('$name · Tú'));
                    return ActionChip(
                      avatar: const Icon(Icons.chat_bubble_outline, size: 17),
                      label: Text(name),
                      tooltip: 'Abrir conversación directa',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _DirectChatScreen(
                            user: user,
                            recipientId: doc.id,
                            recipientName: name,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
}

class _DirectChatScreen extends StatefulWidget {
  final AppUser user;
  final String recipientId;
  final String recipientName;
  const _DirectChatScreen({
    required this.user,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<_DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<_DirectChatScreen> {
  final message = TextEditingController();

  String get conversationId {
    final ids = [widget.user.uid, widget.recipientId]..sort();
    return ids.join('_');
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = message.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance.collection('direct_messages').add({
      'conversationId': conversationId,
      'senderId': widget.user.uid,
      'senderName': widget.user.displayName,
      'recipientId': widget.recipientId,
      'recipientName': widget.recipientName,
      'message': text,
      'createdAt': FieldValue.serverTimestamp(),
      'moderated': false,
    });
    message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat · ${widget.recipientName}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('direct_messages')
                      .where('conversationId', isEqualTo: conversationId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs.toList()
                      ..sort((a, b) => asDate(a.data()['createdAt']).compareTo(asDate(b.data()['createdAt'])));
                    if (docs.isEmpty) return const Center(child: Text('Inicia la conversación.'));
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final own = data['senderId'] == widget.user.uid;
                        return Align(
                          alignment: own ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 520),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: own
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['senderName'] as String? ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(data['message'] as String? ?? ''),
                                const SizedBox(height: 4),
                                Text(formatDateTime(data['createdAt']), style: const TextStyle(fontSize: 11, color: NexoColors.muted)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: message,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(labelText: 'Mensaje directo'),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: send, icon: const Icon(Icons.send), label: const Text('Enviar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectMessageModerationScreen extends StatelessWidget {
  final AppUser user;
  const _DirectMessageModerationScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderación de mensajes directos')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('direct_messages').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs.toList()
              ..sort((a, b) => asDate(b.data()['createdAt']).compareTo(asDate(a.data()['createdAt'])));
            if (docs.isEmpty) return const EmptyState(icon: Icons.forum_outlined, title: 'Sin mensajes', message: 'Todavía no existen conversaciones directas.');
            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.chat_outlined)),
                  title: Text('${data['senderName'] ?? ''} → ${data['recipientName'] ?? ''}'),
                  subtitle: Text('${data['message'] ?? ''}\n${formatDateTime(data['createdAt'])}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Eliminar mensaje inapropiado',
                    onPressed: () => doc.reference.delete(),
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CommitteeChat extends StatelessWidget {
  final String committeeId;
  final AppUser user;
  const _CommitteeChat({required this.committeeId, required this.user});

  @override
  Widget build(BuildContext context) => Card(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('committee_messages')
              .where('committeeId', isEqualTo: committeeId)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.toList() ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            docs.sort(
              (a, b) => asDate(a.data()['createdAt'])
                  .compareTo(asDate(b.data()['createdAt'])),
            );
            if (docs.isEmpty) return const Center(child: Text('No hay mensajes.'));
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(data['authorName'] as String? ?? 'Integrante'),
                  subtitle: Text('${data['message'] ?? ''}\n${formatDateTime(data['createdAt'])}'),
                  isThreeLine: true,
                  trailing: user.isTechnical ? IconButton(onPressed: () => doc.reference.delete(), icon: const Icon(Icons.delete_outline)) : null,
                );
              },
            );
          },
        ),
      );
}

Future<void> _committeeDialog(BuildContext context, AppUser user) async {
  final name = TextEditingController();
  final description = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Crear comisión'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')), const SizedBox(height: 10), TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción'))]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Crear'))],
    ),
  );
  if (saved != true || name.text.trim().isEmpty) return;
  await FirebaseFirestore.instance.collection('committees').add({'name': name.text.trim(), 'description': description.text.trim(), 'createdBy': user.uid, 'createdAt': FieldValue.serverTimestamp()});
}

class CommitteeRequestsScreen extends StatefulWidget {
  final AppUser user;
  const CommitteeRequestsScreen({super.key, required this.user});

  @override
  State<CommitteeRequestsScreen> createState() => _CommitteeRequestsScreenState();
}

class _CommitteeRequestsScreenState extends State<CommitteeRequestsScreen> {
  final text = TextEditingController();

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(title: 'Solicitudes globales', description: 'Feed común para pedir materiales, personal o apoyo entre comisiones.'),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: TextField(controller: text, maxLines: 2, decoration: const InputDecoration(labelText: '¿Qué necesita tu comisión?'))), const SizedBox(width: 8), FilledButton.icon(onPressed: _send, icon: const Icon(Icons.send), label: const Text('Publicar'))]),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('committee_requests').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.toList() ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            docs.sort(
              (a, b) => asDate(b.data()['createdAt'])
                  .compareTo(asDate(a.data()['createdAt'])),
            );
            if (docs.isEmpty) return const EmptyState(icon: Icons.campaign_outlined, title: 'Sin solicitudes', message: 'No hay peticiones publicadas.');
            return Column(children: docs.map((doc) {
              final data = doc.data();
              return Card(child: ListTile(leading: const Icon(Icons.campaign_outlined), title: Text(data['message'] as String? ?? ''), subtitle: Text('${data['authorName'] ?? ''} · Comisión ${data['committeeId'] ?? 'general'} · ${formatDateTime(data['createdAt'])}'), trailing: widget.user.canManageEvents ? PopupMenuButton<String>(onSelected: (value) => doc.reference.update({'status': value, 'updatedAt': FieldValue.serverTimestamp()}), itemBuilder: (_) => const [PopupMenuItem(value: 'open', child: Text('Abierta')), PopupMenuItem(value: 'in_progress', child: Text('En proceso')), PopupMenuItem(value: 'resolved', child: Text('Resuelta'))]) : Chip(label: Text('${data['status'] ?? 'open'}'))));
            }).toList());
          },
        ),
      ],
    );
  }

  Future<void> _send() async {
    if (text.text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('committee_requests').add({
      'message': text.text.trim(),
      'committeeId': widget.user.committeeId,
      'authorId': widget.user.uid,
      'authorName': widget.user.displayName,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    text.clear();
  }
}

class InventoryScreen extends StatelessWidget {
  final AppUser user;
  const InventoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => _InventoryBudgetBase(
        user: user,
        inventory: true,
      );
}

class BudgetsScreen extends StatelessWidget {
  final AppUser user;
  const BudgetsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => _InventoryBudgetBase(
        user: user,
        inventory: false,
      );
}

class _InventoryBudgetBase extends StatelessWidget {
  final AppUser user;
  final bool inventory;
  const _InventoryBudgetBase({required this.user, required this.inventory});

  String get collection => inventory ? 'inventory_items' : 'budget_items';

  @override
  Widget build(BuildContext context) {
    final canEdit = user.canManageEvents || user.isCommissioner;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.toList();
        final total = inventory
            ? docs.fold<double>(0, (sum, doc) => sum + ((doc.data()['quantity'] as num?)?.toDouble() ?? 0))
            : docs.fold<double>(0, (sum, doc) => sum + ((doc.data()['approvedAmount'] as num?)?.toDouble() ?? 0));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: inventory ? 'Inventarios' : 'Presupuestos',
              description: inventory ? 'Materiales, cantidades, ubicación, evento y responsable.' : 'Partidas aprobadas; al marcar una compra puedes enviarla al inventario.',
              action: canEdit ? FilledButton.icon(onPressed: () => _inventoryBudgetDialog(context, user, inventory), icon: const Icon(Icons.add), label: const Text('Agregar')) : null,
            ),
            const SizedBox(height: 14),
            Card(child: ListTile(leading: Icon(inventory ? Icons.inventory_2_outlined : Icons.account_balance_wallet_outlined), title: Text(inventory ? 'Unidades registradas' : 'Presupuesto aprobado'), trailing: Text(inventory ? total.toStringAsFixed(0) : 'Q ${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall))),
            const SizedBox(height: 12),
            if (docs.isEmpty)
              EmptyState(icon: inventory ? Icons.inventory_2_outlined : Icons.account_balance_wallet_outlined, title: 'Sin registros', message: 'Agrega el primer elemento.')
            else
              ...docs.map((doc) {
                final data = doc.data();
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(inventory ? Icons.inventory_outlined : Icons.receipt_long_outlined)),
                    title: Text(data['name'] as String? ?? 'Elemento'),
                    subtitle: Text(inventory ? 'Cantidad: ${data['quantity'] ?? 0} · ${data['location'] ?? ''} · Responsable: ${data['responsibleName'] ?? ''}' : 'Q ${data['approvedAmount'] ?? 0} · Cantidad ${data['quantity'] ?? 0} · ${data['status'] ?? 'approved'}'),
                    trailing: Wrap(spacing: 4, children: [
                      if (!inventory && data['status'] != 'acquired' && canEdit)
                        FilledButton.tonal(onPressed: () => _acquireBudget(context, doc, user), child: const Text('Ya se posee')),
                      if (canEdit) IconButton(onPressed: () => _inventoryBudgetDialog(context, user, inventory, existing: doc), icon: const Icon(Icons.edit_outlined)),
                    ]),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

Future<void> _inventoryBudgetDialog(BuildContext context, AppUser user, bool inventory, {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
  final data = existing?.data() ?? <String, dynamic>{};
  final name = TextEditingController(text: data['name'] as String? ?? '');
  final quantity = TextEditingController(text: '${data['quantity'] ?? 1}');
  final amount = TextEditingController(text: '${data['approvedAmount'] ?? 0}');
  final location = TextEditingController(text: data['location'] as String? ?? '');
  final eventId = TextEditingController(text: data['eventId'] as String? ?? '');
  final responsible = TextEditingController(text: data['responsibleName'] as String? ?? user.displayName);
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(inventory ? 'Elemento de inventario' : 'Partida presupuestaria'),
      content: SizedBox(
        width: 620,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
          const SizedBox(height: 10),
          TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad')),
          if (!inventory) ...[const SizedBox(height: 10), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto aprobado en quetzales'))],
          const SizedBox(height: 10),
          TextField(controller: location, decoration: InputDecoration(labelText: inventory ? 'Ubicación/inventario' : 'Inventario de destino')),
          const SizedBox(height: 10),
          TextField(controller: eventId, decoration: const InputDecoration(labelText: 'ID del evento')),
          const SizedBox(height: 10),
          TextField(controller: responsible, decoration: const InputDecoration(labelText: 'Responsable')),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
    ),
  );
  if (saved != true || name.text.trim().isEmpty) return;
  final payload = {
    'name': name.text.trim(),
    'quantity': double.tryParse(quantity.text) ?? 0,
    if (!inventory) 'approvedAmount': double.tryParse(amount.text) ?? 0,
    'location': location.text.trim(),
    'eventId': eventId.text.trim(),
    'responsibleName': responsible.text.trim(),
    'status': data['status'] ?? (inventory ? 'available' : 'approved'),
    'updatedAt': FieldValue.serverTimestamp(),
    if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
    if (existing == null) 'createdBy': user.uid,
  };
  final collection = FirebaseFirestore.instance.collection(inventory ? 'inventory_items' : 'budget_items');
  if (existing == null) {
    await collection.add(payload);
  } else {
    await existing.reference.set(payload, SetOptions(merge: true));
  }
}

Future<void> _acquireBudget(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> budget, AppUser user) async {
  final data = budget.data();
  final batch = FirebaseFirestore.instance.batch();
  final inventory = FirebaseFirestore.instance.collection('inventory_items').doc();
  batch.set(inventory, {
    'name': data['name'],
    'quantity': data['quantity'],
    'location': data['location'],
    'eventId': data['eventId'],
    'responsibleName': data['responsibleName'],
    'status': 'available',
    'sourceBudgetId': budget.id,
    'createdBy': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  batch.update(budget.reference, {'status': 'acquired', 'inventoryItemId': inventory.id, 'updatedAt': FieldValue.serverTimestamp()});
  await batch.commit();
  if (context.mounted) showMessage(context, 'Elemento enviado al inventario.');
}
