# Milestone 6 — Registro y prioridad de problemas

## Regla de clasificación

- **Critical:** impide iniciar sesión, crear/consultar datos o completar una demostración principal.
- **Medium:** el flujo termina, pero existe una limitación o problema visible.
- **Minor:** detalle cosmético o módulo secundario fuera del flujo crítico.

## Problemas encontrados durante la integración

| ID | Categoría | Problema | Estado | Acción |
| --- | --- | --- | --- | --- |
| C-01 | Critical | No existía creación general de eventos | Resuelto | Formulario, ruta, servicio y reglas por rol |
| C-02 | Critical | Solicitudes de permisos no tenían aprobación funcional | Resuelto | Bandeja técnica y creación atómica del permiso |
| C-03 | Critical | Tarjetas de eventos e inscripciones eran datos estáticos | Resuelto | Streams y escrituras reales de Firestore |
| M-01 | Medium | Eventos antiguos sin `date`/`capacity` mostraban 1969 y 0 | Resuelto visualmente | Mostrar “por confirmar”; migrar los documentos después |
| M-02 | Medium | `capacity` no se descuenta de forma transaccional | Conocido | No bloquea la demo; usar Cloud Function en producción |
| M-03 | Medium | Consulta pública usa el ID aleatorio como código | Conocido | No permite listados; usar backend/token adicional en producción |
| P-01 | Minor | Inventario, mapa, comités, notas y asistencia no están completos | Aceptado | Marcados explícitamente como Prototipo y sin enlaces rotos |

## Registro de ejecución

Agregue aquí únicamente problemas observados al ejecutar `doc/15_Milestone_6_Integration_and_Testing.md`.

| ID | Fecha/hora | Caso | Categoría | Descripción | Evidencia | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| | | | Critical / Medium / Minor | | | Abierto |

## Orden de corrección

1. Cualquier Critical abierto.
2. Medium que sea visible durante la ruta exacta de presentación.
3. Minor solo si el build estable ya está generado y respaldado.

No cambie diseño, dependencias ni reglas el día de la presentación salvo que resuelvan un Critical reproducible.
