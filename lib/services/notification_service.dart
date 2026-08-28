import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Servicio interno (sin dependencias externas de pago) para programar
/// recordatorios de citas mediante notificaciones locales del dispositivo.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Debe llamarse una sola vez, antes de runApp().
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Ajusta la zona horaria local a Colombia. Si luego detectas la zona
    // real del dispositivo, reemplaza este valor fijo.
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

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

  /// Pide permiso de notificaciones en Android 13+.
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Programa el recordatorio de una cita 24h antes de [appointmentDate].
  /// Si faltan menos de 24h, se notifica de inmediato.
  /// [bookingId] debe ser único por cita (úsalo para poder cancelarla luego).
  Future<void> scheduleBookingReminder({
    required int bookingId,
    required String serviceName,
    required DateTime appointmentDate,
  }) async {
    if (!_initialized) await init();

    var reminderDate = appointmentDate.subtract(const Duration(hours: 24));
    final now = DateTime.now();
    if (reminderDate.isBefore(now)) {
      reminderDate = now.add(const Duration(seconds: 5));
    }

    await _plugin.zonedSchedule(
      bookingId,
      'Recordatorio de cita — Driven Yield',
      'Tu cita de "$serviceName" es el ${_formatDate(appointmentDate)} a las ${_formatTime(appointmentDate)}',
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

  /// Cancela el recordatorio de una cita (por ejemplo si el cliente la cancela).
  Future<void> cancelBookingReminder(int bookingId) => _plugin.cancel(bookingId);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
