import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class TechnicalAdminScreen extends StatelessWidget {
  final AppUser user;
  const TechnicalAdminScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (!user.isTechnical) return const EmptyState(icon: Icons.lock_outline, title: 'Acceso restringido', message: 'Solo el personal técnico puede abrir esta sección.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(title: 'Administración técnica', description: 'Usuarios, roles, grados, cursos, configuración y datos iniciales.'),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 800 ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          final cards = [
            ModuleCard(icon: Icons.person_add_alt_1_outlined, title: 'Crear cuenta', description: 'Crea la cuenta en Firebase Authentication y su perfil activo en Firestore.', color: NexoColors.royalBlue, onTap: () => _createUser(context, user)),
            ModuleCard(icon: Icons.people_alt_outlined, title: 'Administrar usuarios', description: 'Edita rol, estado, grado, sección, cursos y comisión.', color: NexoColors.violet, onTap: () => _usersDialog(context, user)),
            ModuleCard(icon: Icons.dataset_outlined, title: 'Crear datos iniciales', description: 'Genera cursos, horarios, eventos, FAQ y ubicaciones de demostración utilizables.', color: NexoColors.cyan, onTap: () => _seedData(context, user)),
            ModuleCard(icon: Icons.move_down_outlined, title: 'Migrar datos del prototipo', description: 'Conserva las inscripciones antiguas y completa campos nuevos sin borrar información.', color: NexoColors.violet, onTap: () => _migrateLegacyData(context, user)),
            ModuleCard(icon: Icons.health_and_safety_outlined, title: 'Diagnóstico Firebase', description: 'Verifica lectura de colecciones y estado del servicio sin modificar datos.', color: NexoColors.coral, onTap: () => _diagnostics(context)),
          ];
          return Wrap(spacing: 12, runSpacing: 12, children: cards.map((card) => SizedBox(width: width, child: card)).toList());
        }),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Importante sobre la creación de cuentas'),
            subtitle: Text('La cuenta técnica crea usuarios mediante una instancia secundaria de Firebase Auth. Los perfiles inactivos o inexistentes no pueden usar Firestore, aunque alguien intente crear una cuenta directamente con la API pública de Authentication.'),
          ),
        ),
      ],
    );
  }
}

Future<void> _createUser(BuildContext context, AppUser technical) async {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final schoolCode = TextEditingController();
  final classId = TextEditingController();
  String accountType = 'student';
  String eventRole = 'guest';
  bool saving = false;
  String? error;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Crear cuenta NEXO 360'),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre completo')),
                const SizedBox(height: 10),
                TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo')),
                const SizedBox(height: 10),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña temporal')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: accountType,
                  decoration: const InputDecoration(labelText: 'Tipo de cuenta'),
                  items: const [DropdownMenuItem(value: 'student', child: Text('Estudiante')), DropdownMenuItem(value: 'teacher', child: Text('Docente')), DropdownMenuItem(value: 'technical', child: Text('Técnico'))],
                  onChanged: saving ? null : (value) => setState(() => accountType = value ?? 'student'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: eventRole,
                  decoration: const InputDecoration(labelText: 'Rol en eventos'),
                  items: const [DropdownMenuItem(value: 'guest', child: Text('Invitado')), DropdownMenuItem(value: 'commissioner', child: Text('Comisionado')), DropdownMenuItem(value: 'organizer', child: Text('Organizador'))],
                  onChanged: saving ? null : (value) => setState(() => eventRole = value ?? 'guest'),
                ),
                const SizedBox(height: 10),
                TextField(controller: schoolCode, decoration: const InputDecoration(labelText: 'Código escolar único')),
                const SizedBox(height: 10),
                TextField(controller: classId, decoration: const InputDecoration(labelText: 'Grado/sección')),
                if (error != null) ...[const SizedBox(height: 10), Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (name.text.trim().length < 3 || !email.text.contains('@') || password.text.length < 6 || schoolCode.text.trim().isEmpty) {
                      setState(() => error = 'Completa nombre, correo, contraseña y código escolar.');
                      return;
                    }
                    setState(() {
                      saving = true;
                      error = null;
                    });
                    try {
                      await AuthService().createManagedUser(
                        technical: technical,
                        email: email.text,
                        password: password.text,
                        displayName: name.text,
                        accountType: accountType,
                        eventRole: eventRole,
                        schoolCode: schoolCode.text,
                        classId: classId.text,
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (context.mounted) showMessage(context, 'Cuenta creada correctamente.');
                    } catch (exception) {
                      setState(() {
                        saving = false;
                        error = '$exception';
                      });
                    }
                  },
            child: Text(saving ? 'Creando...' : 'Crear cuenta'),
          ),
        ],
      ),
    ),
  );
}

void _usersDialog(BuildContext context, AppUser technical) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Usuarios', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs.toList()..sort((a, b) => '${a.data()['displayName']}'.compareTo('${b.data()['displayName']}'));
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        return ListTile(
                          leading: CircleAvatar(child: Text((data['displayName'] as String? ?? 'U').substring(0, 1).toUpperCase())),
                          title: Text(data['displayName'] as String? ?? 'Usuario'),
                          subtitle: Text('${data['email'] ?? ''} · ${data['accountType'] ?? ''} · ${data['classId'] ?? ''} · ${data['status'] ?? ''}'),
                          trailing: IconButton(onPressed: () => _editUser(context, doc), icon: const Icon(Icons.edit_outlined)),
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

Future<void> _editUser(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
  final data = doc.data();
  final name = TextEditingController(text: data['displayName'] as String? ?? '');
  final schoolCode = TextEditingController(text: data['schoolCode'] as String? ?? '');
  final classId = TextEditingController(text: data['classId'] as String? ?? '');
  final courses = TextEditingController(text: List<String>.from(data['courseIds'] as List? ?? const []).join(', '));
  final committee = TextEditingController(text: data['committeeId'] as String? ?? '');
  final permissions = TextEditingController(text: List<String>.from(data['eventPermissions'] as List? ?? const []).join(', '));
  String accountType = data['accountType'] as String? ?? 'student';
  String eventRole = data['eventRole'] as String? ?? 'guest';
  String status = data['status'] as String? ?? 'active';
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Editar ${data['displayName']}'),
        content: SizedBox(
          width: 680,
          child: SingleChildScrollView(
            child: Column(children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: DropdownButtonFormField<String>(initialValue: accountType, decoration: const InputDecoration(labelText: 'Cuenta'), items: const [DropdownMenuItem(value: 'student', child: Text('Estudiante')), DropdownMenuItem(value: 'teacher', child: Text('Docente')), DropdownMenuItem(value: 'technical', child: Text('Técnico'))], onChanged: (value) => setState(() => accountType = value ?? accountType))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(initialValue: eventRole, decoration: const InputDecoration(labelText: 'Eventos'), items: const [DropdownMenuItem(value: 'guest', child: Text('Invitado')), DropdownMenuItem(value: 'commissioner', child: Text('Comisionado')), DropdownMenuItem(value: 'organizer', child: Text('Organizador'))], onChanged: (value) => setState(() => eventRole = value ?? eventRole)))]),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(initialValue: status, decoration: const InputDecoration(labelText: 'Estado'), items: const [DropdownMenuItem(value: 'active', child: Text('Activo')), DropdownMenuItem(value: 'inactive', child: Text('Inactivo'))], onChanged: (value) => setState(() => status = value ?? status)),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: TextField(controller: schoolCode, decoration: const InputDecoration(labelText: 'Código escolar'))), const SizedBox(width: 10), Expanded(child: TextField(controller: classId, decoration: const InputDecoration(labelText: 'Grado/sección')))]),
              const SizedBox(height: 10),
              TextField(controller: courses, decoration: const InputDecoration(labelText: 'IDs de cursos separados por coma')),
              const SizedBox(height: 10),
              TextField(controller: committee, decoration: const InputDecoration(labelText: 'ID de comisión')),
              const SizedBox(height: 10),
              TextField(controller: permissions, decoration: const InputDecoration(labelText: 'Permisos especiales separados por coma', helperText: 'Ejemplo: class_representative')),
            ]),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
      ),
    ),
  );
  if (saved != true) return;
  final batch = FirebaseFirestore.instance.batch();
  batch.update(doc.reference, {
    'displayName': name.text.trim(),
    'accountType': accountType,
    'eventRole': eventRole,
    'status': status,
    'schoolCode': schoolCode.text.trim(),
    'classId': classId.text.trim(),
    'courseIds': courses.text.split(',').map((value) => value.trim()).where((value) => value.isNotEmpty).toList(),
    'committeeId': committee.text.trim(),
    'eventPermissions': permissions.text.split(',').map((value) => value.trim()).where((value) => value.isNotEmpty).toList(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  batch.set(FirebaseFirestore.instance.collection('directory_profiles').doc(doc.id), {
    'displayName': name.text.trim(),
    'accountType': accountType,
    'eventRole': eventRole,
    'status': status,
    'classId': classId.text.trim(),
    'committeeId': committee.text.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  await batch.commit();
}

Future<void> _seedData(BuildContext context, AppUser user) async {
  final confirmed = await confirmDialog(context, title: 'Crear datos iniciales', message: 'Se crearán documentos de ejemplo idempotentes para que todos los módulos puedan probarse.', confirm: 'Crear datos');
  if (!confirmed) return;
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  batch.set(db.collection('courses').doc('MAT-IVC'), {
    'code': 'MAT-IVC', 'name': 'Matemática IV Bachillerato C', 'description': 'Curso de demostración', 'classId': 'IVC', 'teacherId': '', 'teacherName': 'Docente por asignar', 'isConductCourse': false, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  batch.set(db.collection('courses').doc('CONDUCTA-IVC'), {
    'code': 'CONDUCTA-IVC', 'name': 'Conducta IV Bachillerato C', 'description': 'Registro de conducta', 'classId': 'IVC', 'teacherId': '', 'teacherName': 'Encargado', 'isConductCourse': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  for (var day = 1; day <= 5; day++) {
    for (var period = 1; period <= 3; period++) {
      final start = 420 + (period - 1) * 50;
      batch.set(db.collection('timetable_periods').doc('demo_${day}_$period'), {
        'dayOfWeek': day, 'periodNumber': period, 'startMinutes': start, 'endMinutes': start + 45, 'classId': 'IVC', 'courseId': 'MAT-IVC', 'courseName': 'Matemática', 'teacherId': '', 'teacherName': 'Docente por asignar', 'room': 'Aula IVC', 'active': true, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
  batch.set(db.collection('events').doc('juventud-2026-demo'), {
    'name': 'Movimiento Juventud 2026', 'description': 'Festival escolar de áreas, categorías y comisiones.', 'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))), 'location': 'Colegio Salesiano Don Bosco', 'capacity': 500, 'area': 'General', 'category': 'Todas', 'regulationLink': '', 'eventType': 'youth', 'isPublic': true, 'registrationOpen': true, 'status': 'active', 'createdBy': user.uid, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  batch.set(db.collection('event_faqs').doc('faq-inscripcion'), {
    'question': '¿Cómo me inscribo?', 'answer': 'Abre la página pública, selecciona el evento y completa el formulario. La autorización en PDF mostrará un aviso mientras el almacenamiento esté en mantenimiento.', 'keywords': ['inscripción', 'inscribo', 'registro', 'formulario'], 'contactEmail': 'movimiento@colegiodonbosco.edu.gt', 'createdBy': user.uid, 'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  const points = <int, List<double>>{1: [5, 28], 2: [17, 26], 3: [25, 8], 4: [38, 10], 5: [42, 17], 6: [51, 10], 7: [61, 22], 8: [69, 38], 9: [57, 43], 10: [51, 54], 11: [35, 53], 12: [48, 72]};
  for (final entry in points.entries) {
    batch.set(db.collection('event_live_locations').doc('point-${entry.key}'), {
      'pointNumber': entry.key, 'locationName': 'Punto ${entry.key}', 'eventId': '', 'eventName': '', 'description': '', 'xPercent': entry.value[0], 'yPercent': entry.value[1], 'status': 'finished', 'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  await batch.commit();
  if (context.mounted) showMessage(context, 'Datos iniciales creados. Asigna docentes y estudiantes desde Usuarios.');
}


Future<void> _migrateLegacyData(BuildContext context, AppUser user) async {
  final confirmed = await confirmDialog(
    context,
    title: 'Migrar datos anteriores',
    message: 'Se copiarán las inscripciones de event_registrations a event_registration_requests y se completarán campos faltantes en actividades, eventos y usuarios. No se borrarán los documentos originales.',
    confirm: 'Migrar',
  );
  if (!confirmed) return;
  final db = FirebaseFirestore.instance;
  var migratedRegistrations = 0;
  var updatedActivities = 0;
  var updatedEvents = 0;
  var updatedUsers = 0;

  try {
    final legacyRegistrations = await db.collection('event_registrations').get();
    for (final legacy in legacyRegistrations.docs) {
      final data = legacy.data();
      final trackingCode = legacy.id;
      final eventDoc = await db.collection('events').doc('${data['eventId'] ?? ''}').get();
      final eventName = data['eventName'] ?? eventDoc.data()?['name'] ?? 'Evento NEXO 360';
      final target = db.collection('event_registration_requests').doc(trackingCode);
      final existing = await target.get();
      if (!existing.exists) {
        final batch = db.batch();
        batch.set(target, {
          'eventId': '${data['eventId'] ?? ''}',
          'eventName': '$eventName',
          'fullName': '${data['fullName'] ?? 'Participante'}',
          'email': '${data['email'] ?? ''}',
          'phone': '${data['phone'] ?? ''}',
          'organization': '${data['organization'] ?? ''}',
          'area': '${data['area'] ?? 'General'}',
          'category': '${data['category'] ?? 'General'}',
          'trackingCode': trackingCode,
          'authorizationFileUrl': data['documentUrl'],
          'status': '${data['status'] ?? 'pending'}',
          'checkedIn': data['checkedIn'] == true,
          'checkedInAt': data['checkedInAt'],
          'checkedInBy': data['checkedInBy'],
          'reviewComment': '${data['reviewComment'] ?? ''}',
          'reviewedBy': data['reviewedBy'],
          'reviewedAt': data['reviewedAt'],
          'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'migratedFrom': 'event_registrations/$trackingCode',
        });
        batch.set(db.collection('public_registration_status').doc(trackingCode), {
          'eventId': '${data['eventId'] ?? ''}',
          'eventName': '$eventName',
          'status': '${data['status'] ?? 'pending'}',
          'checkedIn': data['checkedIn'] == true,
          'publicComment': '${data['reviewComment'] ?? 'Registro migrado correctamente.'}',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await batch.commit();
        migratedRegistrations++;
      }
    }

    final activities = await db.collection('school_activities').get();
    for (final document in activities.docs) {
      final data = document.data();
      final patch = <String, dynamic>{};
      if (!data.containsKey('courseId')) patch['courseId'] = '${data['course'] ?? 'GENERAL'}';
      if (!data.containsKey('courseName')) patch['courseName'] = '${data['course'] ?? 'General'}';
      if (!data.containsKey('points')) patch['points'] = 0;
      if (!data.containsKey('allowLate')) patch['allowLate'] = true;
      if (!data.containsKey('allowStudentLinks')) patch['allowStudentLinks'] = true;
      if (!data.containsKey('allowStudentFiles')) patch['allowStudentFiles'] = true;
      if (!data.containsKey('resourceLinks')) {
        final old = '${data['attachmentUrl'] ?? ''}'.trim();
        patch['resourceLinks'] = old.isEmpty ? <Map<String, String>>[] : <Map<String, String>>[{'label': 'Recurso anterior', 'url': old}];
      }
      patch['updatedAt'] = FieldValue.serverTimestamp();
      if (patch.length > 1) {
        await document.reference.set(patch, SetOptions(merge: true));
        updatedActivities++;
      }
    }

    final events = await db.collection('events').get();
    for (final document in events.docs) {
      final data = document.data();
      final patch = <String, dynamic>{};
      if (!data.containsKey('eventType')) patch['eventType'] = 'school';
      if (!data.containsKey('area')) patch['area'] = 'General';
      if (!data.containsKey('category')) patch['category'] = 'General';
      if (!data.containsKey('regulationLink')) patch['regulationLink'] = '';
      patch['updatedAt'] = FieldValue.serverTimestamp();
      if (patch.length > 1) {
        await document.reference.set(patch, SetOptions(merge: true));
        updatedEvents++;
      }
    }

    final users = await db.collection('users').get();
    for (final document in users.docs) {
      final data = document.data();
      final patch = <String, dynamic>{};
      if (!data.containsKey('courseIds')) patch['courseIds'] = <String>[];
      if (!data.containsKey('eventPermissions')) patch['eventPermissions'] = <String>[];
      if (!data.containsKey('committeeId')) patch['committeeId'] = '';
      if (!data.containsKey('phone')) patch['phone'] = '';
      if (!data.containsKey('guardianPhone')) patch['guardianPhone'] = '';
      patch['updatedAt'] = FieldValue.serverTimestamp();
      if (patch.length > 1) {
        await document.reference.set(patch, SetOptions(merge: true));
        updatedUsers++;
      }
      final merged = {...data, ...patch};
      await db.collection('directory_profiles').doc(document.id).set({
        'displayName': '${merged['displayName'] ?? 'Usuario'}',
        'accountType': '${merged['accountType'] ?? 'student'}',
        'eventRole': '${merged['eventRole'] ?? 'guest'}',
        'status': '${merged['status'] ?? 'active'}',
        'classId': '${merged['classId'] ?? ''}',
        'committeeId': '${merged['committeeId'] ?? ''}',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await db.collection('audit_logs').add({
      'action': 'legacy_migration',
      'actorId': user.uid,
      'actorName': user.displayName,
      'details': {
        'registrations': migratedRegistrations,
        'activities': updatedActivities,
        'events': updatedEvents,
        'users': updatedUsers,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (context.mounted) {
      showMessage(context, 'Migración terminada: $migratedRegistrations inscripciones, $updatedActivities actividades, $updatedEvents eventos y $updatedUsers usuarios.');
    }
  } catch (exception) {
    if (context.mounted) showMessage(context, 'La migración se detuvo: $exception', error: true);
  }
}

Future<void> _diagnostics(BuildContext context) async {
  final collections = ['users', 'courses', 'timetable_periods', 'school_activities', 'permissions', 'events', 'event_registration_requests'];
  final results = <String>[];
  for (final collection in collections) {
    try {
      final snapshot = await FirebaseFirestore.instance.collection(collection).limit(1).get();
      results.add('✓ $collection: lectura correcta (${snapshot.docs.length} muestra)');
    } catch (exception) {
      results.add('✗ $collection: $exception');
    }
  }
  if (!context.mounted) return;
  showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Diagnóstico Firebase'), content: SelectableText(results.join('\n')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))]));
}
