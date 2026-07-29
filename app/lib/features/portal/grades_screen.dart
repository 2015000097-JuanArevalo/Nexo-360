import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class GradesScreen extends StatefulWidget {
  final AppUser user;
  const GradesScreen({super.key, required this.user});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int bimester = 1;
  String? courseId;

  static const weights = {1: 20.0, 2: 30.0, 3: 20.0, 4: 30.0};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, courseSnapshot) {
        if (!courseSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final courses = courseSnapshot.data!.docs.where((doc) {
          final data = doc.data();
          if (widget.user.isTechnical) return true;
          if (widget.user.isTeacher) return data['teacherId'] == widget.user.uid || widget.user.courseIds.contains(doc.id);
          return data['classId'] == widget.user.classId || widget.user.courseIds.contains(doc.id);
        }).toList();
        courseId ??= courses.isEmpty ? null : courses.first.id;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Notas',
              description: 'Zona, parciales y examen final por bimestre. Pesos acumulados: 20%, 30%, 20% y 30%.',
              action: widget.user.canPublishSchool && courseId != null
                  ? FilledButton.icon(
                      onPressed: () => _createGradeItem(context, widget.user, courseId!, bimester),
                      icon: const Icon(Icons.add_chart),
                      label: const Text('Crear evaluación'),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: courseId,
                    decoration: const InputDecoration(labelText: 'Curso'),
                    items: courses.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc.data()['name'] as String? ?? doc.id))).toList(),
                    onChanged: (value) => setState(() => courseId = value),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<int>(
                    initialValue: bimester,
                    decoration: const InputDecoration(labelText: 'Bimestre'),
                    items: [1, 2, 3, 4].map((value) => DropdownMenuItem(value: value, child: Text('Bimestre $value (${weights[value]!.toInt()}%)'))).toList(),
                    onChanged: (value) => setState(() => bimester = value ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (courseId == null)
              const EmptyState(icon: Icons.grade_outlined, title: 'Sin cursos', message: 'El personal técnico debe asignar cursos.')
            else if (widget.user.isStudent)
              _StudentGrades(user: widget.user, courseId: courseId!, bimester: bimester, weight: weights[bimester]!)
            else
              _TeacherGrades(user: widget.user, courseId: courseId!, bimester: bimester, weight: weights[bimester]!),
          ],
        );
      },
    );
  }
}

class _StudentGrades extends StatelessWidget {
  final AppUser user;
  final String courseId;
  final int bimester;
  final double weight;
  const _StudentGrades({required this.user, required this.courseId, required this.bimester, required this.weight});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('grade_items').snapshots(),
      builder: (context, itemSnapshot) {
        if (!itemSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = itemSnapshot.data!.docs.where((doc) => doc.data()['courseId'] == courseId && doc.data()['bimester'] == bimester).toList();
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('grade_scores').where('studentId', isEqualTo: user.uid).snapshots(),
          builder: (context, scoreSnapshot) {
            final scores = <String, double>{};
            for (final doc in scoreSnapshot.data?.docs ?? const []) {
              scores[doc.data()['itemId'] as String? ?? ''] = (doc.data()['score'] as num?)?.toDouble() ?? 0;
            }
            final byCategory = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
            for (final item in items) {
              byCategory.putIfAbsent(item.data()['category'] as String? ?? 'zone', () => []).add(item);
            }
            final earned = items.fold<double>(0, (sum, item) => sum + (scores[item.id] ?? 0));
            final max = items.fold<double>(0, (sum, item) => sum + ((item.data()['maxPoints'] as num?)?.toDouble() ?? 0));
            final percentage = max == 0 ? 0.0 : earned / max * 100;
            final accumulated = percentage / 100 * weight;
            return Column(
              children: [
                _GradeSummary(earned: earned, max: max, percentage: percentage, accumulated: accumulated, weight: weight),
                const SizedBox(height: 14),
                if (items.isEmpty)
                  const EmptyState(icon: Icons.grade_outlined, title: 'Sin evaluaciones', message: 'El docente aún no ha creado evaluaciones para este bimestre.')
                else
                  ...byCategory.entries.map((entry) => _CategoryCard(category: entry.key, items: entry.value, scores: scores)),
                const SizedBox(height: 14),
                _AnnualCourseAverage(user: user, courseId: courseId),
                const SizedBox(height: 14),
                _OverallStudentAverage(user: user),
              ],
            );
          },
        );
      },
    );
  }
}

class _GradeSummary extends StatelessWidget {
  final double earned;
  final double max;
  final double percentage;
  final double accumulated;
  final double weight;
  const _GradeSummary({required this.earned, required this.max, required this.percentage, required this.accumulated, required this.weight});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(builder: (context, constraints) {
            return Wrap(
              spacing: 30,
              runSpacing: 14,
              children: [
                _Metric('Puntos', '${earned.toStringAsFixed(1)} / ${max.toStringAsFixed(1)}'),
                _Metric('Promedio del bimestre', '${percentage.toStringAsFixed(1)}%'),
                _Metric('Peso del bimestre', '${weight.toStringAsFixed(0)}%'),
                _Metric('Aporte al promedio anual', '${accumulated.toStringAsFixed(2)} pts'),
              ],
            );
          }),
        ),
      );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: NexoColors.royalBlue)), Text(label, style: const TextStyle(color: NexoColors.muted))]),
      );
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final Map<String, double> scores;
  const _CategoryCard({required this.category, required this.items, required this.scores});

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {'partial' => 'Parciales', 'final' => 'Examen final', _ => 'Zona'};
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(label),
        children: items.map((item) {
          final data = item.data();
          return ListTile(
            leading: const Icon(Icons.task_alt_outlined),
            title: Text(data['name'] as String? ?? 'Evaluación'),
            subtitle: Text(data['description'] as String? ?? ''),
            trailing: Text('${(scores[item.id] ?? 0).toStringAsFixed(1)} / ${data['maxPoints'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }
}

class _TeacherGrades extends StatelessWidget {
  final AppUser user;
  final String courseId;
  final int bimester;
  final double weight;
  const _TeacherGrades({required this.user, required this.courseId, required this.bimester, required this.weight});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('grade_items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!.docs.where((doc) => doc.data()['courseId'] == courseId && doc.data()['bimester'] == bimester).toList();
        if (items.isEmpty) return const EmptyState(icon: Icons.add_chart, title: 'Sin evaluaciones', message: 'Crea la primera evaluación de este bimestre.');
        return Column(
          children: [
            ...items.map((item) {
              final data = item.data();
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.grade_outlined)),
                  title: Text(data['name'] as String? ?? 'Evaluación'),
                  subtitle: Text('${_category(data['category'])} · ${data['maxPoints']} puntos'),
                  trailing: FilledButton.tonalIcon(
                    onPressed: () => _gradeStudents(context, item, user),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Calificar'),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            _ClassAverage(user: user, courseId: courseId, bimester: bimester),
          ],
        );
      },
    );
  }

  static String _category(dynamic value) => switch (value) {'partial' => 'Parcial', 'final' => 'Examen final', _ => 'Zona'};
}

Future<void> _createGradeItem(BuildContext context, AppUser user, String courseId, int bimester) async {
  final name = TextEditingController();
  final description = TextEditingController();
  final maxPoints = TextEditingController(text: '10');
  String category = 'zone';
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Crear evaluación'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre de la evaluación')),
              const SizedBox(height: 12),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Descripción')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Estructura'),
                items: const [DropdownMenuItem(value: 'zone', child: Text('Zona')), DropdownMenuItem(value: 'partial', child: Text('Parcial')), DropdownMenuItem(value: 'final', child: Text('Examen final'))],
                onChanged: (value) => setState(() => category = value ?? 'zone'),
              ),
              const SizedBox(height: 12),
              TextField(controller: maxPoints, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Punteo máximo')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Crear'))],
      ),
    ),
  );
  if (saved != true || name.text.trim().isEmpty) return;
  final courseDocument = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
  final classId = courseDocument.data()?['classId'] as String? ?? '';
  await FirebaseFirestore.instance.collection('grade_items').add({
    'courseId': courseId,
    'classId': classId,
    'bimester': bimester,
    'name': name.text.trim(),
    'description': description.text.trim(),
    'category': category,
    'maxPoints': double.tryParse(maxPoints.text) ?? 0,
    'teacherId': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
  if (context.mounted) showMessage(context, 'Evaluación creada.');
}

void _gradeStudents(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> item, AppUser teacher) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Calificar · ${item.data()['name']}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').where('accountType', isEqualTo: 'student').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final classId = item.data()['classId'] as String? ?? '';
                    final students = snapshot.data!.docs
                        .where((doc) => classId.isEmpty || doc.data()['classId'] == classId)
                        .toList()
                      ..sort((a, b) => '${a.data()['displayName']}'.compareTo('${b.data()['displayName']}'));
                    return ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) => _ScoreEditor(item: item, student: students[index], teacher: teacher),
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

class _ScoreEditor extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> item;
  final QueryDocumentSnapshot<Map<String, dynamic>> student;
  final AppUser teacher;
  const _ScoreEditor({required this.item, required this.student, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final id = '${item.id}_${student.id}';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('grade_scores').doc(id).snapshots(),
      builder: (context, snapshot) {
        final controller = TextEditingController(text: snapshot.data?.data()?['score']?.toString() ?? '');
        return ListTile(
          title: Text(student.data()['displayName'] as String? ?? 'Estudiante'),
          subtitle: Text(student.data()['classId'] as String? ?? ''),
          trailing: SizedBox(
            width: 180,
            child: Row(children: [
              Expanded(child: TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'de ${item.data()['maxPoints']}'))),
              IconButton(
                tooltip: 'Guardar nota',
                onPressed: () async {
                  final score = double.tryParse(controller.text);
                  final max = (item.data()['maxPoints'] as num?)?.toDouble() ?? 0;
                  if (score == null || score < 0 || score > max) {
                    showMessage(context, 'La nota debe estar entre 0 y $max.', error: true);
                    return;
                  }
                  await FirebaseFirestore.instance.collection('grade_scores').doc(id).set({
                    'itemId': item.id,
                    'courseId': item.data()['courseId'],
                    'bimester': item.data()['bimester'],
                    'studentId': student.id,
                    'studentName': student.data()['displayName'],
                    'classId': student.data()['classId'],
                    'score': score,
                    'maxPoints': max,
                    'teacherId': teacher.uid,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) showMessage(context, 'Nota guardada.');
                },
                icon: const Icon(Icons.save_outlined),
              ),
            ]),
          ),
        );
      },
    );
  }
}


class _AnnualCourseAverage extends StatelessWidget {
  final AppUser user;
  final String courseId;
  const _AnnualCourseAverage({required this.user, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('grade_scores')
          .where('studentId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = (snapshot.data?.docs ?? const [])
            .where((doc) => doc.data()['courseId'] == courseId)
            .toList();
        final periods = <int, List<Map<String, dynamic>>>{};
        for (final doc in docs) {
          final data = doc.data();
          final period = data['bimester'] as int? ?? 1;
          periods.putIfAbsent(period, () => []).add(data);
        }
        const weights = <int, double>{1: 20, 2: 30, 3: 20, 4: 30};
        var annual = 0.0;
        final details = <String>[];
        for (var period = 1; period <= 4; period++) {
          final scores = periods[period] ?? const <Map<String, dynamic>>[];
          final earned = scores.fold<double>(0, (sum, data) => sum + ((data['score'] as num?)?.toDouble() ?? 0));
          final maximum = scores.fold<double>(0, (sum, data) => sum + ((data['maxPoints'] as num?)?.toDouble() ?? 0));
          final percentage = maximum == 0 ? 0.0 : earned / maximum * 100;
          final contribution = percentage / 100 * weights[period]!;
          annual += contribution;
          details.add('B$period: ${percentage.toStringAsFixed(1)}% → ${contribution.toStringAsFixed(2)} pts');
        }
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1A0E6EC7),
              child: Icon(Icons.timeline_outlined, color: NexoColors.royalBlue),
            ),
            title: const Text('Promedio anual ponderado del curso'),
            subtitle: Text(details.join(' · ')),
            trailing: Text('${annual.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineSmall),
          ),
        );
      },
    );
  }
}

class _ClassAverage extends StatelessWidget {
  final AppUser user;
  final String courseId;
  final int bimester;
  const _ClassAverage({required this.user, required this.courseId, required this.bimester});

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('grade_scores');
    if (user.isTeacher) query = query.where('teacherId', isEqualTo: user.uid);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final docs = (snapshot.data?.docs ?? const []).where((doc) {
          final data = doc.data();
          return data['courseId'] == courseId && data['bimester'] == bimester;
        }).toList();
        final byStudent = <String, List<Map<String, dynamic>>>{};
        for (final doc in docs) {
          final data = doc.data();
          byStudent.putIfAbsent('${data['studentId'] ?? ''}', () => []).add(data);
        }
        final studentAverages = byStudent.values.map((scores) {
          final earned = scores.fold<double>(0, (sum, data) => sum + ((data['score'] as num?)?.toDouble() ?? 0));
          final maximum = scores.fold<double>(0, (sum, data) => sum + ((data['maxPoints'] as num?)?.toDouble() ?? 0));
          return maximum == 0 ? 0.0 : earned / maximum * 100;
        }).toList();
        final average = studentAverages.isEmpty
            ? 0.0
            : studentAverages.reduce((a, b) => a + b) / studentAverages.length;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1AD4526B),
              child: Icon(Icons.groups_outlined, color: NexoColors.coral),
            ),
            title: Text('Promedio general del aula · Bimestre $bimester'),
            subtitle: Text('${studentAverages.length} estudiante(s) con notas'),
            trailing: Text('${average.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineSmall),
          ),
        );
      },
    );
  }
}

class _OverallStudentAverage extends StatelessWidget {
  final AppUser user;
  const _OverallStudentAverage({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('grade_scores').where('studentId', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        final byCourse = <String, List<Map<String, dynamic>>>{};
        for (final doc in docs) {
          final data = doc.data();
          byCourse.putIfAbsent(data['courseId'] as String? ?? '', () => []).add(data);
        }
        const weights = <int, double>{1: 20, 2: 30, 3: 20, 4: 30};
        final annualCourseAverages = byCourse.values.map((scores) {
          var annual = 0.0;
          for (var period = 1; period <= 4; period++) {
            final periodScores = scores.where((data) => (data['bimester'] as int? ?? 1) == period).toList();
            final earned = periodScores.fold<double>(0, (sum, data) => sum + ((data['score'] as num?)?.toDouble() ?? 0));
            final maximum = periodScores.fold<double>(0, (sum, data) => sum + ((data['maxPoints'] as num?)?.toDouble() ?? 0));
            final percentage = maximum == 0 ? 0.0 : earned / maximum * 100;
            annual += percentage / 100 * weights[period]!;
          }
          return annual;
        }).toList();
        final average = annualCourseAverages.isEmpty
            ? 0.0
            : annualCourseAverages.reduce((a, b) => a + b) / annualCourseAverages.length;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0x1A5E109E), child: Icon(Icons.analytics_outlined, color: NexoColors.violet)),
            title: const Text('Promedio general del estudiante'),
            subtitle: Text('${byCourse.length} curso(s) con calificaciones'),
            trailing: Text('${average.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineSmall),
          ),
        );
      },
    );
  }
}
