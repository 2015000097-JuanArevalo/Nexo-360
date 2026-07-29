import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import 'diary_screen.dart';

class TimetableScreen extends StatefulWidget {
  final AppUser user;
  const TimetableScreen({super.key, required this.user});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Horario',
          description: 'Horario semanal de clases y calendario completo de actividades, incluidas las vencidas.',
          action: widget.user.isTechnical
              ? FilledButton.icon(
                  onPressed: () => _periodDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear período'),
                )
              : null,
        ),
        const SizedBox(height: 14),
        TabBar(
          controller: controller,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_view_week), text: 'Horario semanal'),
            Tab(icon: Icon(Icons.event_note), text: 'Todas las actividades'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 720,
          child: TabBarView(
            controller: controller,
            children: [
              _WeeklyTimetable(user: widget.user),
              _ActivityTimeline(user: widget.user),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyTimetable extends StatelessWidget {
  final AppUser user;
  const _WeeklyTimetable({required this.user});

  static const days = <int, String>{
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('timetable_periods').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return FirestoreError(snapshot.error);
        final docs = snapshot.data!.docs.where((doc) => _visible(doc.data(), user)).toList()
          ..sort((a, b) {
            final day = (a.data()['dayOfWeek'] as int? ?? 1).compareTo(b.data()['dayOfWeek'] as int? ?? 1);
            if (day != 0) return day;
            return (a.data()['startMinutes'] as int? ?? 0).compareTo(b.data()['startMinutes'] as int? ?? 0);
          });
        return ListView(
          children: days.entries.map((day) {
            final periods = docs.where((doc) => doc.data()['dayOfWeek'] == day.key).toList();
            if (periods.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: NexoColors.royalBlue)),
                  const SizedBox(height: 8),
                  ...periods.map((period) => _PeriodTile(period: period, user: user)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  bool _visible(Map<String, dynamic> data, AppUser user) {
    if (user.isTechnical) return true;
    if (user.isTeacher) return data['teacherId'] == user.uid;
    return data['classId'] == user.classId;
  }
}

class _PeriodTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> period;
  final AppUser user;
  const _PeriodTile({required this.period, required this.user});

  @override
  Widget build(BuildContext context) {
    final data = period.data();
    final start = data['startMinutes'] as int? ?? 0;
    final end = data['endMinutes'] as int? ?? 0;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: NexoColors.cyan.withValues(alpha: .13),
          child: Text('${data['periodNumber'] ?? ''}', style: const TextStyle(color: NexoColors.royalBlue, fontWeight: FontWeight.bold)),
        ),
        title: Text(data['courseName'] as String? ?? data['courseId'] as String? ?? 'Curso'),
        subtitle: Text('${_minutes(start)} – ${_minutes(end)} · ${data['classId'] ?? ''} · ${data['teacherName'] ?? ''}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Abrir diario de este día',
              onPressed: () {
                final now = DateTime.now();
                final target = now.add(Duration(days: (data['dayOfWeek'] as int? ?? 1) - now.weekday));
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Diario Pedagógico')),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: DiaryScreen(
                            user: user,
                            initialDate: target,
                            focusPeriodId: period.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_outlined),
            ),
            if (user.isTechnical)
              IconButton(
                tooltip: 'Editar período',
                onPressed: () => _periodDialog(context, existing: period),
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
      ),
    );
  }

  static String _minutes(int value) {
    final hour = value ~/ 60;
    final minute = value % 60;
    final suffix = hour >= 12 ? 'p. m.' : 'a. m.';
    final display = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return '$display:${minute.toString().padLeft(2, '0')} $suffix';
  }
}

class _ActivityTimeline extends StatelessWidget {
  final AppUser user;
  const _ActivityTimeline({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('school_activities').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          if (user.isTechnical) return true;
          if (user.isTeacher) return data['teacherId'] == user.uid || user.courseIds.contains(data['courseId']);
          return data['classId'] == user.classId || user.courseIds.contains(data['courseId']);
        }).toList()
          ..sort((a, b) => asDate(a.data()['dueDate']).compareTo(asDate(b.data()['dueDate'])));
        if (docs.isEmpty) return const EmptyState(icon: Icons.event_busy, title: 'Sin actividades', message: 'No hay actividades para mostrar.');
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final due = asDate(data['dueDate']);
            final late = DateTime.now().isAfter(due);
            return Card(
              child: ListTile(
                leading: Icon(late ? Icons.history : Icons.event_available, color: late ? Colors.red : NexoColors.royalBlue),
                title: Text(data['title'] as String? ?? 'Actividad'),
                subtitle: Text('${data['courseName'] ?? ''} · ${formatDateTime(due)}'),
                trailing: Chip(label: Text(late ? 'Vencida' : 'Pendiente')),
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> _periodDialog(BuildContext context, {QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
  final data = existing?.data() ?? <String, dynamic>{};
  int day = data['dayOfWeek'] as int? ?? 1;
  final periodNumber = TextEditingController(text: '${data['periodNumber'] ?? 1}');
  final start = TextEditingController(text: '${data['startMinutes'] ?? 420}');
  final end = TextEditingController(text: '${data['endMinutes'] ?? 465}');
  final classId = TextEditingController(text: data['classId'] as String? ?? '');
  final courseId = TextEditingController(text: data['courseId'] as String? ?? '');
  final courseName = TextEditingController(text: data['courseName'] as String? ?? '');
  final teacherId = TextEditingController(text: data['teacherId'] as String? ?? '');
  final teacherName = TextEditingController(text: data['teacherName'] as String? ?? '');
  final room = TextEditingController(text: data['room'] as String? ?? '');
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'Crear período' : 'Editar período'),
        content: SizedBox(
          width: 660,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  initialValue: day,
                  decoration: const InputDecoration(labelText: 'Día'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Lunes')),
                    DropdownMenuItem(value: 2, child: Text('Martes')),
                    DropdownMenuItem(value: 3, child: Text('Miércoles')),
                    DropdownMenuItem(value: 4, child: Text('Jueves')),
                    DropdownMenuItem(value: 5, child: Text('Viernes')),
                    DropdownMenuItem(value: 6, child: Text('Sábado')),
                  ],
                  onChanged: (value) => setState(() => day = value ?? 1),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: periodNumber, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Número de período'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: start, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Inicio en minutos (7:00 = 420)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: end, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fin en minutos'))),
                ]),
                const SizedBox(height: 10),
                TextField(controller: classId, decoration: const InputDecoration(labelText: 'Grado/sección')),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: TextField(controller: courseId, decoration: const InputDecoration(labelText: 'ID curso'))), const SizedBox(width: 10), Expanded(child: TextField(controller: courseName, decoration: const InputDecoration(labelText: 'Nombre curso')))]),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: TextField(controller: teacherId, decoration: const InputDecoration(labelText: 'UID docente'))), const SizedBox(width: 10), Expanded(child: TextField(controller: teacherName, decoration: const InputDecoration(labelText: 'Nombre docente')))]),
                const SizedBox(height: 10),
                TextField(controller: room, decoration: const InputDecoration(labelText: 'Aula')),
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
    'dayOfWeek': day,
    'periodNumber': int.tryParse(periodNumber.text) ?? 1,
    'startMinutes': int.tryParse(start.text) ?? 420,
    'endMinutes': int.tryParse(end.text) ?? 465,
    'classId': classId.text.trim(),
    'courseId': courseId.text.trim(),
    'courseName': courseName.text.trim(),
    'teacherId': teacherId.text.trim(),
    'teacherName': teacherName.text.trim(),
    'room': room.text.trim(),
    'active': true,
    'updatedAt': FieldValue.serverTimestamp(),
    if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
  };
  if (existing == null) {
    await FirebaseFirestore.instance.collection('timetable_periods').add(payload);
  } else {
    await existing.reference.set(payload, SetOptions(merge: true));
  }
  if (context.mounted) showMessage(context, 'Período guardado.');
}
