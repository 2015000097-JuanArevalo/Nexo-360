import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/models/app_user.dart';
import '../../core/services/storage_maintenance_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/qr_payloads.dart';
import '../../core/widgets/common.dart';

class DiaryScreen extends StatefulWidget {
  final AppUser user;
  final DateTime? initialDate;
  final String? focusPeriodId;
  const DiaryScreen({
    super.key,
    required this.user,
    this.initialDate,
    this.focusPeriodId,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('timetable_periods').snapshots(),
      builder: (context, periodSnapshot) {
        if (!periodSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final periods = periodSnapshot.data!.docs.where((doc) {
          final data = doc.data();
          if (data['dayOfWeek'] != selectedDate.weekday) return false;
          if (widget.user.isTechnical) return true;
          if (widget.user.isTeacher) return data['teacherId'] == widget.user.uid;
          return data['classId'] == widget.user.classId;
        }).toList()
          ..sort((a, b) => (a.data()['startMinutes'] as int? ?? 0).compareTo(b.data()['startMinutes'] as int? ?? 0));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: 'Diario Pedagógico',
              description: 'Contenido visto, asistencia, tareas, observaciones, conducta, enlaces y evidencias de cada período.',
              action: OutlinedButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(formatDate(selectedDate)),
              ),
            ),
            const SizedBox(height: 14),
            if (widget.user.isTechnical) _MissingPeriodsBanner(date: selectedDate, periods: periods),
            if (periods.isEmpty)
              EmptyState(
                icon: Icons.event_busy,
                title: 'No hay períodos para ${weekdayName(selectedDate)}',
                message: widget.user.isTechnical
                    ? 'Crea los períodos desde el módulo Horario.'
                    : 'No tienes clases asignadas en este día.',
              )
            else
              ...periods.map((period) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DiaryPeriodCard(
                      date: selectedDate,
                      period: period,
                      user: widget.user,
                      initiallyExpanded: period.id == widget.focusPeriodId,
                    ),
                  )),
          ],
        );
      },
    );
  }
}

class _MissingPeriodsBanner extends StatelessWidget {
  final DateTime date;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> periods;
  const _MissingPeriodsBanner({required this.date, required this.periods});

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('pedagogical_diary').snapshots(),
      builder: (context, snapshot) {
        final completed = snapshot.data?.docs.map((doc) => doc.id).toSet() ?? <String>{};
        final now = DateTime.now();
        final missing = periods.where((period) {
          final endMinutes = period.data()['endMinutes'] as int? ?? 0;
          final end = DateTime(date.year, date.month, date.day, endMinutes ~/ 60, endMinutes % 60);
          return now.isAfter(end) && !completed.contains('${dateKey(date)}_${period.id}');
        }).length;
        if (missing == 0) return const SizedBox(height: 6);
        return Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text('$missing período(s) sin completar'),
            subtitle: const Text('Esta advertencia se actualiza en tiempo real mientras una cuenta técnica tiene abierta la aplicación.'),
          ),
        );
      },
    );
  }
}

class _DiaryPeriodCard extends StatelessWidget {
  final DateTime date;
  final QueryDocumentSnapshot<Map<String, dynamic>> period;
  final AppUser user;
  final bool initiallyExpanded;
  const _DiaryPeriodCard({
    required this.date,
    required this.period,
    required this.user,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final periodData = period.data();
    final diaryId = '${dateKey(date)}_${period.id}';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('pedagogical_diary').doc(diaryId).snapshots(),
      builder: (context, snapshot) {
        final diary = snapshot.data?.data();
        final canEdit = user.isTechnical || (user.isTeacher && periodData['teacherId'] == user.uid);
        return Card(
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: CircleAvatar(
              backgroundColor: diary == null ? Colors.orange.withValues(alpha: .15) : NexoColors.cyan.withValues(alpha: .15),
              child: Icon(diary == null ? Icons.pending_actions : Icons.check_circle_outline, color: diary == null ? Colors.orange : NexoColors.royalBlue),
            ),
            title: Text('${periodData['periodNumber'] ?? ''}. ${periodData['courseName'] ?? periodData['courseId'] ?? 'Curso'}'),
            subtitle: Text('${periodData['classId'] ?? ''} · ${periodData['teacherName'] ?? ''} · ${_minutes(periodData['startMinutes'])}–${_minutes(periodData['endMinutes'])}'),
            trailing: Chip(label: Text(diary == null ? 'Pendiente' : 'Completado')),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (diary == null)
                const Text('Este período todavía no ha sido registrado.')
              else ...[
                _Info(label: 'Qué se vio', value: diary['contentCovered']),
                _Info(label: 'Tarea del período', value: diary['homework']),
                _Info(label: 'Observaciones', value: diary['observations']),
                _Info(label: 'Enlace de apoyo', value: diary['resourceLink']),
                _Info(label: 'Pantalla interactiva', value: diary['interactiveBoardNote']),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (canEdit)
                    OutlinedButton.icon(
                      onPressed: () => _editDiary(context, diaryId, period, date, user, diary),
                      icon: const Icon(Icons.edit_note),
                      label: Text(diary == null ? 'Completar período' : 'Editar período'),
                    ),
                  if (canEdit)
                    FilledButton.icon(
                      onPressed: () => _attendanceDialog(context, diaryId, period, date, user),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Tomar asistencia'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _attendanceSummary(context, diaryId),
                    icon: const Icon(Icons.people_outline),
                    label: const Text('Ver asistencia'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _minutes(dynamic raw) {
    final value = raw as int? ?? 0;
    final hour = value ~/ 60;
    final minute = value % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class _Info extends StatelessWidget {
  final String label;
  final dynamic value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = value as String? ?? '';
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 155, child: Text(label, style: const TextStyle(color: NexoColors.muted))),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

Future<void> _editDiary(
  BuildContext context,
  String diaryId,
  QueryDocumentSnapshot<Map<String, dynamic>> period,
  DateTime date,
  AppUser user,
  Map<String, dynamic>? existing,
) async {
  final content = TextEditingController(text: existing?['contentCovered'] as String? ?? '');
  final homework = TextEditingController(text: existing?['homework'] as String? ?? '');
  final observations = TextEditingController(text: existing?['observations'] as String? ?? '');
  final link = TextEditingController(text: existing?['resourceLink'] as String? ?? '');
  final boardNote = TextEditingController(text: existing?['interactiveBoardNote'] as String? ?? '');
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740, maxHeight: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Registro del período', style: Theme.of(context).textTheme.headlineSmall),
              Text('${period.data()['courseName']} · ${formatDate(date)}'),
              const SizedBox(height: 16),
              TextField(controller: content, maxLines: 4, decoration: const InputDecoration(labelText: 'Qué se vio ese día')),
              const SizedBox(height: 12),
              TextField(controller: homework, maxLines: 3, decoration: const InputDecoration(labelText: 'Tareas dejadas en el período')),
              const SizedBox(height: 12),
              TextField(controller: observations, maxLines: 3, decoration: const InputDecoration(labelText: 'Observaciones')),
              const SizedBox(height: 12),
              TextField(controller: link, decoration: const InputDecoration(labelText: 'Enlace o presentación usada')),
              const SizedBox(height: 12),
              TextField(controller: boardNote, maxLines: 2, decoration: const InputDecoration(labelText: 'Nota o QR de pantalla interactiva')),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(onPressed: () => StorageMaintenanceService.show(context, feature: 'La subida de presentación o evidencia del período'), icon: const Icon(Icons.upload_file), label: const Text('Subir presentación')),
                OutlinedButton.icon(
                  onPressed: () async {
                    final raw = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (_) => const _InteractiveBoardQrScanner()),
                    );
                    if (raw == null || raw.trim().isEmpty || !context.mounted) return;
                    boardNote.text = raw.trim();
                    final uri = Uri.tryParse(raw.trim());
                    if (uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
                      link.text = raw.trim();
                    }
                    showMessage(context, 'QR de la pantalla guardado en el período.');
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Leer QR de pantalla'),
                ),
              ]),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar período')),
              ]),
            ],
          ),
        ),
      ),
    ),
  );
  if (saved != true) return;
  await FirebaseFirestore.instance.collection('pedagogical_diary').doc(diaryId).set({
    'dateKey': dateKey(date),
    'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
    'periodId': period.id,
    'periodNumber': period.data()['periodNumber'],
    'classId': period.data()['classId'],
    'courseId': period.data()['courseId'],
    'courseName': period.data()['courseName'],
    'teacherId': period.data()['teacherId'],
    'teacherName': period.data()['teacherName'],
    'contentCovered': content.text.trim(),
    'homework': homework.text.trim(),
    'observations': observations.text.trim(),
    'resourceLink': link.text.trim(),
    'interactiveBoardNote': boardNote.text.trim(),
    'fileAttachments': <dynamic>[],
    'completed': true,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': user.uid,
    if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  if (context.mounted) showMessage(context, 'Período guardado.');
}

Future<void> _attendanceDialog(
  BuildContext context,
  String diaryId,
  QueryDocumentSnapshot<Map<String, dynamic>> period,
  DateTime date,
  AppUser teacher,
) async {
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Asistencia · ${period.data()['courseName']}', style: Theme.of(context).textTheme.headlineSmall)),
                  FilledButton.icon(
                    onPressed: () async {
                      final payload = await Navigator.of(context).push<StudentQrPayload>(MaterialPageRoute(builder: (_) => const _AttendanceScanner()));
                      if (payload == null || !context.mounted) return;
                      final studentDocument = await FirebaseFirestore.instance.collection('users').doc(payload.uid).get();
                      if (!context.mounted) return;
                      final studentData = studentDocument.data();
                      final expectedClassId = period.data()['classId'] as String? ?? '';
                      if (!studentDocument.exists ||
                          studentData == null ||
                          studentData['accountType'] != 'student' ||
                          studentData['schoolCode'] != payload.schoolCode ||
                          studentData['classId'] != expectedClassId) {
                        showMessage(
                          context,
                          'El QR no corresponde a un estudiante activo de esta clase.',
                          error: true,
                        );
                        return;
                      }
                      await _markAttendance(
                        diaryId: diaryId,
                        studentId: payload.uid,
                        studentName: studentData['displayName'] as String? ?? payload.schoolCode,
                        classId: expectedClassId,
                        status: 'present',
                        teacher: teacher,
                        date: date,
                      );
                      if (context.mounted) showMessage(context, 'Asistencia por QR registrada.');
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Escanear QR'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Marca manualmente o escanea el QR permanente del estudiante. En inasistencias puedes justificar, llamar la atención y bajar puntos de Conducta.'),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').where('accountType', isEqualTo: 'student').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final students = snapshot.data!.docs.where((doc) => doc.data()['classId'] == period.data()['classId']).toList()
                      ..sort((a, b) => '${a.data()['displayName']}'.compareTo('${b.data()['displayName']}'));
                    if (students.isEmpty) return const Center(child: Text('No hay estudiantes en este grado/sección.'));
                    return ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) => _StudentAttendanceTile(
                        diaryId: diaryId,
                        student: students[index],
                        classId: period.data()['classId'] as String? ?? '',
                        teacher: teacher,
                        date: date,
                      ),
                    );
                  },
                ),
              ),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Terminar'))),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StudentAttendanceTile extends StatelessWidget {
  final String diaryId;
  final QueryDocumentSnapshot<Map<String, dynamic>> student;
  final String classId;
  final AppUser teacher;
  final DateTime date;
  const _StudentAttendanceTile({
    required this.diaryId,
    required this.student,
    required this.classId,
    required this.teacher,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceId = '${diaryId}_${student.id}';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('attendance_records').doc(attendanceId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final status = data?['status'] as String? ?? 'unmarked';
        return ListTile(
          leading: CircleAvatar(child: Text((student.data()['displayName'] as String? ?? 'E').substring(0, 1).toUpperCase())),
          title: Text(student.data()['displayName'] as String? ?? 'Estudiante'),
          subtitle: Text('${student.data()['schoolCode'] ?? ''}${data?['justification'] != null && '${data!['justification']}'.isNotEmpty ? ' · ${data['justification']}' : ''}'),
          trailing: Wrap(
            spacing: 5,
            children: [
              _StatusButton(
                label: 'Presente',
                selected: status == 'present',
                color: Colors.green,
                onPressed: () => _markAttendance(diaryId: diaryId, studentId: student.id, studentName: student.data()['displayName'] as String? ?? '', classId: classId, status: 'present', teacher: teacher, date: date),
              ),
              _StatusButton(
                label: 'Tarde',
                selected: status == 'late',
                color: Colors.orange,
                onPressed: () => _markAttendance(diaryId: diaryId, studentId: student.id, studentName: student.data()['displayName'] as String? ?? '', classId: classId, status: 'late', teacher: teacher, date: date),
              ),
              _StatusButton(
                label: 'Ausente',
                selected: status == 'absent',
                color: Colors.red,
                onPressed: () => _absenceDialog(context, diaryId, student, classId, teacher, date),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onPressed;
  const _StatusButton({required this.label, required this.selected, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? color.withValues(alpha: .16) : null,
          foregroundColor: color,
          side: BorderSide(color: color),
        ),
        child: Text(label),
      );
}

Future<void> _absenceDialog(
  BuildContext context,
  String diaryId,
  QueryDocumentSnapshot<Map<String, dynamic>> student,
  String classId,
  AppUser teacher,
  DateTime date,
) async {
  final justification = TextEditingController();
  final warning = TextEditingController();
  final points = TextEditingController(text: '0');
  bool excused = false;
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Inasistencia · ${student.data()['displayName']}'),
        content: SizedBox(
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(value: excused, onChanged: (value) => setState(() => excused = value), title: const Text('Falta justificada')),
              TextField(controller: justification, maxLines: 2, decoration: const InputDecoration(labelText: 'Justificación de la falta')),
              const SizedBox(height: 12),
              TextField(controller: warning, maxLines: 2, decoration: const InputDecoration(labelText: 'Llamado de atención u observación')),
              const SizedBox(height: 12),
              TextField(controller: points, keyboardType: const TextInputType.numberWithOptions(signed: true), decoration: const InputDecoration(labelText: 'Puntos a bajar en Conducta', helperText: 'Escribe un número positivo; se guardará como descuento.')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
      ),
    ),
  );
  if (saved != true) return;
  final deduction = (double.tryParse(points.text) ?? 0).abs();
  await _markAttendance(
    diaryId: diaryId,
    studentId: student.id,
    studentName: student.data()['displayName'] as String? ?? '',
    classId: classId,
    status: 'absent',
    teacher: teacher,
    date: date,
    excused: excused,
    justification: justification.text.trim(),
    warning: warning.text.trim(),
    conductDeduction: deduction,
  );
  if (deduction > 0 || warning.text.trim().isNotEmpty) {
    await FirebaseFirestore.instance.collection('conduct_events').add({
      'studentId': student.id,
      'studentName': student.data()['displayName'],
      'classId': classId,
      'source': 'attendance',
      'diaryId': diaryId,
      'description': warning.text.trim().isEmpty ? 'Descuento por inasistencia' : warning.text.trim(),
      'pointsDelta': -deduction,
      'createdBy': teacher.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

Future<void> _markAttendance({
  required String diaryId,
  required String studentId,
  required String studentName,
  required String classId,
  required String status,
  required AppUser teacher,
  required DateTime date,
  bool excused = false,
  String justification = '',
  String warning = '',
  double conductDeduction = 0,
}) async {
  await FirebaseFirestore.instance.collection('attendance_records').doc('${diaryId}_$studentId').set({
    'diaryId': diaryId,
    'studentId': studentId,
    'studentName': studentName,
    'classId': classId,
    'date': Timestamp.fromDate(date),
    'status': status,
    'excused': excused,
    'justification': justification,
    'warning': warning,
    'conductDeduction': conductDeduction,
    'recordedBy': teacher.uid,
    'recordedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  await FirebaseFirestore.instance.collection('users').doc(studentId).set({
    'lastAttendanceAt': FieldValue.serverTimestamp(),
    'lastAttendanceDiaryId': diaryId,
    'lastAttendanceStatus': status,
  }, SetOptions(merge: true));
}

void _attendanceSummary(BuildContext context, String diaryId) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Resumen de asistencia'),
      content: SizedBox(
        width: 600,
        height: 450,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('attendance_records').where('diaryId', isEqualTo: diaryId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('No se ha tomado asistencia.'));
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data();
                return ListTile(
                  leading: Icon(switch (data['status']) {'present' => Icons.check_circle, 'late' => Icons.schedule, _ => Icons.cancel}, color: switch (data['status']) {'present' => Colors.green, 'late' => Colors.orange, _ => Colors.red}),
                  title: Text(data['studentName'] as String? ?? data['studentId'] as String? ?? ''),
                  subtitle: Text('${data['status']}${data['excused'] == true ? ' · Justificada' : ''}'),
                );
              },
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
    ),
  );
}


class _InteractiveBoardQrScanner extends StatefulWidget {
  const _InteractiveBoardQrScanner();

  @override
  State<_InteractiveBoardQrScanner> createState() => _InteractiveBoardQrScannerState();
}

class _InteractiveBoardQrScannerState extends State<_InteractiveBoardQrScanner> {
  final manualController = TextEditingController();
  bool handled = false;

  @override
  void dispose() {
    manualController.dispose();
    super.dispose();
  }

  void finish(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty || handled) return;
    handled = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final manualMode = defaultTargetPlatform == TargetPlatform.windows;
    return Scaffold(
      appBar: AppBar(title: const Text('Leer QR de pantalla interactiva')),
      body: manualMode
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.qr_code_2, size: 72),
                      const SizedBox(height: 18),
                      const Text(
                        'En Windows ingresa el contenido o enlace mostrado por el QR. La cámara se utiliza directamente en Android.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: manualController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Contenido o enlace del QR',
                          prefixIcon: Icon(Icons.link),
                        ),
                        onSubmitted: finish,
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => finish(manualController.text),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar contenido'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : MobileScanner(
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  if (barcode.rawValue != null) {
                    finish(barcode.rawValue);
                    return;
                  }
                }
              },
            ),
    );
  }
}

class _AttendanceScanner extends StatefulWidget {
  const _AttendanceScanner();

  @override
  State<_AttendanceScanner> createState() => _AttendanceScannerState();
}

class _AttendanceScannerState extends State<_AttendanceScanner> {
  bool handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR del estudiante')),
      body: defaultTargetPlatform == TargetPlatform.windows
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'La lectura por cámara está disponible en Android. En Windows utiliza el listado manual de estudiantes.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : MobileScanner(
              onDetect: (capture) {
                if (handled) return;
                for (final barcode in capture.barcodes) {
                  final raw = barcode.rawValue;
                  if (raw == null) continue;
                  final payload = StudentQrPayload.tryParse(raw);
                  if (payload != null) {
                    handled = true;
                    Navigator.pop(context, payload);
                    return;
                  }
                }
              },
            ),
    );
  }
}
