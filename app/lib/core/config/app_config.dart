abstract final class AppConfig {
  static const appName = 'NEXO 360';
  static const storageEnabled = bool.fromEnvironment(
    'STORAGE_ENABLED',
    defaultValue: false,
  );
  static const emailWebhookUrl = String.fromEnvironment(
    'EMAIL_WEBHOOK_URL',
    defaultValue: '',
  );
  static const emailWebhookSecret = String.fromEnvironment(
    'EMAIL_WEBHOOK_SECRET',
    defaultValue: '',
  );
  static const downloadsPage = String.fromEnvironment(
    'DOWNLOADS_PAGE',
    defaultValue: 'https://2015000097-juanarevalo.github.io/Nexo-360/descargas/',
  );
  static const eventsPage = String.fromEnvironment(
    'EVENTS_PAGE',
    defaultValue: 'https://2015000097-juanarevalo.github.io/Nexo-360/eventos/',
  );
}
