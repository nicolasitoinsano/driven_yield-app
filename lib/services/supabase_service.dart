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

  static Future<List<Map<String, dynamic>>> getBookingsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final end = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];
    return await _supabase.from('cita').select('fecha').gte('fecha', start).lte('fecha', end);
  }

  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    // Harcoded user 1
    return await _supabase.from('cita').select('*, servicio(nombre, precio)').eq('id_usuario', 1).order('fecha', ascending: false);
  }

  static Future<void> updateBookingDate(int citaId, DateTime date, String time) async {
    await _supabase.from('cita').update({
      'fecha': date.toIso8601String().split('T')[0],
      'hora': '$time:00',
    }).eq('id_cita', citaId);
  }

  static Future<void> cancelBooking(int citaId) async {
    await _supabase.from('cita').update({'estado': 'cancelada'}).eq('id_cita', citaId);
  }

  static Future<List<Map<String, dynamic>>> getUserVehicles() async {
    try {
      return await _supabase.from('vehiculo').select('*').eq('id_usuario', 1);
    } catch (e) {
      return []; // fallback if table doesn't exist
    }
  }

  static Future<void> addVehicle(String brand, String model, String plate) async {
    await _supabase.from('vehiculo').insert({
      'marca': brand,
      'modelo': model,
      'placa': plate,
      'id_usuario': 1,
    });
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await _supabase.from('usuario').select('*').eq('id_usuario', 1).single();
      return res;
    } catch (e) {
      return {'nombre': 'Carlos M.', 'telefono': '300 000 0000', 'correo': 'carlos@ejemplo.com'}; // fallback
    }
  }

  static Future<void> updateUserProfile(String name, String phone) async {
    await _supabase.from('usuario').update({
      'nombre': name,
      'telefono': phone,
    }).eq('id_usuario', 1);
  }

  // --- ADMIN ENDPOINTS ---

  static Future<List<Map<String, dynamic>>> getClients() async {
    return await _supabase.from('usuario').select('*');
  }

  static Future<void> addClient(String name, String email, String phone) async {
    await _supabase.from('usuario').insert({
      'nombre': name,
      'correo': email,
      'telefono': phone,
    });
  }

  static Future<void> updateClient(String id, String name, String email, String phone) async {
    await _supabase.from('usuario').update({
      'nombre': name,
      'correo': email,
      'telefono': phone,
    }).eq('id_usuario', id);
  }

  static Future<void> deleteClient(String id) async {
    await _supabase.from('usuario').delete().eq('id_usuario', id);
  }

  static Future<void> addService(String name, String description, String price, bool active) async {
    // Assuming price is passed as a string like "120,000", clean it up or store as string
    final cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    await _supabase.from('servicio').insert({
      'nombre': name,
      'descripcion': description,
      'precio': cleanPrice.isEmpty ? 0 : double.parse(cleanPrice),
      'activo': active ? 1 : 0,
    });
  }

  static Future<void> updateService(String id, String name, String description, String price, bool active) async {
    final cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    await _supabase.from('servicio').update({
      'nombre': name,
      'descripcion': description,
      'precio': cleanPrice.isEmpty ? 0 : double.parse(cleanPrice),
      'activo': active ? 1 : 0,
    }).eq('id_servicio', id);
  }

  static Future<void> deleteService(String id) async {
    await _supabase.from('servicio').delete().eq('id_servicio', id);
  }
}
