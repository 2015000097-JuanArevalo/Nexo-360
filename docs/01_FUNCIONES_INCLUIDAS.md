# Funciones incluidas

## Acceso y usuarios

- Inicio de sesión con Firebase Authentication.
- Tipos principales: técnico, docente y estudiante.
- Rol independiente en eventos: organizador, comisionado o invitado.
- Bloqueo de perfiles inexistentes o inactivos.
- Creación de cuentas por personal técnico mediante una instancia secundaria de Firebase Auth.
- Código escolar único, grado/sección, cursos, comisión y permisos especiales.
- Edición del perfil y cierre de sesión.
- Tema del sistema, claro u oscuro y varias paletas basadas en el logo.

## Portal

- Nombre visible: **Portal**.
- Actividades agrupadas por fecha; no se muestran días vacíos.
- Historial de actividades vencidas.
- Fecha y hora de entrega modificables.
- Recursos por enlaces.
- Opción visual para archivos con alerta de mantenimiento.
- Entregas por enlace, entregas tardías y política de aceptar/no aceptar retrasos.
- Calificación de la entrega conectada con la zona de Notas.
- Avisos separados de las actividades, con leídos/no leídos.
- Avisos generales, por grado/sección o curso.
- Cursos y clases visibles según asignación técnica.
- Materiales por curso mediante enlaces.
- Chat escolar en tiempo real.

## Horario y Diario Pedagógico

- Horario semanal administrado por técnicos.
- Períodos con día, número, hora, curso, docente, aula y sección.
- Acceso rápido al día actual desde Portal.
- Apertura del Diario desde un período del horario.
- Contenido visto, tareas, observaciones y recursos por enlace.
- Lector del QR de una pantalla interactiva: cámara en Android y entrada manual en Windows; guarda el contenido o enlace del QR.
- Opción para presentaciones, imágenes o PDF con alerta de mantenimiento.
- Estado completo/incompleto de cada período.
- Panel de períodos sin llenar para técnicos.
- Asistencia manual por listado.
- Escáner del QR permanente del estudiante.
- Estados presente, ausente, tarde y justificado.
- Justificación de falta, llamado de atención y descuento en conducta.
- Última asistencia guardada en el perfil del estudiante.

## Notas

- Estructura: zona, parciales y examen final.
- Evaluaciones independientes y actividades calificables.
- Bimestres 1–4.
- Pesos anuales: 20%, 30%, 20% y 30%.
- Vista del estudiante por curso y bimestre.
- Promedio bimestral y aporte al promedio anual.
- Promedio anual ponderado por curso.
- Promedio general del estudiante.
- Promedio general del aula para docentes/técnicos.
- Comentarios de entregas y calificación.

## QR y permisos

- La sección se llama **QR**.
- QR permanente único para identificación y asistencia.
- Historial de permisos del estudiante.
- QR separado y token largo para cada permiso.
- Solicitud de permisos por docentes/organizadores.
- Aprobación técnica para uno o varios estudiantes.
- Validación por cámara o código manual.
- Detección de QR incorrecto, token incorrecto, permiso futuro, vencido, cancelado o usado.

## Eventos escolares y Movimiento Juventud

- Secciones independientes para eventos escolares y Juventud.
- Creación y actualización de eventos.
- Área, categoría, capacidad, ubicación, reglamento por enlace y apertura de inscripciones.
- Página pública conectada con Firestore.
- Formulario público y código de seguimiento.
- Inscripciones privadas y estado público sin exponer correo ni teléfono.
- Aprobación, reserva, rechazo y check-in.
- Eliminación de una solicitud para permitir reenviarla.
- Correo prellenado o automático mediante Apps Script.
- Croquis en tiempo real sobre la imagen proporcionada, con 12 puntos.
- Avisos públicos y reglamentos.
- Ayuda por preguntas frecuentes y contactos.
- Comisiones, integrantes, grupos por comisión y chats directos entre miembros.
- Moderación de mensajes directos por docentes y técnicos.
- Solicitudes globales entre comisiones.
- Inventario por comisión.
- Presupuestos aprobados y conversión de elementos adquiridos a inventario.
- Galería y archivos mediante enlaces; carga directa en mantenimiento.

## Administración y operación

- Migración de usuarios, actividades, eventos e inscripciones del prototipo.
- Datos iniciales idempotentes.
- Diagnóstico de lectura por colección.
- Reglas de seguridad por rol.
- Páginas y builds automáticos mediante GitHub Actions.
