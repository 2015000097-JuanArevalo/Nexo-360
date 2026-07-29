import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class EmailService {
  bool get configured => AppConfig.emailWebhookUrl.isNotEmpty;

  Future<void> sendRegistrationDecision({
    required String email,
    required String name,
    required String eventName,
    required String status,
    required String trackingCode,
  }) async {
    if (!configured) return;
    final response = await http.post(
      Uri.parse(AppConfig.emailWebhookUrl),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'secret': AppConfig.emailWebhookSecret,
        'email': email,
        'name': name,
        'eventName': eventName,
        'status': status,
        'trackingCode': trackingCode,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('El servicio de correo respondió ${response.statusCode}.');
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['ok'] != true) {
      throw StateError('El servicio de correo rechazó la solicitud: ${response.body}');
    }
  }
}
