import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';

import '../models/booking_service.dart';

class GoogleCalendarService {
  // Singleton pattern
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  static const _scopes = [calendar.CalendarApi.calendarScope];
  static const String _calendarId = 'primary'; // Se puede reemplazar con el ID del calendario del taller

  calendar.CalendarApi? _calendarApi;

  /// Inicializa la API con las credenciales JSON
  Future<void> initialize(Map<String, dynamic> jsonCredentials) async {
    if (_calendarApi != null) return; // Ya inicializado
    try {
      final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
      final client = await clientViaServiceAccount(credentials, _scopes);
      _calendarApi = calendar.CalendarApi(client);
    } catch (e) {
      debugPrint('Error al inicializar Google Calendar: $e');
    }
  }

  /// Verifica si el servicio está inicializado
  bool get isReady => _calendarApi != null;

  /// Obtiene los eventos (citas) de un día específico
  Future<List<calendar.Event>> getEventsForDay(DateTime date) async {
    if (_calendarApi == null) return [];

    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = await _calendarApi!.events.list(
        _calendarId,
        timeMin: startOfDay,
        timeMax: endOfDay,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      debugPrint('Error al obtener eventos: $e');
      return [];
    }
  }

  /// Crea una nueva cita en el calendario
  Future<bool> createBooking(Booking booking) async {
    if (_calendarApi == null) return false;

    try {
      final startTime = booking.date;
      final endTime = startTime.add(const Duration(hours: 1)); // Suponiendo 1 hora por servicio

      final event = calendar.Event(
        summary: 'Cita Taller: ${booking.serviceName}',
        description: 'Cliente: ${booking.clientName}\nServicio: ${booking.serviceName}\nEstado: ${booking.status}',
        start: calendar.EventDateTime(
          dateTime: startTime.toUtc(),
          timeZone: 'UTC',
        ),
        end: calendar.EventDateTime(
          dateTime: endTime.toUtc(),
          timeZone: 'UTC',
        ),
      );

      await _calendarApi!.events.insert(event, _calendarId);
      return true;
    } catch (e) {
      debugPrint('Error al crear evento: $e');
      return false;
    }
  }
}
