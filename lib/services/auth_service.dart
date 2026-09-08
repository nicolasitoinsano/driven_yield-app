import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static final _supabase = Supabase.instance.client;
  static AppUser? _currentUser;

  static AppUser? get currentUser => _currentUser;
  static int? get currentUserId => _currentUser?.id;
  static bool get isAuthenticated => _currentUser != null;
  static bool get isAdmin => _currentUser?.isAdmin ?? false;

  static void setCurrentUser(AppUser? user) {
    _currentUser = user;
  }

  static void logout() {
    _currentUser = null;
  }

  /// Verifica si la contraseña coincide con el hash almacenado (Bcrypt o texto claro fallback)
  static bool verifyPassword(String plainPassword, String storedHash) {
    final cleanInput = plainPassword.trim();
    final cleanHash = storedHash.trim();

    // Fallback para datos de prueba con texto plano
    if (cleanInput == cleanHash) {
      return true;
    }

    // Normalizar hash Bcrypt: en PHP/Node a veces se almacena como $2b$ o $2y$, Dart bcrypt usa $2a$
    String normalizedHash = cleanHash;
    if (normalizedHash.startsWith(r'$2b$') || normalizedHash.startsWith(r'$2y$')) {
      normalizedHash = r'$2a$' + normalizedHash.substring(4);
    }

    try {
      if (normalizedHash.startsWith(r'$2a$')) {
        return BCrypt.checkpw(cleanInput, normalizedHash);
      }
    } catch (e) {
      debugPrint('Error verificando hash Bcrypt: $e');
    }

    return false;
  }

  /// Inicia sesión validando credenciales contra Supabase.
  /// Si [requireAdmin] es true, exige que el usuario posea rol de Administrador.
  static Future<AppUser> login({
    required String identifier,
    required String password,
    bool requireAdmin = false,
  }) async {
    final cleanId = identifier.trim();
    final cleanPass = password.trim();

    if (cleanId.isEmpty) {
      throw const AuthException('Por favor, ingresa tu correo electrónico o usuario.');
    }
    if (cleanPass.isEmpty) {
      throw const AuthException('Por favor, ingresa tu contraseña.');
    }

    // 1. Buscar en la tabla `usuario`
    List<Map<String, dynamic>> userRows = [];
    try {
      final res = await _supabase
          .from('usuario')
          .select('*')
          .or('email.eq.$cleanId,correo.eq.$cleanId,username.eq.$cleanId');
      userRows = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error consultando tabla usuario: $e');
    }

    AppUser? authenticatedUser;

    for (final row in userRows) {
      final storedHash = row['contrasena']?.toString() ?? '';
      if (storedHash.isNotEmpty && verifyPassword(cleanPass, storedHash)) {
        // Determinar rol
        final rawRole = row['rol']?.toString().toLowerCase().trim() ?? '';
        final email = (row['email'] ?? row['correo'] ?? '').toString().toLowerCase();
        final username = (row['username'] ?? '').toString().toLowerCase();

        bool isUserAdmin = rawRole == 'admin' ||
            username == 'admin123' ||
            username.contains('admin') ||
            email == 'admin@drivenytield.com' ||
            email == 'admin@drivenyield.com';

        final role = isUserAdmin ? 'admin' : (rawRole.isNotEmpty ? rawRole : 'cliente');
        authenticatedUser = AppUser.fromMap(row, defaultRole: role);
        break;
      }
    }

    // 2. Si no se autenticó en `usuario`, buscar en la tabla `administrador`
    if (authenticatedUser == null) {
      try {
        final adminRows = await _supabase
            .from('administrador')
            .select('*')
            .or('email.eq.$cleanId,nombre.eq.$cleanId');
        for (final row in List<Map<String, dynamic>>.from(adminRows)) {
          final storedHash = row['contrasena']?.toString() ?? '';
          if (storedHash.isNotEmpty && verifyPassword(cleanPass, storedHash)) {
            authenticatedUser = AppUser.fromMap(row, defaultRole: 'admin');
            break;
          }
        }
      } catch (e) {
        debugPrint('Error consultando tabla administrador: $e');
      }
    }

    // Si no se encontró usuario válido o la contraseña no coincidió
    if (authenticatedUser == null) {
      // Revisar si el usuario existía pero la clave fue incorrecta
      if (userRows.isNotEmpty) {
        throw const AuthException('Contraseña incorrecta. Por favor verifica tus datos.');
      }
      throw const AuthException('No existe una cuenta registrada con este correo o usuario.');
    }

    // 3. Validar privilegios de administrador si es requerido
    if (requireAdmin && !authenticatedUser.isAdmin) {
      throw const AuthException('Acceso denegado: Esta cuenta no tiene permisos de administrador.');
    }

    _currentUser = authenticatedUser;
    return authenticatedUser;
  }

  /// Registra un nuevo usuario en la base de datos con contraseña cifrada (Bcrypt)
  static Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehiclePlate,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();
    final cleanPass = password.trim();

    if (cleanName.isEmpty) {
      throw const AuthException('Por favor, ingresa tu nombre completo.');
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw const AuthException('Por favor, ingresa un correo electrónico válido.');
    }
    if (cleanPass.length < 6) {
      throw const AuthException('La contraseña debe contener al menos 6 caracteres.');
    }

    // Verificar duplicado
    try {
      final existing = await _supabase
          .from('usuario')
          .select('id_usuario')
          .or('email.eq.$cleanEmail,correo.eq.$cleanEmail')
          .limit(1);
      if (List.from(existing).isNotEmpty) {
        throw const AuthException('Ya existe una cuenta con este correo electrónico.');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Error verificando existencia de correo: $e');
    }

    // Cifrar contraseña con Bcrypt
    final salt = BCrypt.gensalt(logRounds: 10);
    final hashedPassword = BCrypt.hashpw(cleanPass, salt);

    final String generatedUsername = cleanEmail.split('@')[0];

    // Insertar en la tabla usuario
    final Map<String, dynamic> insertPayload = {
      'nombre': cleanName,
      'email': cleanEmail,
      'correo': cleanEmail,
      'telefono': cleanPhone,
      'username': generatedUsername,
      'contrasena': hashedPassword,
      'activo': 1,
    };

    final userRow = await _supabase
        .from('usuario')
        .insert(insertPayload)
        .select()
        .single();

    final newUser = AppUser.fromMap(userRow, defaultRole: 'cliente');

    // Registrar vehículo si fue provisto
    if (vehicleBrand != null &&
        vehicleBrand.trim().isNotEmpty &&
        vehiclePlate != null &&
        vehiclePlate.trim().isNotEmpty) {
      try {
        await _supabase.from('vehiculo').insert({
          'id_usuario': newUser.id,
          'marca': vehicleBrand.trim(),
          'modelo': (vehicleModel ?? '').trim(),
          'placa': vehiclePlate.trim().toUpperCase(),
        });
      } catch (e) {
        debugPrint('Error registrando vehículo inicial: $e');
      }
    }

    _currentUser = newUser;
    return newUser;
  }
}
