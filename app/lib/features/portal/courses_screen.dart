import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/services/storage_maintenance_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class CoursesScreen extends StatelessWidget {
  final AppUser user;
  const CoursesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return FirestoreError(snapshot.error);
        final courses = snapshot.data!.docs.where((doc) => _visible(doc.data(), user)).toList()
          ..sort((a, b) => '${a.data()['name']}'.compareTo('${b.data()['name']}'));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Cursos y clases',
              description: user.isTechnical
                  ? 'Crea cursos y asigna docente, grado y sección.'
                  : 'Consulta los cursos que tienes disponibles y su carpeta de materiales.',
              action: user.isTechnical
                  ? FilledButton.icon(
                      onPressed: () => _courseDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear curso'),
                    )
                  : null,
            ),
            const SizedBox(height: 18),
            if (courses.isEmpty)
              const EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No hay cursos asignados',
                message: 'El personal técnico debe crear y asignar los cursos.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 800 ? 2 : 1;
                  final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: courses
                        .map((doc) => SizedBox(
                              width: width,
                              child: _CourseCard(doc: doc, user: user),
                            ))
                        .toList(),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  bool _visible(Map<String, dynamic> data, AppUser user) {
    if (user.isTechnical) return true;
    if (user.isTeacher) return data['teacherId'] == user.uid || user.courseIds.contains(data['code']);
    return data['classId'] == user.classId || user.courseIds.contains(data['code']);
  }
}

class _CourseCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final AppUser user;
  const _CourseCard({required this.doc, required this.user});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0x1A0E6EC7),
                  child: Icon(Icons.menu_book_outlined, color: NexoColors.royalBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] as String? ?? 'Curso', style: Theme.of(context).textTheme.titleMedium),
                      Text('${data['classId'] ?? 'Sin clase'} · ${data['teacherName'] ?? 'Docente por asignar'}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(data['description'] as String? ?? ''),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showMaterials(context, doc, user),
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Carpeta del curso'),
            ),
            if (user.isTechnical) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _courseDialog(context, existing: doc),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar asignación'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMaterials(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> course, AppUser user) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeading(
                  title: 'Carpeta · ${course.data()['name']}',
                  description: 'Material de apoyo organizado por curso.',
                  action: user.canPublishSchool
                      ? FilledButton.icon(
                          onPressed: () => _materialDialog(context, course.id, user),
                          icon: const Icon(Icons.add_link),
                          label: const Text('Agregar'),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('course_materials')
                        .where('courseId', isEqualTo: course.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return const Center(child: Text('No hay materiales publicados.'));
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          return ListTile(
                            leading: Icon(data['type'] == 'file' ? Icons.insert_drive_file_outlined : Icons.link),
                            title: Text(data['title'] as String? ?? 'Material'),
                            subtitle: Text(data['url'] as String? ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _materialDialog(BuildContext context, String courseId, AppUser user) async {
  final title = TextEditingController();
  final url = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Agregar material'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(controller: url, decoration: const InputDecoration(labelText: 'Enlace')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => StorageMaintenanceService.show(context, feature: 'La subida de material del curso'),
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir archivo'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar enlace')),
      ],
    ),
  );
  if (saved != true || title.text.trim().isEmpty || url.text.trim().isEmpty) return;
  await FirebaseFirestore.instance.collection('course_materials').add({
    'courseId': courseId,
    'title': title.text.trim(),
    'url': url.text.trim(),
    'type': 'link',
    'authorId': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> _courseDialog(
  BuildContext context, {
  QueryDocumentSnapshot<Map<String, dynamic>>? existing,
}) async {
  final data = existing?.data() ?? <String, dynamic>{};
  final code = TextEditingController(text: data['code'] as String? ?? '');
  final name = TextEditingController(text: data['name'] as String? ?? '');
  final description = TextEditingController(text: data['description'] as String? ?? '');
  final classId = TextEditingController(text: data['classId'] as String? ?? '');
  final teacherId = TextEditingController(text: data['teacherId'] as String? ?? '');
  final teacherName = TextEditingController(text: data['teacherName'] as String? ?? '');
  final conductCourse = ValueNotifier<bool>(data['isConductCourse'] as bool? ?? false);
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existing == null ? 'Crear curso' : 'Editar curso'),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: code, decoration: const InputDecoration(labelText: 'Código único del curso')),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre del curso')),
              const SizedBox(height: 12),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Descripción')),
              const SizedBox(height: 12),
              TextField(controller: classId, decoration: const InputDecoration(labelText: 'Grado y sección')),
              const SizedBox(height: 12),
              TextField(controller: teacherId, decoration: const InputDecoration(labelText: 'UID del docente')),
              const SizedBox(height: 12),
              TextField(controller: teacherName, decoration: const InputDecoration(labelText: 'Nombre del docente')),
              ValueListenableBuilder<bool>(
                valueListenable: conductCourse,
                builder: (context, value, _) => SwitchListTile(
                  value: value,
                  onChanged: (next) => conductCourse.value = next,
                  title: const Text('Este es el curso de Conducta'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
      ],
    ),
  );
  if (saved != true || code.text.trim().isEmpty || name.text.trim().isEmpty) return;
  final payload = {
    'code': code.text.trim(),
    'name': name.text.trim(),
    'description': description.text.trim(),
    'classId': classId.text.trim(),
    'teacherId': teacherId.text.trim(),
    'teacherName': teacherName.text.trim(),
    'isConductCourse': conductCourse.value,
    'updatedAt': FieldValue.serverTimestamp(),
    if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
  };
  if (existing == null) {
    await FirebaseFirestore.instance.collection('courses').doc(code.text.trim()).set(payload);
  } else {
    await existing.reference.set(payload, SetOptions(merge: true));
  }
  if (context.mounted) showMessage(context, 'Curso guardado.');
}
