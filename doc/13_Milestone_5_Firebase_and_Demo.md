# Milestone 5 — Firebase, ejecución y demostración

## 1. Actualizar dependencias y verificar Flutter

No se agregó ningún paquete nuevo. Desde `Nexo-360/app`:

```powershell
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## 2. Publicar reglas e índices

```powershell
firebase login
firebase use nexo-360-9ed4c
firebase deploy --only firestore:rules,firestore:indexes
```

Las reglas nuevas son necesarias antes de probar el formulario, la consulta pública o el check-in.

## 3. Confirmar el organizador

En Authentication debe existir `organizer@nexo360.com`. Su documento `users/{uid}` debe usar el mismo UID y contener:

```text
accountType: teacher
eventRole: organizer
status: active
```

También puede administrar eventos una cuenta con `accountType: technical` y `status: active`.

## 4. Crear el evento de demostración

Método recomendado:

1. Inicie sesión como organizador o técnico.
2. Abra **Eventos**.
3. Si no hay eventos, pulse **Crear evento de demostración**.
4. Confirme en Firestore `events/encuentro-juvenil-nexo-2026`.

El botón escribe timestamps correctos del servidor. Como referencia manual también se incluye `app/tool/milestone5_sample_event.json`; sus textos `FIRESTORE_TIMESTAMP` deben convertirse a valores Timestamp reales en Firebase Console.

## 5. Probar el checkpoint completo

### Registrar participante

1. Cierre sesión o abra una ventana privada.
2. En Login pulse **Inscripción pública a eventos**.
3. Complete nombre, correo, teléfono e institución.
4. Agregue opcionalmente una URL de documento.
5. Envíe el formulario.
6. Guarde el código de seguimiento mostrado.

Firestore debe contener un documento nuevo en `event_registrations` con:

```text
status: pending
checkedIn: false
checkedInAt: null
checkedInBy: null
```

### Aprobar

1. Inicie sesión como organizador.
2. Abra Eventos → Administrar inscripciones.
3. El contador pendiente y la lista deben actualizarse automáticamente.
4. Pulse **Aprobar** y confirme.
5. El estado debe cambiar a `approved`.

### Consultar resultado

1. Abra **Consultar estado de inscripción** desde Login o use el botón posterior al envío.
2. Pegue el código guardado.
3. Debe aparecer **APROBADA**.

### Check in

1. Regrese a la administración.
2. Pulse **Check in** en el participante aprobado.
3. Debe aparecer **Ingresó**.
4. La consulta pública debe mostrar **Ingreso registrado** y la hora.

### Reserva y rechazo

Cree dos inscripciones adicionales y use **Reservar** y **Rechazar**. La consulta pública debe mostrar **EN RESERVA** y **RECHAZADA** respectivamente.

## 6. Errores frecuentes

| Síntoma | Corrección |
| --- | --- |
| No hay evento en el formulario | Cree el evento demo y confirme `isPublic`, `registrationOpen` y `status: active` |
| `permission-denied` al enviar | Publique las reglas; revise que el evento exista y esté abierto |
| Organizador no ve la lista | Revise `eventRole: organizer`, `status: active` y el UID del perfil |
| El participante no consulta estado | Use el ID completo del documento y publique las reglas nuevas |
| Check-in deshabilitado | Primero cambie la inscripción a `approved` |
| La app conserva pantallas anteriores | Ejecute `flutter clean`, `flutter pub get` y reinicie completamente |

## 7. Hosting web opcional

Para presentar el formulario públicamente:

```powershell
flutter build web
firebase deploy --only hosting
```

En Firebase Authentication → Settings → Authorized domains, mantenga `localhost` y agregue el dominio de Hosting si corresponde. Configure Hosting como SPA para que las rutas `/events/register` y `/events/status/...` regresen `index.html`.
