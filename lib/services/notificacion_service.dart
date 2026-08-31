import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.idCita,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  final int id;
  final int idCita;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> json) => AppNotification(
        id: json['id_notificacion'] as int,
        idCita: json['id_cita'] as int,
        titulo: json['titulo'] as String,
        mensaje: json['mensaje'] as String,
        leida: json['leida'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Servicio de notificaciones in-app respaldadas por la tabla `notificacion`
/// en Supabase (creada por el trigger `trg_notificar_nueva_cita`).
class NotificacionService {
  static final _supabase = Supabase.instance.client;

  /// TODO: reemplazar por el id del usuario autenticado real.
  static const int currentUserId = 1;

  static Future<List<AppNotification>> getNotifications() async {
    final data = await _supabase
        .from('notificacion')
        .select()
        .eq('id_usuario', currentUserId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => AppNotification.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Stream en vivo para el badge de no leidas (Supabase Realtime).
  static Stream<List<AppNotification>> watchNotifications() {
    return _supabase
        .from('notificacion')
        .stream(primaryKey: ['id_notificacion'])
        .eq('id_usuario', currentUserId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AppNotification.fromMap).toList());
  }

  static Future<void> markAsRead(int idNotificacion) async {
    await _supabase.from('notificacion').update({'leida': true}).eq('id_notificacion', idNotificacion);
  }

  static Future<void> markAllAsRead() async {
    await _supabase
        .from('notificacion')
        .update({'leida': true})
        .eq('id_usuario', currentUserId)
        .eq('leida', false);
  }
}
