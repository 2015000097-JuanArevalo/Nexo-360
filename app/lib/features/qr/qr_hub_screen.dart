import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/qr_payloads.dart';
import '../../core/widgets/common.dart';

class QrHubScreen extends StatelessWidget {
  final AppUser user;
  const QrHubScreen({super.key, required this.user});

  void open(BuildContext context, String title, Widget child) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: child)),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'QR',
          description: 'QR permanente del estudiante, permisos individuales y validación segura.',
        ),
        const SizedBox(height: 18),
        if (user.isStudent) ...[
          ModuleCard(
            icon: Icons.badge_outlined,
            title: 'Mi QR permanente',
            description: 'Identificador único para asistencia y consulta del registro escolar.',
            color: NexoColors.cyan,
            onTap: () => open(context, 'Mi QR permanente', StudentPermanentQrScreen(user: user)),
          ),
          const SizedBox(height: 12),
          ModuleCard(
            icon: Icons.verified_user_outlined,
            title: 'Mis permisos',
            description: 'Consulta todos tus permisos y muestra el QR propio de cada autorización.',
            color: NexoColors.violet,
            onTap: () => open(context, 'Mis permisos', PermissionListScreen(user: user)),
          ),
        ],
        if (user.isTeacher || user.isTechnical || user.isOrganizer) ...[
          ModuleCard(
            icon: Icons.add_task_outlined,
            title: user.isTechnical ? 'Crear permiso' : 'Solicitar permiso',
            description: user.isTechnical
                ? 'Crea autorizaciones directamente para uno o varios estudiantes.'
                : 'Envía la solicitud para aprobación del personal técnico.',
            color: NexoColors.violet,
            onTap: () => _permissionForm(context, user),
          ),
          const SizedBox(height: 12),
        ],
        if (user.canValidateQr) ...[
          ModuleCard(
            icon: Icons.qr_code_scanner,
            title: 'Escanear y validar',
            description: 'Reconoce QR permanente o permiso; detecta tokens incorrectos, permisos vencidos y cancelados.',
            color: NexoColors.royalBlue,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QrScannerScreen(user: user))),
          ),
          const SizedBox(height: 12),
        ],
        if (user.isTechnical)
          ModuleCard(
            icon: Icons.approval_outlined,
            title: 'Solicitudes pendientes',
            description: 'Aprueba, rechaza o revisa las solicitudes creadas por docentes y organizadores.',
            color: NexoColors.coral,
            onTap: () => open(context, 'Solicitudes pendientes', PermissionRequestsScreen(user: user)),
          ),
      ],
    );
  }
}

class StudentPermanentQrScreen extends StatelessWidget {
  final AppUser user;
  const StudentPermanentQrScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final payload = StudentQrPayload(user.uid, user.schoolCode).encode();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          title: 'QR permanente del estudiante',
          description: 'Este QR no reemplaza los QR de permisos. Se utiliza para asistencia e identificación.',
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall),
                Text('${user.schoolCode} · ${user.classId}'),
                const SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: QrImageView(data: payload, size: 260),
                ),
                const SizedBox(height: 14),
                const Text('NEXO 360 · QR de estudiante', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Última asistencia registrada'),
                subtitle: Text(data?['lastAttendanceAt'] == null
                    ? 'Aún no hay registros.'
                    : '${formatDateTime(data!['lastAttendanceAt'])} · ${data['lastAttendanceStatus'] ?? ''}'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class PermissionListScreen extends StatelessWidget {
  final AppUser user;
  const PermissionListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('permissions').where('studentId', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) => asDate(b.data()['validUntil']).compareTo(asDate(a.data()['validUntil'])));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading(title: 'Mis permisos', description: 'Historial completo de autorizaciones; cada permiso posee su propio QR.'),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              const EmptyState(icon: Icons.qr_code_2, title: 'Sin permisos', message: 'Cuando se apruebe un permiso aparecerá aquí.')
            else
              ...docs.map((doc) => _PermissionCard(doc: doc)),
          ],
        );
      },
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _PermissionCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final now = DateTime.now();
    final from = asDate(data['validFrom']);
    final until = asDate(data['validUntil']);
    final status = data['status'] as String? ?? 'active';
    final active = status == 'active' && !now.isBefore(from) && now.isBefore(until);
    final payload = PermissionQrPayload(doc.id, data['qrToken'] as String? ?? '').encode();
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: active ? Colors.green.withValues(alpha: .13) : Colors.red.withValues(alpha: .13),
          child: Icon(active ? Icons.verified : Icons.history, color: active ? Colors.green : Colors.red),
        ),
        title: Text(data['reason'] as String? ?? 'Permiso'),
        subtitle: Text('${formatDateTime(from)} – ${formatDateTime(until)} · ${active ? 'Activo' : status == 'cancelled' ? 'Cancelado' : 'Vencido'}'),
        childrenPadding: const EdgeInsets.all(18),
        children: [
          Text('Destino: ${data['destination'] ?? ''}'),
          const SizedBox(height: 14),
          Container(color: Colors.white, padding: const EdgeInsets.all(12), child: QrImageView(data: payload, size: 230)),
          const SizedBox(height: 10),
          const Text('QR exclusivo de este permiso.'),
        ],
      ),
    );
  }
}

Future<void> _permissionForm(BuildContext context, AppUser user) async {
  final reason = TextEditingController();
  final destination = TextEditingController();
  DateTime from = DateTime.now();
  DateTime until = DateTime.now().add(const Duration(hours: 2));
  String selectedClassId = user.classId;
  final selectedStudentIds = <String>{};
  final selectedStudentNames = <String, String>{};

  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 820),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  user.isTechnical ? 'Crear permiso' : 'Solicitar permiso',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text('Selecciona primero el grado/sección y luego uno o varios estudiantes.'),
                const SizedBox(height: 14),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('accountType', isEqualTo: 'student')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 230,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text('No se pudo cargar el listado de estudiantes.');
                    }
                    final students = (snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                        .where((doc) => doc.data()['status'] == 'active')
                        .toList()
                      ..sort((a, b) => '${a.data()['displayName']}'.compareTo('${b.data()['displayName']}'));
                    final classes = students
                        .map((doc) => '${doc.data()['classId'] ?? ''}'.trim())
                        .where((value) => value.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();
                    final effectiveClass = classes.contains(selectedClassId) ? selectedClassId : null;
                    final visibleStudents = effectiveClass == null
                        ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
                        : students.where((doc) => doc.data()['classId'] == effectiveClass).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: effectiveClass,
                          decoration: const InputDecoration(
                            labelText: 'Grado/sección',
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                          items: classes
                              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClassId = value ?? '';
                              selectedStudentIds.removeWhere((id) {
                                final matches = students.where((doc) => doc.id == id);
                                final student = matches.isEmpty ? null : matches.first;
                                return student == null || student.data()['classId'] != selectedClassId;
                              });
                              selectedStudentNames.removeWhere((id, _) => !selectedStudentIds.contains(id));
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 230,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: effectiveClass == null
                              ? const Center(child: Text('Selecciona un grado/sección.'))
                              : visibleStudents.isEmpty
                                  ? const Center(child: Text('No hay estudiantes activos en esta sección.'))
                                  : ListView.builder(
                                      itemCount: visibleStudents.length,
                                      itemBuilder: (context, index) {
                                        final student = visibleStudents[index];
                                        final data = student.data();
                                        final selected = selectedStudentIds.contains(student.id);
                                        return CheckboxListTile(
                                          value: selected,
                                          title: Text(data['displayName'] as String? ?? 'Estudiante'),
                                          subtitle: Text(data['schoolCode'] as String? ?? student.id),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedStudentIds.add(student.id);
                                                selectedStudentNames[student.id] = data['displayName'] as String? ?? student.id;
                                              } else {
                                                selectedStudentIds.remove(student.id);
                                                selectedStudentNames.remove(student.id);
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: 8),
                        Text('${selectedStudentIds.length} estudiante(s) seleccionado(s).'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reason,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destination,
                  decoration: const InputDecoration(labelText: 'Destino o actividad'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: from,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(from),
                    );
                    if (time != null) {
                      setState(() => from = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Desde: ${formatDateTime(from)}'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: until,
                      firstDate: from,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(until),
                    );
                    if (time != null) {
                      setState(() => until = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                    }
                  },
                  icon: const Icon(Icons.stop),
                  label: Text('Hasta: ${formatDateTime(until)}'),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(user.isTechnical ? 'Crear' : 'Enviar solicitud'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  if (saved != true) return;
  final ids = selectedStudentIds.toList()..sort();
  final names = ids.map((id) => selectedStudentNames[id] ?? id).toList();
  if (ids.isEmpty || selectedClassId.isEmpty || reason.text.trim().isEmpty || !until.isAfter(from)) {
    if (context.mounted) {
      showMessage(context, 'Selecciona estudiantes, completa el motivo y usa una vigencia válida.', error: true);
    }
    return;
  }
  if (user.isTechnical) {
    final batch = FirebaseFirestore.instance.batch();
    for (var index = 0; index < ids.length; index++) {
      final ref = FirebaseFirestore.instance.collection('permissions').doc();
      batch.set(ref, {
        'studentId': ids[index],
        'studentName': names[index],
        'classId': selectedClassId,
        'createdBy': user.uid,
        'reason': reason.text.trim(),
        'destination': destination.text.trim(),
        'validFrom': Timestamp.fromDate(from),
        'validUntil': Timestamp.fromDate(until),
        'status': 'active',
        'qrToken': const Uuid().v4().replaceAll('-', '') + const Uuid().v4().replaceAll('-', ''),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  } else {
    await FirebaseFirestore.instance.collection('permission_requests').add({
      'studentIds': ids,
      'studentNames': names,
      'classId': selectedClassId,
      'requestedBy': user.uid,
      'requestedByName': user.displayName,
      'reason': reason.text.trim(),
      'destination': destination.text.trim(),
      'validFrom': Timestamp.fromDate(from),
      'validUntil': Timestamp.fromDate(until),
      'status': 'pending',
      'reviewedBy': null,
      'reviewComment': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  if (context.mounted) {
    showMessage(context, user.isTechnical ? 'Permiso(s) creado(s).' : 'Solicitud enviada.');
  }
}

class PermissionRequestsScreen extends StatelessWidget {
  final AppUser user;
  const PermissionRequestsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('permission_requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) => asDate(b.data()['createdAt']).compareTo(asDate(a.data()['createdAt'])));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading(title: 'Solicitudes de permisos', description: 'Revisión técnica de solicitudes de docentes y organizadores.'),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              const EmptyState(icon: Icons.inbox_outlined, title: 'Sin solicitudes', message: 'No hay solicitudes pendientes o revisadas.')
            else
              ...docs.map((doc) {
                final data = doc.data();
                return Card(
                  child: ListTile(
                    leading: Icon(data['status'] == 'pending' ? Icons.pending_actions : data['status'] == 'approved' ? Icons.check_circle : Icons.cancel),
                    title: Text(data['reason'] as String? ?? 'Solicitud'),
                    subtitle: Text('${data['requestedByName'] ?? ''} · ${List<String>.from(data['studentNames'] as List? ?? const []).join(', ')}\n${formatDateTime(data['validFrom'])} – ${formatDateTime(data['validUntil'])}'),
                    isThreeLine: true,
                    trailing: data['status'] == 'pending'
                        ? Wrap(spacing: 6, children: [
                            FilledButton.tonal(onPressed: () => _reviewRequest(context, doc, user, true), child: const Text('Aprobar')),
                            OutlinedButton(onPressed: () => _reviewRequest(context, doc, user, false), child: const Text('Rechazar')),
                          ])
                        : Chip(label: Text('${data['status']}')),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

Future<void> _reviewRequest(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> request, AppUser technical, bool approve) async {
  final comment = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(approve ? 'Aprobar solicitud' : 'Rechazar solicitud'),
      content: TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Comentario de revisión')),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(approve ? 'Aprobar' : 'Rechazar'))],
    ),
  );
  if (confirmed != true) return;
  final data = request.data();
  final batch = FirebaseFirestore.instance.batch();
  if (approve) {
    final ids = List<String>.from(data['studentIds'] as List? ?? const []);
    final names = List<String>.from(data['studentNames'] as List? ?? const []);
    for (var index = 0; index < ids.length; index++) {
      final ref = FirebaseFirestore.instance.collection('permissions').doc();
      batch.set(ref, {
        'studentId': ids[index],
        'studentName': index < names.length ? names[index] : ids[index],
        'classId': data['classId'],
        'createdBy': technical.uid,
        'reason': data['reason'],
        'destination': data['destination'],
        'validFrom': data['validFrom'],
        'validUntil': data['validUntil'],
        'status': 'active',
        'qrToken': const Uuid().v4().replaceAll('-', '') + const Uuid().v4().replaceAll('-', ''),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdFromRequestId': request.id,
      });
    }
  }
  batch.update(request.reference, {
    'status': approve ? 'approved' : 'denied',
    'reviewedBy': technical.uid,
    'reviewComment': comment.text.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  await batch.commit();
  if (context.mounted) showMessage(context, approve ? 'Solicitud aprobada.' : 'Solicitud rechazada.');
}

class QrScannerScreen extends StatefulWidget {
  final AppUser user;
  const QrScannerScreen({super.key, required this.user});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final manual = TextEditingController();
  bool handled = false;
  String result = 'Escanea un QR o pega el código manual.';
  Color resultColor = NexoColors.muted;

  @override
  void dispose() {
    manual.dispose();
    super.dispose();
  }

  Future<void> validate(String raw) async {
    if (raw.isEmpty) return;
    final student = StudentQrPayload.tryParse(raw);
    if (student != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(student.uid).get();
      if (!mounted) return;
      if (!doc.exists || doc.data()?['accountType'] != 'student' || doc.data()?['schoolCode'] != student.schoolCode) {
        setState(() {
          result = 'QR de estudiante incorrecto o inexistente.';
          resultColor = Colors.red;
        });
      } else {
        setState(() {
          result = 'Estudiante válido: ${doc.data()?['displayName']} · ${doc.data()?['classId']}';
          resultColor = Colors.green;
        });
      }
      return;
    }
    final permission = PermissionQrPayload.tryParse(raw);
    if (permission == null) {
      setState(() {
        result = 'Token incorrecto: el código no pertenece a NEXO 360.';
        resultColor = Colors.red;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('permissions').doc(permission.permissionId).get();
    if (!mounted) return;
    if (!doc.exists || doc.data()?['qrToken'] != permission.token) {
      setState(() {
        result = 'Permiso inexistente o token alterado.';
        resultColor = Colors.red;
      });
      return;
    }
    final data = doc.data()!;
    final now = DateTime.now();
    final from = asDate(data['validFrom']);
    final until = asDate(data['validUntil']);
    if (data['status'] != 'active') {
      setState(() {
        result = 'Permiso no válido: estado ${data['status']}.';
        resultColor = Colors.red;
      });
    } else if (now.isBefore(from)) {
      setState(() {
        result = 'Permiso válido, pero todavía no inicia. Desde ${formatDateTime(from)}.';
        resultColor = Colors.orange;
      });
    } else if (!now.isBefore(until)) {
      setState(() {
        result = 'Permiso expirado el ${formatDateTime(until)}.';
        resultColor = Colors.red;
      });
    } else {
      setState(() {
        result = 'PERMISO VÁLIDO · ${data['studentName']} · ${data['reason']} · hasta ${formatDateTime(until)}';
        resultColor = Colors.green;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validar QR')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: defaultTargetPlatform == TargetPlatform.windows
                ? const ColoredBox(
                    color: Color(0xFF11162F),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.desktop_windows_outlined, size: 56, color: Colors.white70),
                            SizedBox(height: 12),
                            Text(
                              'El escáner por cámara está disponible en Android. En Windows utiliza el código manual.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : MobileScanner(
                    onDetect: (capture) {
                      if (handled) return;
                      final raw = capture.barcodes
                          .map((barcode) => barcode.rawValue)
                          .whereType<String>()
                          .firstOrNull;
                      if (raw != null) {
                        handled = true;
                        validate(raw).whenComplete(
                          () => Future<void>.delayed(
                            const Duration(seconds: 2),
                            () => handled = false,
                          ),
                        );
                      }
                    },
                  ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: resultColor.withValues(alpha: .12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(result, style: TextStyle(color: resultColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: manual, decoration: const InputDecoration(labelText: 'Código manual', prefixIcon: Icon(Icons.keyboard))),
                  const SizedBox(height: 8),
                  FilledButton.icon(onPressed: () => validate(manual.text.trim()), icon: const Icon(Icons.verified_user_outlined), label: const Text('Validar código')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
