import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notificacion_service.dart';

/// Registra el token del dispositivo para push (FCM) y muestra el aviso
/// cuando llega un mensaje con la app abierta en primer plano.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localPlugin.initialize(const InitializationSettings(android: androidSettings));

    await _registerToken();
    _messaging.onTokenRefresh.listen((_) => _registerToken());

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _registerToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;

    await Supabase.instance.client.from('dispositivo_push').upsert({
      'id_usuario': NotificacionService.currentUserId,
      'token': token,
      'plataforma': Platform.isIOS ? 'ios' : 'android',
    }, onConflict: 'token');
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cita_push_channel',
          'Notificaciones de citas',
          channelDescription: 'Avisos push cuando se registra o actualiza una cita',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
