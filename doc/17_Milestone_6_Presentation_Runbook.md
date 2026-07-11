# Milestone 6 — Build, capturas, respaldo y ensayo

## 1. Credenciales privadas

1. Copie `app/tool/demo_credentials.template.md` como `app/tool/demo_credentials.private.md`.
2. Complete las contraseñas únicamente en la copia privada.
3. Confirme con `git status` que el archivo privado no aparece.
4. No fotografíe ni grabe la nota de credenciales.

## 2. Capturas obligatorias

Guarde las imágenes en una carpeta externa `presentation/screenshots/`, no dentro del repositorio.

| Archivo sugerido | Captura |
| --- | --- |
| `01-login.png` | Login sin credenciales visibles |
| `02-dashboard-teacher.png` | Resúmenes y tarjetas del docente |
| `03-assignment-created.png` | Actividad creada |
| `04-assignment-student.png` | Detalle visto por estudiante |
| `05-permission-request.png` | Solicitud docente |
| `06-permission-approved.png` | Aprobación técnica |
| `07-student-qr.png` | QR del estudiante |
| `08-valid.png` | VÁLIDO verde |
| `09-expired.png` | EXPIRADO rojo |
| `10-unauthorized.png` | NO AUTORIZADO rojo |
| `11-event-form.png` | Inscripción pública |
| `12-registration-admin.png` | Registro pendiente del organizador |
| `13-registration-approved.png` | Estado público aprobado |
| `14-check-in.png` | Ingreso registrado |

## 3. Build estable

Congele primero el commit y las reglas que pasaron la matriz manual.

```powershell
cd app
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build web --release
```

Resultados esperados:

```text
app/build/app/outputs/flutter-apk/app-release.apk
app/build/web/
```

Copie el APK fuera del directorio `build/` y póngale un nombre versionado, por ejemplo `NEXO360-demo-2026-07-11.apk`.

## 4. Respaldo ejecutable

- Principal: teléfono Android físico conectado y autorizado.
- Respaldo 1: Chrome local con `flutter run -d chrome`.
- Respaldo 2: APK release instalado previamente.
- Respaldo 3: build web desplegado en Firebase Hosting.

```powershell
firebase deploy --only hosting
```

No despliegue Hosting por primera vez minutos antes de presentar. Verifique rutas profundas y configure el proyecto como SPA.

## 5. Video de respaldo

Grabe entre 2 y 4 minutos, sin mostrar contraseñas:

1. Login docente y actividad.
2. Solicitud de permiso y aprobación técnica.
3. QR válido, expirado y token incorrecto.
4. Inscripción pública, aprobación y check-in.
5. Dashboard final.

Reproduzca el video completo sin Internet antes de considerarlo válido. Guarde una copia local y otra en una memoria USB o teléfono.

## 6. Guion de presentación

1. Dashboard y resúmenes — 30 segundos.
2. Portal Escolar — 60 segundos.
3. Permisos QR — 90 segundos.
4. Eventos, aprobación y check-in — 90 segundos.
5. Roles protegidos y cierre — 30 segundos.

Objetivo total: 5 minutos. No abra módulos secundarios; señálelos como prototipos.

## 7. Dos ensayos

| Ensayo | Objetivo | Registrar |
| --- | --- | --- |
| 1 | Encontrar errores y medir tiempo | Fallos, esperas Firebase, duración |
| 2 | Simulación final sin detenerse | Duración, claridad, funcionamiento del respaldo |

Después del segundo ensayo, corrija solo problemas Critical. No cambie la base de datos manualmente durante la demostración: use **Preparar presentación** antes de empezar.
