import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/managed_service.dart';

class SupabaseService {
  static final _supabase = Supabase.instance.client;

  static Future<List<ManagedService>> getServices() async {
    final data = await _supabase.from('servicio').select();
    return data.map((json) {
      return ManagedService(
        id: json['id_servicio'].toString(),
        name: json['nombre'] ?? 'Sin nombre',
        description: json['descripcion'] ?? json['categoria'] ?? 'Sin descripción',
        price: '\$${json['precio']}',
        active: json['activo'] == 1 || json['activo'] == true,
      );
    }).toList();
  }

  static Future<void> createBooking({
    required int idServicio,
    required DateTime date,
    required String time,
  }) async {
    await _supabase.from('cita').insert({
      'fecha': date.toIso8601String().split('T')[0],
      'hora': '$time:00',
      'estado': 'pendiente',
      'id_usuario': 1, // Usuario quemado por ahora (necesita auth)
      'id_vehiculo': 1, // Vehiculo quemado por ahora
      'id_servicio': idServicio,
      'notas': 'Reserva desde app móvil',
      'monto': 0.0, // Idealmente enviar el monto
    });
  }

  static Future<List<Map<String, dynamic>>> getBookingsForDay(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    return await _supabase.from('cita').select('*, servicio(nombre)').eq('fecha', dateString);
  }
}
