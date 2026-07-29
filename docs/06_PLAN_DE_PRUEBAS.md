# Plan de pruebas antes de publicar

Registra cada resultado como Correcto, Falló o No probado.

## Acceso

- Inicio correcto para técnico, docente y estudiante.
- Contraseña incorrecta.
- Usuario de Authentication sin documento `users/{uid}`.
- Usuario con `status=inactive`.
- Estudiante intenta abrir Administración.
- Cerrar y volver a abrir conserva la sesión.
- Cerrar sesión elimina la sesión local.

## Portal

- Técnico asigna curso a docente y estudiante.
- Docente crea actividad con fecha, enlace, puntos, bimestre y entrega tardía.
- Actividad aparece debajo de la fecha correcta.
- Días vacíos no aparecen.
- Estudiante entrega por enlace antes de vencer.
- Estudiante entrega tarde cuando está permitido.
- Entrega tarde bloqueada cuando no está permitido.
- Botón de archivo muestra mantenimiento.
- Docente cambia fecha límite.
- Docente califica y la nota aparece en Notas.
- Aviso aparece como no leído y cambia a leído.
- Material por enlace abre correctamente.
- Chat escolar recibe mensajes en tiempo real.

## Horario y Diario

- Técnico crea/edita períodos con horas válidas.
- Portal abre rápidamente el día actual.
- Docente abre el Diario desde el período.
- Guarda contenido, tarea y observaciones.
- Período incompleto aparece en advertencias técnicas.
- Período completo desaparece de advertencias.
- Asistencia manual actualiza al estudiante.
- QR permanente identifica al estudiante correcto.
- QR de una sección diferente es rechazado.
- QR de pantalla interactiva guarda la referencia de clase.
- QR alterado es rechazado.
- Ausencia permite justificación, llamada de atención y descuento de conducta.

## Notas

- Crear zona, parcial y examen final.
- Rechazar nota menor que cero o mayor al máximo.
- Cambiar entre bimestres.
- Confirmar pesos 20/30/20/30.
- Ver promedio anual ponderado del curso.
- Ver promedio general del estudiante.
- Ver promedio general del aula.

## QR y permisos

- Estudiante ve QR permanente.
- Docente filtra por grado/sección y selecciona varios estudiantes.
- Técnico aprueba y genera permisos separados.
- Permiso válido.
- Permiso aún no iniciado.
- Permiso expirado.
- Permiso cancelado/usado.
- Token incorrecto.
- ID inexistente.

## Eventos y web

- Crear evento escolar.
- Crear evento Juventud.
- Solo eventos públicos aparecen en la web.
- Abrir/cerrar inscripciones.
- Visitante envía formulario sin PDF y recibe código.
- Visitante consulta el estado sin ver correo/teléfono.
- Organizador aprueba, reserva y rechaza.
- Check-in solo después de aprobación.
- Eliminar registro permite reenviarlo.
- Croquis refleja cambios en tiempo real.
- Avisos, FAQ y galería por enlaces.
- Chats de comisiones.
- Chat directo entre integrantes.
- Docente/técnico revisa el panel de moderación.
- Solicitud global cambia de estado.
- Presupuesto marcado como adquirido crea inventario.

## Builds y páginas

- `flutter analyze` sin errores.
- `flutter test` completo.
- APK instala y abre en Android físico.
- Escáner solicita permiso de cámara.
- Windows abre desde la carpeta extraída.
- Ambas plataformas se conectan al mismo Firebase.
- Página `/eventos/` abre por HTTPS.
- Página `/descargas/` encuentra el último Release.
- APK y ZIP descargados coinciden con la última etiqueta.
