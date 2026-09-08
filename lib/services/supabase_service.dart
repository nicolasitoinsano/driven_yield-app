import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/app_user.dart';
import '../models/managed_service.dart';
import 'auth_service.dart';

class SupabaseService {
  static final _supabase = Supabase.instance.client;

  static int get _currentUserId => AuthService.currentUserId ?? 1;

  /// Formatea un valor numérico o texto a formato de pesos colombianos (ej. $120,000)
  static String formatPrice(dynamic price) {
    if (price == null) return '\$0';
    final numValue = price is num
        ? price
        : (double.tryParse(price.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0);
    final intVal = numValue.round();
    final formatted = intVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '\$$formatted';
  }

  /// Convierte un string de precio a número decimal
  static double parsePrice(String price) {
    final clean = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  static Future<List<ManagedService>> getServices() async {
    final data = await _supabase.from('servicio').select().order('id_servicio', ascending: true);
    return data.map((json) {
      return ManagedService(
        id: json['id_servicio'].toString(),
        name: json['nombre']?.toString() ?? 'Sin nombre',
        description: json['descripcion']?.toString() ?? json['categoria']?.toString() ?? 'Sin descripción',
        price: formatPrice(json['precio']),
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
    final cleanBrand = brand.trim();
    final cleanModel = model.trim();
    final cleanPlate = AuthService.normalizePlate(plate);

    if (cleanBrand.isEmpty) {
      throw const AuthException('Por favor, ingresa la marca del vehículo.');
    }
    if (!AuthService.isValidPlate(cleanPlate)) {
      throw const AuthException('La placa debe tener 3 letras y 3 números (ej. ABC123). No se permite 000000.');
    }

    await _supabase.from('vehiculo').insert({
      'marca': cleanBrand,
      'modelo': cleanModel,
      'placa': cleanPlate,
      'id_usuario': _currentUserId,
    });
  }

  static Future<void> updateVehicle({
    required int vehicleId,
    required String brand,
    required String model,
    required String plate,
  }) async {
    final cleanBrand = brand.trim();
    final cleanModel = model.trim();
    final cleanPlate = AuthService.normalizePlate(plate);

    if (cleanBrand.isEmpty) {
      throw const AuthException('Por favor, ingresa la marca del vehículo.');
    }
    if (!AuthService.isValidPlate(cleanPlate)) {
      throw const AuthException('La placa debe tener 3 letras y 3 números (ej. ABC123). No se permite 000000.');
    }

    await _supabase.from('vehiculo').update({
      'marca': cleanBrand,
      'modelo': cleanModel,
      'placa': cleanPlate,
    }).eq('id_vehiculo', vehicleId).eq('id_usuario', _currentUserId);
  }

  static Future<void> deleteVehicle(int vehicleId) async {
    await _supabase.from('vehiculo').delete().eq('id_vehiculo', vehicleId).eq('id_usuario', _currentUserId);
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await _supabase.from('usuario').select('*').eq('id_usuario', _currentUserId).single();
      if (res['correo'] == null && res['email'] != null) {
        res['correo'] = res['email'];
      }
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

  static Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = AuthService.normalizePhone(phone);
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      throw const AuthException('Por favor, ingresa tu nombre completo.');
    }
    if (cleanEmail.isEmpty || !AuthService.isValidEmail(cleanEmail)) {
      throw const AuthException('Por favor, ingresa un correo electrónico válido con dominio (ej. usuario@dominio.com).');
    }
    if (cleanPhone.isEmpty || !AuthService.isValidColombianPhone(cleanPhone)) {
      throw const AuthException('El teléfono debe tener mínimo 10 dígitos y empezar por 3 (ej. 3001234567).');
    }

    // Verificar si el correo está en uso por otro usuario
    final existing = await _supabase
        .from('usuario')
        .select('id_usuario')
        .or('email.eq.$cleanEmail,correo.eq.$cleanEmail')
        .neq('id_usuario', _currentUserId)
        .limit(1);
    if (List.from(existing).isNotEmpty) {
      throw const AuthException('Este correo electrónico ya está registrado por otra cuenta.');
    }

    await _supabase.from('usuario').update({
      'nombre': cleanName,
      'telefono': cleanPhone,
      'email': cleanEmail,
      'correo': cleanEmail,
    }).eq('id_usuario', _currentUserId);

    // Mantener la sesión local sincronizada
    final current = AuthService.currentUser;
    if (current != null) {
      AuthService.setCurrentUser(AppUser(
        id: current.id,
        name: cleanName,
        username: current.username,
        email: cleanEmail,
        phone: cleanPhone,
        role: current.role,
      ));
    }
  }

  // --- ADMIN ENDPOINTS ---

  static Future<List<Map<String, dynamic>>> getClients() async {
    final res = await _supabase.from('usuario').select('*').order('id_usuario', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<Map<String, dynamic>> addClient(String name, String email, String phone) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = AuthService.normalizePhone(phone);

    if (cleanName.isEmpty) {
      throw const AuthException('El nombre del cliente no puede estar vacío.');
    }
    if (!AuthService.isValidEmail(cleanEmail)) {
      throw const AuthException('Por favor ingresa un correo electrónico válido con dominio completo.');
    }
    if (!AuthService.isValidColombianPhone(cleanPhone)) {
      throw const AuthException('El teléfono debe tener mínimo 10 dígitos y empezar por 3.');
    }

    final username = cleanEmail.contains('@')
        ? cleanEmail.split('@')[0]
        : cleanName.toLowerCase().replaceAll(' ', '');

    final res = await _supabase.from('usuario').insert({
      'nombre': cleanName,
      'email': cleanEmail,
      'correo': cleanEmail,
      'telefono': cleanPhone,
      'username': username,
      'activo': 1,
    }).select().single();

    return res;
  }

  static Future<void> updateClient(String id, String name, String email, String phone) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = AuthService.normalizePhone(phone);

    if (cleanName.isEmpty) {
      throw const AuthException('El nombre del cliente no puede estar vacío.');
    }
    if (!AuthService.isValidEmail(cleanEmail)) {
      throw const AuthException('Por favor ingresa un correo electrónico válido con dominio completo.');
    }
    if (!AuthService.isValidColombianPhone(cleanPhone)) {
      throw const AuthException('El teléfono debe tener mínimo 10 dígitos y empezar por 3.');
    }

    await _supabase.from('usuario').update({
      'nombre': cleanName,
      'email': cleanEmail,
      'correo': cleanEmail,
      'telefono': cleanPhone,
    }).eq('id_usuario', id);
  }

  static Future<void> deleteClient(String id) async {
    final uid = int.tryParse(id);
    if (uid != null) {
      try {
        await _supabase.from('cita').delete().eq('id_usuario', uid);
      } catch (_) {}
      try {
        await _supabase.from('vehiculo').delete().eq('id_usuario', uid);
      } catch (_) {}
    }
    await _supabase.from('usuario').delete().eq('id_usuario', id);
  }

  static Future<Map<String, dynamic>> addService(
    String name,
    String description,
    String price,
    bool active,
  ) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const AuthException('Por favor ingresa el nombre del servicio.');
    }
    final numPrice = parsePrice(price);

    final res = await _supabase.from('servicio').insert({
      'nombre': cleanName,
      'descripcion': description.trim(),
      'categoria': 'General',
      'precio': numPrice,
      'activo': active ? 1 : 0,
    }).select().single();

    return res;
  }

  static Future<void> updateService(
    String id,
    String name,
    String description,
    String price,
    bool active,
  ) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const AuthException('Por favor ingresa el nombre del servicio.');
    }
    final numPrice = parsePrice(price);

    await _supabase.from('servicio').update({
      'nombre': cleanName,
      'descripcion': description.trim(),
      'precio': numPrice,
      'activo': active ? 1 : 0,
    }).eq('id_servicio', id);
  }

  static Future<void> updateServiceActive(String id, bool active) async {
    await _supabase.from('servicio').update({
      'activo': active ? 1 : 0,
    }).eq('id_servicio', id);
  }

  static Future<void> deleteService(String id) async {
    try {
      await _supabase.from('servicio').delete().eq('id_servicio', id);
    } catch (e) {
      // Si existen citas asociadas en la base de datos, desactivar el servicio
      await _supabase.from('servicio').update({'activo': 0}).eq('id_servicio', id);
    }
  }

  /// Obtiene todas las citas de la base de datos para la administración y métricas
  static Future<List<Map<String, dynamic>>> getAllBookingsAdmin() async {
    final res = await _supabase
        .from('cita')
        .select('*, servicio(nombre, precio), usuario(nombre, email, telefono)')
        .order('fecha', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Actualiza el estado de una cita (ej. confirmada, completada, cancelada)
  static Future<void> updateBookingStatus(int citaId, String status) async {
    await _supabase.from('cita').update({'estado': status}).eq('id_cita', citaId);
  }
}
