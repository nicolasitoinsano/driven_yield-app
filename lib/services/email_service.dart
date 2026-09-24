import 'dart:convert';

import 'package:http/http.dart' as http;

import 'email_config.dart';

class EmailService {
  static const _endpoint = 'https://api.emailjs.com/api/v1.0/email/send';

  static Future<void> sendBookingConfirmation({
    required String recipientEmail,
    required String clientName,
    required String serviceName,
    required String serviceDescription,
    required String date,
    required String time,
    required String price,
    http.Client? client,
  }) async {
    if (!EmailConfig.isConfigured) {
      throw Exception(
        'Configura EmailConfig con tu Service ID, Template ID y Public Key de EmailJS.',
      );
    }

    final postClient = client ?? http.Client();

    try {
      final response = await postClient.post(
        Uri.parse(_endpoint),
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': EmailConfig.serviceId,
          'template_id': EmailConfig.templateId,
          'user_id': EmailConfig.publicKey,
          'template_params': {
            'to_email': recipientEmail,
            'client_name': clientName,
            'service_name': serviceName,
            'service_description': serviceDescription,
            'booking_date': date,
            'booking_time': time,
            'booking_price': price,
          },
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'No se pudo enviar el correo. Codigo HTTP: ${response.statusCode}. ${response.body}',
        );
      }
    } finally {
      if (client == null) {
        postClient.close();
      }
    }
  }
}
