# NEXO 360 - Reestructuración Final de App, Firebase y Permisos

Este paquete contiene la versión final corregida de la reestructuración de NEXO 360.

## Archivos incluidos

1. `01_Reestructuracion_Final_App.md`  
   Explica la estructura final de la app en tres secciones: Portal Escolar, Permisos y Eventos.

2. `02_Base_Datos_Firestore_Final.md`  
   Define cómo debe quedar la base de datos en Firestore, incluyendo usuarios, permisos, solicitudes y eventos.

3. `03_Instrucciones_Cambios_Firebase.md`  
   Explica paso a paso qué debes modificar en Firebase tomando como base la versión que ya habías hecho.

4. `app/firestore.rules`
   Reglas finales de Firestore para esta versión.

5. `doc/04_Milestone_1_Design_Freeze.md`
   Congela pantallas, navegación, acceso por rol y guía visual.

6. `doc/05_Prototype_Setup_and_Firebase.md`
   Explica cómo ejecutar Flutter y configurar las cuentas, reglas e índices de Firebase.

## Entrega de Milestone 1

`app/lib` incluye una interfaz responsive con navegación inferior en móvil y lateral en pantallas amplias, dashboard por rol, formularios de prototipo y componentes reutilizables. Consulta `doc/04_Milestone_1_Design_Freeze.md` antes de conectar los flujos a Firestore.

## Decisiones finales importantes

- Solo existen tres tipos de cuenta principales: `technical`, `teacher` y `student`.
- Los roles de Eventos son independientes: `none`, `guest`, `organizer`, `commissioner`.
- El rol de Eventos no cambia permisos dentro del Portal Escolar.
- Los técnicos administran permisos directamente.
- Docentes y organizadores solo envían solicitudes de permisos.
- Los permisos solo se asignan a estudiantes.
- Los docentes no tienen QR de permiso.
- Estudiantes y docentes pueden leer un QR para consultar si un estudiante tiene permiso.
- Ya no existe una opción llamada `validate_qr` dentro de Eventos.
