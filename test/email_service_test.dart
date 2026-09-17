import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:driven_yield/services/email_config.dart';
import 'package:driven_yield/services/email_service.dart';

void main() {
  group('EmailConfig Tests', () {
    test('isConfigured is true and has valid credentials', () {
      expect(EmailConfig.isConfigured, isTrue);
      expect(EmailConfig.serviceId, equals('service_th4jyax'));
      expect(EmailConfig.templateId, equals('template_e0jbu2h'));
      expect(EmailConfig.publicKey, equals('jin3QDN3HSyQi42dm'));
    });
  });

  group('EmailService Tests', () {
    test('sendBookingConfirmation sends correct payload and headers', () async {
      bool called = false;
      final client = MockClient((request) async {
        called = true;
        expect(request.url.toString(), equals('https://api.emailjs.com/api/v1.0/email/send'));
        expect(request.headers['Content-Type'], contains('application/json'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['service_id'], equals(EmailConfig.serviceId));
        expect(body['template_id'], equals(EmailConfig.templateId));
        expect(body['user_id'], equals(EmailConfig.publicKey));

        final params = body['template_params'] as Map<String, dynamic>;
        expect(params['to_email'], equals('cliente@test.com'));
        expect(params['client_name'], equals('Carlos Pérez'));
        expect(params['service_name'], equals('Alineación y Balanceo'));
        expect(params['service_description'], equals('Alineación 3D computarizada'));
        expect(params['booking_date'], equals('20/09/2026'));
        expect(params['booking_time'], equals('10:00'));
        expect(params['booking_price'], equals(r'$120.000'));

        return http.Response('OK', 200);
      });

      await EmailService.sendBookingConfirmation(
        recipientEmail: 'cliente@test.com',
        clientName: 'Carlos Pérez',
        serviceName: 'Alineación y Balanceo',
        serviceDescription: 'Alineación 3D computarizada',
        date: '20/09/2026',
        time: '10:00',
        price: r'$120.000',
        client: client,
      );

      expect(called, isTrue);
    });

    test('sendBookingConfirmation throws exception on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      expect(
        () => EmailService.sendBookingConfirmation(
          recipientEmail: 'cliente@test.com',
          clientName: 'Carlos',
          serviceName: 'Mantenimiento',
          serviceDescription: 'Revisión general',
          date: '21/09/2026',
          time: '14:00',
          price: r'$80.000',
          client: client,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
