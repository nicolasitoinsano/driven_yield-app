import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/managed_service.dart';
import 'auth_service.dart';

class SupabaseService {
  static final _supabase = Supabase.instance.client;

  static int get _currentUserId => AuthService.currentUserId ?? 1;

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

  /// Crea la cita y devuelve la fila insertada (con `id_cita`) para poder
  /// confirmar que sí quedó registrada. Si Supabase no devuelve la fila
  /// (insert bloqueado por RLS, por ejemplo) lanza un error explícito en
  /// vez de reportar éxito silenciosamente.
  static Future<Map<String, dynamic>> createBooking({
    required int idServicio,
    required DateTime date,
    required String time,
  }) async {
    int vehicleId = 1;
    try {
      final vehicles = await getUserVehicles();
      if (vehicles.isNotEmpty && vehicles.first['id_vehiculo'] != null) {
        vehicleId = int.tryParse(vehicles.first['id_vehiculo'].toString()) ?? 1;
      }
    } catch (_) {}

    final result = await _supabase
        .from('cita')
        .insert({
          'fecha': date.toIso8601String().split('T')[0],
          'hora': '$time:00',
          'estado': 'pendiente',
          'id_usuario': _currentUserId,
          'id_vehiculo': vehicleId,
          'id_servicio': idServicio,
          'notas': 'Reserva desde app móvil',
          'monto': 0.0, // Idealmente enviar el monto
        })
        .select()
        .maybeSingle();

    if (result == null) {
      throw Exception('La cita no se pudo confirmar (sin respuesta de la base de datos).');
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getBookingsForDay(DateTime date, {int? userId}) async {
    final uid = userId ?? AuthService.currentUserId;
    if (uid == null) return [];
    final dateString = date.toIso8601String().split('T')[0];
    return await _supabase
        .from('cita')
        .select('*, servicio(nombre)')
        .eq('fecha', dateString)
        .eq('id_usuario', uid);
  }

  static Future<List<Map<String, dynamic>>> getBookingsForMonth(int year, int month, {int? userId}) async {
    final uid = userId ?? AuthService.currentUserId;
    if (uid == null) return [];
    final start = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final end = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];
    return await _supabase
        .from('cita')
        .select('fecha')
        .gte('fecha', start)
        .lte('fecha', end)
        .eq('id_usuario', uid);
  }

  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    return await _supabase
        .from('cita')
        .select('*, servicio(nombre, precio)')
        .eq('id_usuario', _currentUserId)
        .order('fecha', ascending: false);
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
      return await _supabase.from('vehiculo').select('*').eq('id_usuario', _currentUserId);
    } catch (e) {
      return []; // fallback if table doesn't exist
    }
  }

  static Future<void> addVehicle(String brand, String model, String plate) async {
    await _supabase.from('vehiculo').insert({
      'marca': brand,
      'modelo': model,
      'placa': plate,
      'id_usuario': _currentUserId,
    });
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await _supabase.from('usuario').select('*').eq('id_usuario', _currentUserId).single();
      return res;
    } catch (e) {
      final current = AuthService.currentUser;
      return {
        'nombre': current?.name ?? 'Usuario',
        'telefono': current?.phone ?? '',
        'correo': current?.email ?? '',
      };
    }
  }

  static Future<void> updateUserProfile(String name, String phone) async {
    await _supabase.from('usuario').update({
      'nombre': name,
      'telefono': phone,
    }).eq('id_usuario', _currentUserId);
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
