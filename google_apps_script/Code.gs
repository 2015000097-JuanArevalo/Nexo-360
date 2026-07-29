/**
 * NEXO 360 - Webhook gratuito para correos de inscripción.
 * 1. Cambia SECRET por una cadena larga y aleatoria.
 * 2. Implementa como Aplicación web, ejecutando como tú.
 * 3. Acceso: Cualquier persona.
 * 4. Usa la URL y el mismo secreto al compilar la app.
 */
const SECRET = 'CAMBIA-ESTE-SECRETO-LARGO-Y-ALEATORIO';

function doPost(e) {
  try {
    const payload = JSON.parse(e.postData.contents || '{}');
    if (!payload.secret || payload.secret !== SECRET) {
      return json_({ ok: false, error: 'unauthorized' }, 403);
    }

    const email = String(payload.email || '').trim();
    const name = String(payload.name || 'Participante').trim();
    const eventName = String(payload.eventName || 'Evento NEXO 360').trim();
    const status = String(payload.status || 'pending').trim();
    const trackingCode = String(payload.trackingCode || '').trim();
    if (!email || !email.includes('@')) {
      return json_({ ok: false, error: 'invalid_email' }, 400);
    }

    const labels = {
      approved: 'APROBADA',
      reserved: 'EN RESERVA',
      rejected: 'RECHAZADA',
      pending: 'PENDIENTE'
    };
    const label = labels[status] || status.toUpperCase();
    const subject = `NEXO 360 · Inscripción ${label} · ${eventName}`;
    const body = [
      `Hola ${name},`,
      '',
      `El estado de tu inscripción para “${eventName}” es: ${label}.`,
      trackingCode ? `Código de seguimiento: ${trackingCode}` : '',
      '',
      'Puedes consultar el estado en la página pública de NEXO 360.',
      '',
      'Atentamente,',
      'Equipo NEXO 360'
    ].filter(Boolean).join('\n');

    MailApp.sendEmail({ to: email, subject, body, name: 'NEXO 360' });
    return json_({ ok: true, remainingQuota: MailApp.getRemainingDailyQuota() }, 200);
  } catch (error) {
    return json_({ ok: false, error: String(error) }, 500);
  }
}

function doGet() {
  return json_({ ok: true, service: 'NEXO 360 email webhook' }, 200);
}

function json_(value, status) {
  // Apps Script ContentService no permite fijar el status HTTP directamente.
  // El campo status queda en la respuesta para diagnóstico.
  value.status = status;
  return ContentService
    .createTextOutput(JSON.stringify(value))
    .setMimeType(ContentService.MimeType.JSON);
}
