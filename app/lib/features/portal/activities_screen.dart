import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/services/storage_maintenance_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class ActivitiesScreen extends StatelessWidget {
  final AppUser user;
  const ActivitiesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('school_activities').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return FirestoreError(snapshot.error);
        final docs = (snapshot.data?.docs ?? const [])
            .where((doc) => _visibleFor(doc.data(), user))
            .toList()
          ..sort((a, b) => asDate(a.data()['dueDate']).compareTo(asDate(b.data()['dueDate'])));
        final grouped = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
        for (final doc in docs) {
          final due = asDate(doc.data()['dueDate']);
          grouped.putIfAbsent(dateKey(due), () => []).add(doc);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Actividades por fecha',
              description: 'Solo aparecen los días que tienen actividades. Las vencidas continúan disponibles en el historial.',
              action: user.canPublishSchool
                  ? FilledButton.icon(
                      onPressed: () => _showCreateActivity(context, user),
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva actividad'),
                    )
                  : null,
            ),
            const SizedBox(height: 18),
            if (grouped.isEmpty)
              const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No hay actividades',
                message: 'Todavía no existen actividades asignadas para tus cursos.',
              )
            else
              ...grouped.entries.map((entry) {
                final date = DateTime.parse(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_capitalize(weekdayName(date))}, ${formatDate(date)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: NexoColors.royalBlue),
                      ),
                      const SizedBox(height: 10),
                      ...entry.value.map((doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ActivityCard(user: user, doc: doc),
                          )),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  bool _visibleFor(Map<String, dynamic> data, AppUser user) {
    if (user.isTechnical) return true;
    if (user.isTeacher) return data['teacherId'] == user.uid || user.courseIds.contains(data['courseId']);
    final classId = data['classId'] as String? ?? '';
    final courseId = data['courseId'] as String? ?? '';
    return (classId.isEmpty || classId == user.classId) &&
        (courseId.isEmpty || user.courseIds.isEmpty || user.courseIds.contains(courseId));
  }

  static String _capitalize(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _ActivityCard extends StatelessWidget {
  final AppUser user;
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _ActivityCard({required this.user, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final due = asDate(data['dueDate']);
    final expired = DateTime.now().isAfter(due);
    final allowLate = data['allowLate'] as bool? ?? false;
    final links = List<Map<String, dynamic>>.from(data['resourceLinks'] as List? ?? const []);
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: expired ? Colors.red.withValues(alpha: .12) : NexoColors.royalBlue.withValues(alpha: .12),
          child: Icon(expired ? Icons.history : Icons.assignment_outlined, color: expired ? Colors.red : NexoColors.royalBlue),
        ),
        title: Text(data['title'] as String? ?? 'Actividad'),
        subtitle: Text(
          '${data['courseName'] ?? data['courseId'] ?? 'Curso'} · Entrega ${formatDateTime(due)}${expired ? ' · Vencida' : ''}',
        ),
        trailing: Chip(
          label: Text('${data['points'] ?? 0} pts'),
          visualDensity: VisualDensity.compact,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(data['description'] as String? ?? ''),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(allowLate ? 'Permite entregas tarde' : 'No permite entregas tarde')),
              Chip(label: Text((data['allowStudentLinks'] as bool? ?? true) ? 'Entrega por enlace' : 'Sin enlaces')),
              Chip(label: Text((data['allowStudentFiles'] as bool? ?? false) ? 'Archivo habilitado al activar Storage' : 'Sin archivos')),
            ],
          ),
          if (links.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Recursos', style: Theme.of(context).textTheme.titleSmall),
            ...links.map((link) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.link),
                  title: Text(link['label'] as String? ?? 'Enlace'),
                  subtitle: Text(link['url'] as String? ?? ''),
                )),
          ],
          const SizedBox(height: 10),
          if (user.isStudent)
            _SubmissionPanel(activityId: doc.id, activity: data, user: user)
          else
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showSubmissions(context, doc.id, data),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Ver entregas'),
                  ),
                  if (data['teacherId'] == user.uid || user.isTechnical)
                    OutlinedButton.icon(
                      onPressed: () => _editDueDate(context, doc),
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: const Text('Cambiar fecha'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editDueDate(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final current = asDate(doc.data()['dueDate']);
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));
    if (time == null || !context.mounted) return;
    final value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await doc.reference.update({'dueDate': Timestamp.fromDate(value), 'updatedAt': FieldValue.serverTimestamp()});
    if (context.mounted) showMessage(context, 'Fecha de entrega actualizada.');
  }

  void _showSubmissions(BuildContext context, String activityId, Map<String, dynamic> activity) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 650),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Entregas · ${activity['title']}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('activity_submissions')
                        .where('activityId', isEqualTo: activityId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return const Center(child: Text('Todavía no hay entregas.'));
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final submission = docs[index];
                          final data = submission.data();
                          return ListTile(
                            leading: Icon(data['isLate'] == true ? Icons.schedule : Icons.check_circle_outline),
                            title: Text(data['studentName'] as String? ?? data['studentId'] as String? ?? 'Estudiante'),
                            subtitle: Text('${data['linkUrl'] ?? 'Sin enlace'}\n${data['comment'] ?? ''}'),
                            isThreeLine: true,
                            trailing: SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: '${data['score'] ?? ''}',
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Nota'),
                                onFieldSubmitted: (value) async {
                                  final score = double.tryParse(value);
                                  final maximum = (activity['points'] as num?)?.toDouble() ?? 0;
                                  if (score == null || score < 0 || score > maximum) {
                                    showMessage(context, 'La nota debe estar entre 0 y $maximum.', error: true);
                                    return;
                                  }
                                  final batch = FirebaseFirestore.instance.batch();
                                  batch.update(submission.reference, {
                                    'score': score,
                                    'teacherComment': data['teacherComment'] ?? '',
                                    'gradedAt': FieldValue.serverTimestamp(),
                                  });
                                  final scoreRef = FirebaseFirestore.instance
                                      .collection('grade_scores')
                                      .doc('${activityId}_${data['studentId']}');
                                  batch.set(scoreRef, {
                                    'itemId': activityId,
                                    'courseId': activity['courseId'],
                                    'bimester': activity['bimester'] ?? 1,
                                    'studentId': data['studentId'],
                                    'studentName': data['studentName'],
                                    'classId': data['classId'],
                                    'score': score,
                                    'maxPoints': maximum,
                                    'teacherId': activity['teacherId'],
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));
                                  await batch.commit();
                                  if (context.mounted) showMessage(context, 'Nota guardada en la actividad y en Notas.');
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmissionPanel extends StatelessWidget {
  final String activityId;
  final Map<String, dynamic> activity;
  final AppUser user;
  const _SubmissionPanel({required this.activityId, required this.activity, required this.user});

  @override
  Widget build(BuildContext context) {
    final submissionId = '${activityId}_${user.uid}';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('activity_submissions').doc(submissionId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data != null) {
          return Card(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .35),
            child: ListTile(
              leading: Icon(data['isLate'] == true ? Icons.schedule : Icons.check_circle),
              title: Text(data['isLate'] == true ? 'Entrega tarde registrada' : 'Entrega registrada'),
              subtitle: Text('${data['linkUrl'] ?? 'Sin enlace'}${data['score'] != null ? ' · Nota: ${data['score']}' : ''}'),
              trailing: TextButton(
                onPressed: () => _showSubmissionDialog(context, existing: data),
                child: const Text('Editar'),
              ),
            ),
          );
        }
        return FilledButton.icon(
          onPressed: () => _showSubmissionDialog(context),
          icon: const Icon(Icons.upload_outlined),
          label: const Text('Entregar actividad'),
        );
      },
    );
  }

  Future<void> _showSubmissionDialog(BuildContext context, {Map<String, dynamic>? existing}) async {
    final due = asDate(activity['dueDate']);
    final late = DateTime.now().isAfter(due);
    final allowLate = activity['allowLate'] as bool? ?? false;
    if (late && !allowLate) {
      showMessage(context, 'La fecha venció y esta actividad no permite entregas tardías.', error: true);
      return;
    }
    final link = TextEditingController(text: existing?['linkUrl'] as String? ?? '');
    final comment = TextEditingController(text: existing?['comment'] as String? ?? '');
    final allowLinks = activity['allowStudentLinks'] as bool? ?? true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(late ? 'Registrar entrega tarde' : 'Entregar actividad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allowLinks)
                TextField(
                  controller: link,
                  decoration: const InputDecoration(labelText: 'Enlace de la entrega', prefixIcon: Icon(Icons.link)),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: comment,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Comentario'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => StorageMaintenanceService.show(context, feature: 'La subida de archivos de tareas'),
                icon: const Icon(Icons.attach_file),
                label: const Text('Adjuntar archivo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar entrega')),
        ],
      ),
    );
    if (saved != true) return;
    await FirebaseFirestore.instance.collection('activity_submissions').doc('${activityId}_${user.uid}').set({
      'activityId': activityId,
      'studentId': user.uid,
      'studentName': user.displayName,
      'classId': user.classId,
      'linkUrl': link.text.trim().isEmpty ? null : link.text.trim(),
      'comment': comment.text.trim(),
      'fileUrl': null,
      'isLate': late,
      'submittedAt': FieldValue.serverTimestamp(),
      'score': existing?['score'],
      'teacherComment': existing?['teacherComment'],
    }, SetOptions(merge: true));
    if (context.mounted) showMessage(context, late ? 'Entrega tarde registrada.' : 'Actividad entregada.');
  }
}

Future<void> _showCreateActivity(BuildContext context, AppUser user) async {
  final title = TextEditingController();
  final description = TextEditingController();
  final courseId = TextEditingController();
  final courseName = TextEditingController();
  final classId = TextEditingController(text: user.classId);
  final points = TextEditingController(text: '10');
  final linkLabel = TextEditingController();
  final linkUrl = TextEditingController();
  DateTime due = DateTime.now().add(const Duration(days: 1));
  int bimester = 1;
  bool allowLate = true;
  bool allowStudentLinks = true;
  bool allowStudentFiles = true;
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nueva actividad', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Título'), validator: (value) => (value?.trim().length ?? 0) < 3 ? 'Escribe un título.' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: description, maxLines: 4, decoration: const InputDecoration(labelText: 'Instrucciones'), validator: (value) => (value?.trim().length ?? 0) < 5 ? 'Escribe instrucciones.' : null),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextFormField(controller: courseId, decoration: const InputDecoration(labelText: 'ID del curso'), validator: (value) => (value?.trim().isEmpty ?? true) ? 'Requerido' : null)),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: courseName, decoration: const InputDecoration(labelText: 'Nombre del curso'), validator: (value) => (value?.trim().isEmpty ?? true) ? 'Requerido' : null)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextFormField(controller: classId, decoration: const InputDecoration(labelText: 'Grado/sección'))),
                    const SizedBox(width: 10),
                    SizedBox(width: 120, child: TextFormField(controller: points, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Puntos'))),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<int>(
                        initialValue: bimester,
                        decoration: const InputDecoration(labelText: 'Bimestre'),
                        items: [1, 2, 3, 4]
                            .map((value) => DropdownMenuItem(value: value, child: Text('Bimestre $value')))
                            .toList(),
                        onChanged: (value) => setState(() => bimester = value ?? 1),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(context: context, initialDate: due, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 730)));
                      if (date == null || !context.mounted) return;
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(due));
                      if (time == null) return;
                      setState(() => due = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text('Entrega: ${formatDateTime(due)}'),
                  ),
                  SwitchListTile(value: allowLate, onChanged: (value) => setState(() => allowLate = value), title: const Text('Permitir entregas tarde')),
                  SwitchListTile(value: allowStudentLinks, onChanged: (value) => setState(() => allowStudentLinks = value), title: const Text('Permitir entrega por enlaces')),
                  SwitchListTile(value: allowStudentFiles, onChanged: (value) => setState(() => allowStudentFiles = value), title: const Text('Mostrar opción de archivos'), subtitle: const Text('Mostrará aviso de nube en mantenimiento mientras Storage esté desactivado.')),
                  const Divider(),
                  Text('Recurso por enlace (opcional)', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: linkLabel, decoration: const InputDecoration(labelText: 'Etiqueta'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: linkUrl, decoration: const InputDecoration(labelText: 'URL'))),
                  ]),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(onPressed: () => StorageMaintenanceService.show(context, feature: 'La carga de archivos de la actividad'), icon: const Icon(Icons.attach_file), label: const Text('Agregar archivo')),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) Navigator.pop(context, true);
                      },
                      child: const Text('Publicar'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (saved != true) return;
  final resources = <Map<String, dynamic>>[];
  if (linkUrl.text.trim().isNotEmpty) {
    resources.add({'label': linkLabel.text.trim().isEmpty ? 'Recurso' : linkLabel.text.trim(), 'url': linkUrl.text.trim()});
  }
  final db = FirebaseFirestore.instance;
  final activity = db.collection('school_activities').doc();
  final maximum = double.tryParse(points.text) ?? 0;
  final batch = db.batch();
  batch.set(activity, {
    'title': title.text.trim(),
    'description': description.text.trim(),
    'courseId': courseId.text.trim(),
    'courseName': courseName.text.trim(),
    'classId': classId.text.trim(),
    'teacherId': user.uid,
    'teacherName': user.displayName,
    'dueDate': Timestamp.fromDate(due),
    'bimester': bimester,
    'points': maximum,
    'gradeItemId': maximum > 0 ? activity.id : null,
    'allowLate': allowLate,
    'allowStudentLinks': allowStudentLinks,
    'allowStudentFiles': allowStudentFiles,
    'resourceLinks': resources,
    'fileAttachments': <dynamic>[],
    'status': 'published',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  if (maximum > 0) {
    batch.set(db.collection('grade_items').doc(activity.id), {
      'courseId': courseId.text.trim(),
      'classId': classId.text.trim(),
      'bimester': bimester,
      'name': title.text.trim(),
      'description': description.text.trim(),
      'category': 'zone',
      'maxPoints': maximum,
      'teacherId': user.uid,
      'sourceType': 'activity',
      'sourceId': activity.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  if (context.mounted) showMessage(context, 'Actividad publicada correctamente.');
}
