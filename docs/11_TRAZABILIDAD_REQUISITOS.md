# Trazabilidad de requisitos de la versión completa

Este documento relaciona lo solicitado con la pantalla y la colección que lo implementan.

| Requisito | Implementación | Datos principales |
|---|---|---|
| Inicio de sesión y cuentas técnicas/docentes/estudiantes | `auth/login_screen.dart`, `technical_admin_screen.dart` | `users`, Firebase Authentication |
| Roles de Movimiento Juventud | Perfil independiente `eventRole`: organizer, commissioner, guest | `users`, `directory_profiles` |
| Menú Portal, QR, Eventos, Administración y Usuario | `core/widgets/app_shell.dart` | — |
| Portal con actividades por fecha | `portal/activities_screen.dart` agrupa por fecha y omite días vacíos | `school_activities` |
| Archivos y links en actividades | Links activos; botones de archivos muestran mantenimiento | `resourceLinks`, `fileAttachments` |
| Entregas normales/tardías | Entrega por enlace, bloqueo o aceptación después del límite | `activity_submissions` |
| Calificación de actividades | Nota y comentario del docente; sincronización con Notas | `activity_submissions`, `grade_items`, `grade_scores` |
| Avisos separados, leídos/no leídos | `portal/announcements_screen.dart` | `school_announcements`, `announcement_reads` |
| Cursos y clases asignados por técnicos | `portal/courses_screen.dart`, `technical_admin_screen.dart` | `courses`, `users.courseIds`, `users.classId` |
| Carpeta/materiales de curso | Links y botón de archivo en mantenimiento | `course_materials` |
| Horario general | `portal/timetable_screen.dart` | `timetable_periods` |
| Horario administrado por técnicos | Crear/editar/eliminar períodos, horas, curso, docente, aula y sección | `timetable_periods` |
| Acceso rápido al día actual | Tarjeta rápida desde Portal y apertura del período | `timetable_periods` |
| Diario Pedagógico | `portal/diary_screen.dart` | `pedagogical_diary` |
| Contenido visto, tareas y observaciones | Formulario por período | `pedagogical_diary` |
| Enlaces, presentación y QR de pantalla | Link activo, lector QR Android/manual Windows, archivo en mantenimiento | `resourceLink`, `interactiveBoardNote` |
| Alerta de períodos incompletos | Banner técnico en tiempo real dentro del Diario | `timetable_periods`, `pedagogical_diary` |
| Asistencia manual | Listado por aula con presente/tarde/ausente | `attendance_records` |
| Asistencia con QR permanente | Escáner Android y validación contra UID/código/sección | `users`, `attendance_records` |
| Justificación, llamado y conducta | Diálogo de inasistencia y descuento de puntos | `attendance_records`, `conduct_events` |
| Última asistencia | Se actualiza en el perfil del estudiante | `users.lastAttendance*` |
| Notas por zona/parcial/final | `portal/grades_screen.dart` | `grade_items`, `grade_scores` |
| Bimestres 20/30/20/30 | Cálculo bimestral y anual ponderado | `grade_scores` |
| Promedio del alumno/curso/aula | Vistas del estudiante y del docente/técnico | `grade_scores` |
| Chat escolar | `portal/school_chat_screen.dart` | `school_messages` |
| Sección Permisos renombrada QR | `qr/qr_hub_screen.dart` | — |
| QR único del estudiante | QR firmado con UID, código y sección | `users` |
| QR individual de permisos | Token independiente, historial y vigencia | `permissions` |
| Solicitudes para varios estudiantes | Docente/organizador solicita; técnico aprueba | `permission_requests`, `permissions` |
| Validación válida, futura, vencida o incorrecta | Cámara Android y código manual Windows | `permissions` |
| Eventos escolares y Juventud separados | `events/events_hub_screen.dart` | `events.eventType` |
| Inscripción pública | `web/eventos`, formulario Flutter | `event_registration_requests` |
| Seguimiento sin exponer PII | Código público separado | `public_registration_status` |
| Aprobar/reservar/rechazar/check-in/eliminar | `events/registration_admin_screen.dart` | `event_registration_requests` |
| Correo de aprobación | `mailto:` o Apps Script opcional | `google_apps_script/Code.gs` |
| Información/reglamentos/calendario | App y web consumen las mismas colecciones | `events`, `event_announcements`, `event_faqs` |
| Croquis en tiempo real | Imagen original, 12 puntos editables | `event_live_locations` |
| Ayuda | Asistente local de FAQ y contactos, sin API pagada | `event_faqs` |
| Inventarios | CRUD por comisión | `inventory_items` |
| Solicitudes globales | Feed de solicitudes | `committee_requests` |
| Comunicación por comisión | Directorio seguro y chat grupal | `committees`, `directory_profiles`, `committee_messages` |
| Chat directo y moderación docente | Conversaciones entre miembros y panel de moderación | `direct_messages` |
| Galería y archivos | Links activos; subida directa en mantenimiento | `event_gallery_items` |
| Presupuestos e ingreso a inventario | Elemento aprobado puede convertirse en inventario | `budget_items`, `inventory_items` |
| Temas | Sistema, claro, oscuro y paletas NEXO | preferencias locales |
| Página pública | `web/eventos` | Firestore público con reglas limitadas |
| Página de presentación/descarga | `web/descargas` | GitHub Releases |
| APK y Windows | Scripts locales y workflow `build-release.yml` | artefactos de GitHub Actions |
| Migración del prototipo | Acción técnica no destructiva | colecciones heredadas y finales |
