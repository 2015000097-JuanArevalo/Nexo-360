# NEXO 360 - Reestructuración App + Firebase

Este paquete contiene la nueva propuesta de estructura para NEXO 360.

## Archivos incluidos

- `01_Reestructuracion_General_App.md`
- `02_Base_Datos_Firestore_Propuesta.md`
- `03_Plan_Migracion_Firebase.md`
- `firestore.rules`

## Decisión principal

La app se divide en:

1. Portal Escolar
2. Permisos
3. Eventos

Ahora solo existen tres tipos principales de cuenta:

- `technical`
- `teacher`
- `student`

Y los roles de la sección Eventos se guardan en:

- `eventRole`
- `eventPermissions`
