# Esquema, roles y dependencias

## Tipos de cuenta

### Técnico

Puede administrar usuarios, cursos, horarios, reglas operativas, permisos, eventos, inscripciones, comisiones, inventarios y presupuestos. Es el único que crea perfiles y ejecuta migraciones.

### Docente

Puede publicar avisos, actividades, materiales por enlace, completar el Diario, tomar asistencia, registrar conducta, calificar y solicitar permisos. Solo accede a sus cursos/asignaciones.

### Estudiante

Consulta Portal, horarios, Diario, notas, avisos, cursos y materiales; entrega actividades; usa su QR permanente; consulta QR de permisos y eventos.

## Rol de eventos

- `organizer`: administra eventos e inscripciones.
- `commissioner`: participa en comisiones, inventarios, presupuestos y comunicación.
- `guest`: consulta la información autorizada.

El rol de eventos es independiente del tipo de cuenta. Un docente o estudiante puede ser organizador/comisionado sin cambiar su función escolar.

## Relaciones principales

```text
directory_profiles → directorio interno sin datos sensibles
users.courseIds → courses/{id}
users.classId → courses.classId / timetable_periods.classId
school_activities.courseId → courses/{id}
activity_submissions.activityId → school_activities/{id}
grade_items.courseId → courses/{id}
grade_scores.itemId → grade_items/{id}
timetable_periods.courseId → courses/{id}
pedagogical_diary.periodId → timetable_periods/{id}
attendance_records.diaryId → pedagogical_diary/{id}
permissions.studentId → users/{id}
event_registration_requests.eventId → events/{id}
public_registration_status/{id} ↔ event_registration_requests/{id}
committee_messages.committeeId → committees/{id}
direct_messages.conversationId → conversación entre dos miembros
inventory_items.committeeId → committees/{id}
budget_items.committeeId → committees/{id}
```

## Convenciones

- Fechas: `Timestamp` de Firestore.
- Estado activo de usuario: `status = active`.
- Grado/sección: cadena normalizada, por ejemplo `IVC`.
- QR de estudiante: `nexo360://student?...` con UID y código escolar.
- QR de permiso: `nexo360://permission?...` con ID y token.
- Archivos: campos `fileUrl` permanecen `null` mientras Storage esté en mantenimiento.
