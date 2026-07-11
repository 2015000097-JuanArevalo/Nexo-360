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

7. `doc/06_Milestone_2_Application_Foundation.md`
   Documenta sesión centralizada, rutas protegidas, dashboards y componentes reutilizables.

8. `doc/07_Milestone_2_Firebase_Configuration.md`
   Contiene la configuración exacta de las cuentas demo y las verificaciones de Firebase.

9. `doc/08_Milestone_3_School_Portal.md`
   Documenta el flujo funcional de avisos y actividades compartido por docentes y estudiantes.

10. `doc/09_Milestone_3_Firebase_Setup.md`
    Explica las reglas, datos de demostración y prueba completa del Portal Escolar.

11. `doc/10_Milestone_4_QR_Permissions.md`
    Documenta el flujo funcional de permisos, QR, validación y acceso por rol.

12. `doc/11_Milestone_4_Firebase_and_Demo.md`
    Contiene la configuración de Firebase y el guion para demostrar todos los resultados.

## Entrega de Milestone 1

`app/lib` incluye una interfaz responsive con navegación inferior en móvil y lateral en pantallas amplias, dashboard por rol, sesión Firebase, rutas protegidas y componentes reutilizables. Consulta los documentos 06 y 07 para instalar y comprobar Milestone 2.

Milestone 3 conecta `school_announcements` y `school_activities` con Firestore en tiempo real. Consulta los documentos 08 y 09 antes de desplegar las reglas o probar el flujo docente-estudiante.

Milestone 4 conecta `permissions` y `permission_requests`, genera QR reales y permite validarlos por cámara o código manual. Consulta los documentos 10 y 11 antes de desplegar reglas o preparar la presentación.

## Decisiones finales importantes

- Solo existen tres tipos de cuenta principales: `technical`, `teacher` y `student`.
- Los roles de Eventos son independientes: `none`, `guest`, `organizer`, `commissioner`.
- El rol de Eventos no cambia permisos dentro del Portal Escolar.
- Los técnicos administran permisos directamente.
- Docentes y organizadores solo envían solicitudes de permisos.
- Los permisos solo se asignan a estudiantes.
- Los docentes no tienen QR de permiso.
- Docentes y personal técnico validan los QR; el estudiante consulta y presenta únicamente los suyos.
- El personal técnico aprueba o deniega solicitudes pendientes desde una bandeja en tiempo real.
- Ya no existe una opción llamada `validate_qr` dentro de Eventos.
