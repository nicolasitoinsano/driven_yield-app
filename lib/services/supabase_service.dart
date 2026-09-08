import 'package:flutter/foundation.dart';
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

  /// Convierte un string o num de precio a número decimal compatible con moneda colombiana
  static double parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    var s = price.toString().trim().replaceAll(r'$', '').replaceAll(' ', '');
    if (s.contains('.') && s.contains(',')) {
      if (s.indexOf('.') < s.indexOf(',')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (s.contains('.')) {
      final parts = s.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        s = s.replaceAll('.', '');
      }
    } else if (s.contains(',')) {
      final parts = s.split(',');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        s = s.replaceAll(',', '');
      } else {
        s = s.replaceAll(',', '.');
      }
    }
    return double.tryParse(s) ?? 0.0;
  }

  /// Valida que la hora se encuentre dentro del horario de atención permitido (9:00 AM a 9:00 PM)
  static bool isValidOperatingHour(int hour, int minute) {
    if (hour < 9) return false;
    if (hour > 21) return false;
    if (hour == 21 && minute > 0) return false;
    return true;
  }

  /// Valida que la fecha y hora seleccionadas no sean anteriores al momento actual
  static bool isFutureDateTime(DateTime date, int hour, int minute, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final appointmentDateTime = DateTime(date.year, date.month, date.day, hour, minute);
    return appointmentDateTime.isAfter(current);
  }

  /// Consulta si un horario ya se encuentra ocupado por otra cita activa en la misma fecha
  static Future<bool> isTimeSlotBooked(DateTime date, String time, {int? excludeCitaId}) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final formattedTime = time.length == 5 ? '$time:00' : time;
      var query = _supabase
          .from('cita')
          .select('id_cita')
          .eq('fecha', dateString)
          .eq('hora', formattedTime)
          .neq('estado', 'cancelada');
      if (excludeCitaId != null) {
        query = query.neq('id_cita', excludeCitaId);
      }
      final res = await query.limit(1);
      return res.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando disponibilidad de horario: $e');
      return false;
    }
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

  /// Crea la cita y devuelve la fila insertada (con `id_cita`).
  /// Valida:
  /// 1. Horario de atención: 9:00 AM a 9:00 PM.
  /// 2. Citas en el futuro (no antes de la hora actual).
  /// 3. Horarios no repetidos/ocupados.
  /// 4. Guarda uno o varios servicios sumando el monto total.
  static Future<Map<String, dynamic>> createBooking({
    List<ManagedService>? services,
    int? idServicio,
    required DateTime date,
    required String time,
    String? customNotes,
  }) async {
    final timeParts = time.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;

    // 1. Validar horario de atención (9 AM a 9 PM)
    if (!isValidOperatingHour(hour, minute)) {
      throw Exception('Las citas solo se pueden agendar entre las 9:00 AM y las 9:00 PM.');
    }

    // 2. Validar que la fecha y hora no sea pasada
    if (!isFutureDateTime(date, hour, minute)) {
      throw Exception('No se pueden agendar citas antes de la hora actual.');
    }

    // 3. Validar disponibilidad de horario (evitar duplicados a la misma hora)
    final isBooked = await isTimeSlotBooked(date, time);
    if (isBooked) {
      throw Exception('El horario seleccionado ($time) ya se encuentra reservado por otra cita. Por favor selecciona otra hora.');
    }

    // Determinar servicios, monto total y notas
    final List<ManagedService> selectedServices = services ?? [];
    int primaryServiceId = idServicio ?? (selectedServices.isNotEmpty ? int.parse(selectedServices.first.id) : 1);
    double totalAmount = 0.0;
    String notas = customNotes ?? 'Reserva desde app móvil';

    if (selectedServices.isNotEmpty) {
      primaryServiceId = int.parse(selectedServices.first.id);
      totalAmount = selectedServices.fold<double>(0.0, (sum, s) => sum + parsePrice(s.price));
      final serviceNames = selectedServices.map((s) => s.name).join(', ');
      notas = 'Servicios: $serviceNames';
      if (customNotes != null && customNotes.trim().isNotEmpty) {
        notas += ' - $customNotes';
      }
    }

    int vehicleId = 1;
    try {
      final vehicles = await getUserVehicles();
      if (vehicles.isNotEmpty && vehicles.first['id_vehiculo'] != null) {
        vehicleId = int.tryParse(vehicles.first['id_vehiculo'].toString()) ?? 1;
      }
    } catch (_) {}

    final formattedTime = time.length == 5 ? '$time:00' : time;

    final result = await _supabase
        .from('cita')
        .insert({
          'fecha': date.toIso8601String().split('T')[0],
          'hora': formattedTime,
          'estado': 'pendiente',
          'id_usuario': _currentUserId,
          'id_vehiculo': vehicleId,
          'id_servicio': primaryServiceId,
          'notas': notas,
          'monto': totalAmount,
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
        .select('*,servicio(nombre,precio)')
        .eq('id_usuario', _currentUserId)
        .order('fecha', ascending: false);
  }

  static Future<void> updateBookingDate(int citaId, DateTime date, String time) async {
    final timeParts = time.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;

    if (!isValidOperatingHour(hour, minute)) {
      throw Exception('Las citas solo se pueden reprogramar entre las 9:00 AM y las 9:00 PM.');
    }

    if (!isFutureDateTime(date, hour, minute)) {
      throw Exception('No se pueden reprogramar citas antes de la hora actual.');
    }

    final isBooked = await isTimeSlotBooked(date, time, excludeCitaId: citaId);
    if (isBooked) {
      throw Exception('El horario seleccionado ($time) ya se encuentra reservado por otra cita.');
    }

    final formattedTime = time.length == 5 ? '$time:00' : time;
    await _supabase.from('cita').update({
      'fecha': date.toIso8601String().split('T')[0],
      'hora': formattedTime,
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
    try {
      final res = await _supabase
          .from('cita')
          .select('*,servicio(nombre,precio)')
          .order('fecha', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error obteniendo citas: $e');
      return [];
    }
  }

  /// Actualiza el estado de una cita (ej. confirmada, completada, cancelada)
  static Future<void> updateBookingStatus(int citaId, String status) async {
    await _supabase.from('cita').update({'estado': status}).eq('id_cita', citaId);
  }
}
