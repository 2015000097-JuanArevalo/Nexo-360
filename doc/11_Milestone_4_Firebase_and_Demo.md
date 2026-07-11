# Milestone 4 — Configuración Firebase y guion de demostración

## 1. Instalar dependencias

Desde `Nexo-360/app`:

```powershell
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Las dependencias nuevas son `qr_flutter` para generar el código y `mobile_scanner` para leerlo.

## 2. Confirmar perfiles de prueba

En Firebase Authentication y en `users/{uid}` deben existir por lo menos:

- Una cuenta activa con `accountType: "technical"`.
- Una cuenta activa con `accountType: "teacher"`.
- Una cuenta activa con `accountType: "student"`.

El ID del documento `users/{uid}` debe ser exactamente el UID de Authentication. El estudiante necesita como mínimo `uid`, `displayName`, `email`, `accountType: "student"`, `status: "active"`, `classId` y los demás campos establecidos en `app/tool/demo_user_profiles.json`.

## 3. Desplegar las reglas

El archivo `app/firestore.rules` ya integra las reglas entregadas en Milestone 3 con la validación de `permissions` y `permission_requests`.

### Opción A — Firebase CLI

Desde `Nexo-360/app`:

```powershell
firebase login
firebase use TU_PROJECT_ID
firebase deploy --only firestore:rules
```

Si el proyecto todavía no tiene configuración CLI:

```powershell
firebase init firestore
```

Cuando pregunte por el archivo de reglas, escriba `firestore.rules`. No reemplace el archivo entregado por la plantilla generada.

### Opción B — Firebase Console

1. Abra Firestore Database → Reglas.
2. Copie todo `app/firestore.rules`.
3. Pegue, publique y espere la confirmación.

La consulta actual funciona sin índice compuesto porque ordena en Flutter. El archivo `firestore.indexes.json` también quedó preparado con `studentId + validUntil` para una futura consulta ordenada en el servidor. Puede desplegarlo con `firebase deploy --only firestore:indexes`.

## 4. Cámara

Ya se incluyeron:

- Android: permiso `android.permission.CAMERA`.
- iOS: `NSCameraUsageDescription`.
- Web: use `localhost` o un sitio HTTPS y acepte el permiso del navegador.

En Windows use la entrada manual; `mobile_scanner` no ofrece cámara para Windows en esta configuración.

## 5. Prueba completa

### Caso válido

1. Inicie sesión como técnico.
2. Abra Permisos → Crear permiso.
3. Seleccione el estudiante, escriba motivo y destino.
4. Use un inicio anterior a la hora actual y un vencimiento posterior.
5. Guarde y conserve el código manual mostrado.
6. Cierre sesión e ingrese como estudiante: el permiso y el QR deben aparecer.
7. Ingrese otra vez como técnico, abra Validar QR y escanee o pegue el código.
8. Debe mostrarse **VÁLIDO** en verde.

### Caso expirado

1. Como técnico, cree otro permiso con inicio y vencimiento en el pasado. El selector permite fechas de hasta 30 días atrás.
2. Valide ese código.
3. Debe mostrarse **EXPIRADO**.

### Caso no autorizado

1. Copie un código manual real.
2. Cambie el último carácter del token, sin cambiar el ID.
3. Valide el código modificado.
4. Debe mostrarse **NO AUTORIZADO**.

### Caso no encontrado

Pegue un código como el siguiente:

```text
permiso-inexistente|token-de-prueba-con-longitud-suficiente
```

Debe mostrarse **NO ENCONTRADO**.

### Caso cancelado

1. En Firestore Console abra el documento del permiso de demostración.
2. Cambie `status` a `cancelled` y `updatedAt` a un timestamp actual.
3. Vuelva a validarlo.
4. Debe mostrarse **INVÁLIDO**.

La consola administrativa de Firebase no depende de las reglas del cliente. En la app, una actualización equivalente está reservada al técnico y debe usar un timestamp del servidor.

## 6. Formulario docente

Al guardar como docente no se crea un permiso activo: se crea `permission_requests/{requestId}` con estado `pending`. Esto es intencional y coincide con las reglas actuales. Para la demostración del QR use la cuenta técnica para crear el permiso real; la bandeja de aprobación completa pertenece a un milestone posterior.

## 7. Solución rápida de errores

| Error | Revisión concreta |
| --- | --- |
| `permission-denied` al cargar estudiantes | Perfil activo; reglas publicadas; consulta con `accountType == student` |
| `permission-denied` al crear | La cuenta debe ser `technical`; estudiante activo; timestamps del servidor |
| El estudiante no ve el permiso | El `studentId` debe ser exactamente su UID y el perfil debe ser `student/active` |
| Cámara negra o denegada | Conceda permiso al navegador/app o use el código manual |
| QR da no autorizado | Copie otra vez el código completo sin espacios ni caracteres eliminados |
| Web conserva código viejo | Detenga la app, ejecute `flutter clean`, `flutter pub get` y vuelva a iniciar |
