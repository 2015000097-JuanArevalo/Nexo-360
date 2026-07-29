# Alternativa gratuita para archivos

## Decisión aplicada en esta entrega

La aplicación se entrega con `STORAGE_ENABLED=false`. Los botones para archivos, PDF, presentaciones, entregas y galería permanecen visibles, pero muestran **“Storage/nube en mantenimiento”**. Los enlaces externos continúan funcionando.

Esta decisión evita vincular una tarjeta al proyecto Firebase y evita mezclar documentos escolares privados con un servicio externo sin haber configurado primero sus políticas de acceso.

## Opción gratuita disponible: Supabase Storage

Supabase ofrece actualmente un plan gratuito con 1 GB de archivos, 5 GB de egreso almacenado en caché y un tamaño máximo de 50 MB por archivo. El proyecto gratuito puede pausarse después de una semana de inactividad.

No viene activado por defecto en NEXO 360 porque:

- crea un segundo backend además de Firebase;
- requiere configurar buckets privados y políticas RLS;
- los usuarios de Firebase no son reconocidos automáticamente por Supabase;
- una integración rápida con un bucket público expondría tareas, autorizaciones y datos de estudiantes;
- se debe decidir qué documentos son públicos y cuáles requieren URLs firmadas.

## Uso seguro recomendado

Mientras no puedas pagar Firebase Storage:

1. Usa enlaces de Google Drive, OneDrive o YouTube únicamente para materiales públicos o institucionales.
2. No coloques tareas privadas, autorizaciones firmadas ni datos personales en enlaces públicos.
3. Mantén las entregas estudiantiles por enlace desactivadas para cursos que exijan privacidad.
4. Conserva los botones de archivos en mantenimiento, como ya está implementado.

## Activación futura

Cuando decidas usar Supabase, crea un proyecto, un bucket privado y un pequeño backend que valide el ID token de Firebase antes de generar URLs firmadas. No pegues una clave de servicio en Flutter ni en JavaScript público. Esa integración debe probarse con reglas de privacidad antes de activarla.
