import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Servicio interno para programar y enviar notificaciones locales
/// de recordatorio de citas (notificaciones previas de 24h y horas antes).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Debe llamarse una sola vez en el arranque de la app.
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Bogota'));
    } catch (_) {
      // Si falla la ubicación específica, continuar con zona local por defecto
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'bookings_channel',
      'Recordatorios de citas',
      description: 'Notificaciones de recordatorio para citas de Driven Yield',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Pide permiso de notificaciones en Android 13+ (API 33+).
  Future<bool?> requestPermissions() async {
    if (!_initialized) await init();
    return await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Muestra una notificación inmediata de confirmación o resultado al usuario.
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bookings_channel',
          'Recordatorios de citas',
          channelDescription: 'Notificaciones de recordatorio para citas de Driven Yield',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Alerta local inmediata de éxito o error al registrar una cita.
  Future<void> showBookingResult({
    required bool success,
    required String message,
  }) async {
    if (!_initialized) await init();

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      success ? '¡Cita Registrada! — Driven Yield' : 'Error al registrar cita',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bookings_channel',
          'Recordatorios de citas',
          channelDescription: 'Notificaciones de recordatorio para citas de Driven Yield',
          importance: success ? Importance.high : Importance.max,
          priority: success ? Priority.high : Priority.max,
        ),
      ),
    );
  }

  /// Programa un recordatorio para una cita con [hoursBefore] horas de antelación.
  /// Si la fecha con antelación ya pasó (ej. la cita es en menos de 24h), se programa a los 5 segundos.
  Future<void> scheduleBookingReminder({
    required int bookingId,
    required String serviceName,
    required DateTime appointmentDate,
    int hoursBefore = 24,
  }) async {
    if (!_initialized) await init();

    var reminderDate = appointmentDate.subtract(Duration(hours: hoursBefore));
    final now = DateTime.now();
    if (reminderDate.isBefore(now)) {
      reminderDate = now.add(const Duration(seconds: 5));
    }

    final antelacionTexto = hoursBefore >= 24 ? 'el día anterior' : '$hoursBefore horas antes';

    await _plugin.zonedSchedule(
      bookingId,
      'Recordatorio de Cita — Driven Yield',
      'Tu cita de "$serviceName" es el ${_formatDate(appointmentDate)} a las ${_formatTime(appointmentDate)} ($antelacionTexto).',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bookings_channel',
          'Recordatorios de citas',
          channelDescription: 'Notificaciones de recordatorio para citas de Driven Yield',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Programa múltiples recordatorios (por defecto: 24h antes el día anterior Y 2h antes el día de la cita).
  Future<void> scheduleMultipleBookingReminders({
    required int bookingId,
    required String serviceName,
    required DateTime appointmentDate,
    List<int> hoursBeforeList = const [24, 2],
  }) async {
    if (!_initialized) await init();

    bool scheduledAny = false;
    for (int i = 0; i < hoursBeforeList.length; i++) {
      final hoursBefore = hoursBeforeList[i];
      final notificationId = bookingId * 10 + i;

      final reminderDate = appointmentDate.subtract(Duration(hours: hoursBefore));
      final now = DateTime.now();

      if (reminderDate.isBefore(now)) {
        continue;
      }

      scheduledAny = true;
      final labelHours = hoursBefore >= 24
          ? 'el día anterior (${(hoursBefore / 24).round()}d antes)'
          : '$hoursBefore h antes';

      await _plugin.zonedSchedule(
        notificationId,
        'Recordatorio de Cita — Driven Yield',
        'Recordatorio: Tu cita de "$serviceName" es el ${_formatDate(appointmentDate)} a las ${_formatTime(appointmentDate)} ($labelHours).',
        tz.TZDateTime.from(reminderDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bookings_channel',
            'Recordatorios de citas',
            channelDescription: 'Notificaciones de recordatorio para citas de Driven Yield',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Si no se pudo agendar ninguna notificación previa (porque la cita es muy pronto),
    // programar un recordatorio inmediato a los 5 segundos.
    if (!scheduledAny) {
      await scheduleBookingReminder(
        bookingId: bookingId,
        serviceName: serviceName,
        appointmentDate: appointmentDate,
        hoursBefore: 24,
      );
    }
  }

  /// Cancela los recordatorios de una cita (si la cita fue cancelada).
  Future<void> cancelBookingReminder(int bookingId) async {
    await _plugin.cancel(bookingId);
    await _plugin.cancel(bookingId * 10);
    await _plugin.cancel(bookingId * 10 + 1);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
