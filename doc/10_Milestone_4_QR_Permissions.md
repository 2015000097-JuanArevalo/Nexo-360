# Milestone 4 — Flujo de permisos QR

## Resultado implementado

El prototipo ya cubre el flujo principal de M14:

1. El personal técnico crea un permiso real para un estudiante.
2. Un docente u organizador usa el mismo formulario para enviar una solicitud pendiente.
3. El estudiante ve sus permisos en tiempo real y presenta un QR real.
4. El personal técnico valida el QR con cámara o con el código manual.
5. La pantalla de resultado distingue: válido, expirado, no autorizado, no encontrado, inválido y aún no vigente.

> La separación entre solicitud y creación directa conserva el modelo de seguridad existente del proyecto: `permissions` solo lo modifica una cuenta `technical`. El docente no escribe directamente en esa colección.

## Archivos principales

| Archivo | Responsabilidad |
| --- | --- |
| `app/lib/core/models/permission_record.dart` | Modelo del permiso y resultado de validación |
| `app/lib/core/utils/permission_qr_payload.dart` | Codifica y analiza el QR JSON y el código manual |
| `app/lib/core/services/permission_service.dart` | Consultas y escrituras de Firestore |
| `app/lib/core/services/permission_validator.dart` | Reglas puras de vigencia, estado y token |
| `app/lib/features/permisos/permission_form_screen.dart` | Formulario técnico/docente |
| `app/lib/features/permisos/student_qr_screen.dart` | Permiso y QR del estudiante |
| `app/lib/features/permisos/qr_validation_screen.dart` | Escáner, ingreso manual y resultado grande |
| `app/firestore.rules` | Acceso y validación de datos compatible con el flujo |
| `app/test/permission_workflow_test.dart` | Casos válido, expirado, no autorizado y cancelado |

## Documento `permissions/{permissionId}`

```text
studentId: string
studentName: string
classId: string | null
createdBy: string
reason: string
destination: string
validFrom: timestamp
validUntil: timestamp
status: active | cancelled | used | expired
qrToken: string aleatorio seguro
createdAt: timestamp del servidor
updatedAt: timestamp del servidor
createdFromRequestId: string | null
```

El QR contiene JSON con `type`, `permissionId` y `qrToken`. El respaldo manual usa:

```text
permissionId|qrToken
```

## Acceso por rol

| Cuenta | Acción |
| --- | --- |
| `technical` | Selecciona estudiantes, crea permisos y valida QR |
| `teacher` | Selecciona estudiantes y crea `permission_requests` pendientes |
| Organizador | Crea `permission_requests` pendientes |
| `student` | Consulta únicamente sus permisos y presenta su QR |

La ruta `/permissions/validate` y su tarjeta están limitadas a `technical`, que representa al personal encargado en el esquema actual. La protección de Flutter mejora la experiencia, pero la protección real depende de las reglas de Firestore.

## Comportamiento de validación

| Condición | Resultado visual |
| --- | --- |
| Token correcto, estado `active` y hora dentro del intervalo | VÁLIDO, verde |
| Hora igual o posterior a `validUntil`, o estado `expired` | EXPIRADO, rojo |
| Token distinto o formato ajeno a NEXO 360 | NO AUTORIZADO, rojo |
| Documento inexistente | NO ENCONTRADO, rojo |
| Estado `cancelled`, `used` u otro no activo | INVÁLIDO, rojo |
| Hora anterior a `validFrom` | AÚN NO INICIA, amarillo |

## Compatibilidad de cámara

- Android, iOS y Web: escáner disponible.
- Windows y Linux: se muestra el ingreso manual confiable.
- En Web se debe ejecutar en `localhost` o HTTPS y aceptar el permiso de cámara del navegador.
- Si la cámara falla durante la presentación, copie el código manual desde la pantalla del estudiante.

## Límite consciente del prototipo

La validación se ejecuta en el cliente y el estudiante puede leer su propio `qrToken` para poder mostrar el QR. Es adecuado para la demostración, no para producción. Una versión productiva debería validar el token y la hora en un backend confiable (por ejemplo, Cloud Functions), registrar cada escaneo, aplicar App Check y rotar o firmar los tokens.
