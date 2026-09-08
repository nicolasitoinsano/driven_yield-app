import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driven_yield/models/app_user.dart';
import 'package:driven_yield/services/auth_service.dart';

void main() {
  group('AppUser Model Tests', () {
    test('Identifies admin role correctly', () {
      final admin = AppUser(
        id: 20,
        name: 'Admin Driven',
        email: 'admin@drivenytield.com',
        role: 'admin',
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.isClient, isFalse);
    });

    test('Identifies client role correctly', () {
      final client = AppUser(
        id: 2,
        name: 'Pedro Lopez',
        email: 'pedro@email.com',
        role: 'cliente',
      );
      expect(client.isAdmin, isFalse);
      expect(client.isClient, isTrue);
    });
  });

  group('AuthService Password Verification Tests', () {
    test(r'Verifies Bcrypt hashes ($2a$ and $2b$ formats)', () {
      final salt = BCrypt.gensalt();
      final hash2a = BCrypt.hashpw('miPasswordSeguro123', salt);
      expect(AuthService.verifyPassword('miPasswordSeguro123', hash2a), isTrue);
      expect(AuthService.verifyPassword('passwordIncorrecto', hash2a), isFalse);

      // Simular formato $2b$ típico de Node.js / Python
      final hash2b = hash2a.replaceFirst(r'$2a$', r'$2b$');
      expect(AuthService.verifyPassword('miPasswordSeguro123', hash2b), isTrue);
      expect(AuthService.verifyPassword('erroneo', hash2b), isFalse);
    });

    test('Fallback matches exact plain text for test seed data', () {
      expect(AuthService.verifyPassword('hashed_password_1', 'hashed_password_1'), isTrue);
      expect(AuthService.verifyPassword('otra_clave', 'hashed_password_1'), isFalse);
    });
  });

  group('AuthService Session Management Tests', () {
    test('Manages session state and logout', () {
      expect(AuthService.isAuthenticated, isFalse);
      expect(AuthService.isAdmin, isFalse);

      final admin = AppUser(
        id: 20,
        name: 'Admin Test',
        email: 'admin@test.com',
        role: 'admin',
      );
      AuthService.setCurrentUser(admin);

      expect(AuthService.isAuthenticated, isTrue);
      expect(AuthService.isAdmin, isTrue);
      expect(AuthService.currentUserId, equals(20));

      AuthService.logout();
      expect(AuthService.isAuthenticated, isFalse);
      expect(AuthService.isAdmin, isFalse);
      expect(AuthService.currentUserId, isNull);
    });
  });

  group('AuthService Colombian Phone Validation Tests', () {
    test('Accepts valid Colombian mobile numbers (starts with 3, min 10 digits)', () {
      expect(AuthService.isValidColombianPhone('3001234567'), isTrue);
      expect(AuthService.isValidColombianPhone('312 345 6789'), isTrue);
      expect(AuthService.isValidColombianPhone('320-111-2233'), isTrue);
      expect(AuthService.isValidColombianPhone('+573159998877'), isTrue);
      expect(AuthService.isValidColombianPhone('3501234567'), isTrue);
    });

    test('Rejects invalid phone numbers', () {
      // Menos de 10 dígitos
      expect(AuthService.isValidColombianPhone('300123456'), isFalse);
      expect(AuthService.isValidColombianPhone('12345'), isFalse);
      // No empieza por 3 (números fijos o extranjeros)
      expect(AuthService.isValidColombianPhone('2001234567'), isFalse);
      expect(AuthService.isValidColombianPhone('6012345678'), isFalse);
      expect(AuthService.isValidColombianPhone('4001234567'), isFalse);
      // Vacío o letras
      expect(AuthService.isValidColombianPhone(''), isFalse);
      expect(AuthService.isValidColombianPhone('abcdefghij'), isFalse);
    });
  });

  group('AuthService Vehicle Plate Validation Tests', () {
    test('Accepts valid Colombian plates (3 letters and 3 numbers)', () {
      expect(AuthService.isValidPlate('ABC123'), isTrue);
      expect(AuthService.isValidPlate('xyz789'), isTrue);
      expect(AuthService.isValidPlate('DEF-456'), isTrue);
      expect(AuthService.isValidPlate('KLM 098'), isTrue);
    });

    test('Explicitly rejects 000000 and invalid formats', () {
      // Rechazo explícito de 000000
      expect(AuthService.isValidPlate('000000'), isFalse);
      // Formato invertido (3 números y 3 letras)
      expect(AuthService.isValidPlate('123ABC'), isFalse);
      // Todo letras
      expect(AuthService.isValidPlate('AAAAAA'), isFalse);
      // Todo números
      expect(AuthService.isValidPlate('123456'), isFalse);
      // Longitud incorrecta
      expect(AuthService.isValidPlate('AB123'), isFalse);
      expect(AuthService.isValidPlate('ABCD12'), isFalse);
      expect(AuthService.isValidPlate('ABC1234'), isFalse);
      // Vacío
      expect(AuthService.isValidPlate(''), isFalse);
    });
  });

  group('AuthService Email Validation Tests', () {
    test('Accepts valid email addresses with domains', () {
      expect(AuthService.isValidEmail('mateo@gmail.com'), isTrue);
      expect(AuthService.isValidEmail('juan.perez@empresa.com.co'), isTrue);
      expect(AuthService.isValidEmail('cliente123@drivenyield.com'), isTrue);
      expect(AuthService.isValidEmail('admin@taller.co'), isTrue);
    });

    test('Rejects invalid email addresses (including missing domain or just @)', () {
      // El caso específico reportado por el usuario: solo nombre y arroba sin dominio
      expect(AuthService.isValidEmail('mateo@'), isFalse);
      expect(AuthService.isValidEmail('usuario@'), isFalse);
      // Sin arroba
      expect(AuthService.isValidEmail('mateo'), isFalse);
      // Sin usuario
      expect(AuthService.isValidEmail('@gmail.com'), isFalse);
      // Sin TLD o TLD inválido
      expect(AuthService.isValidEmail('mateo@dominio'), isFalse);
      expect(AuthService.isValidEmail('mateo@dominio.'), isFalse);
      expect(AuthService.isValidEmail('mateo@dominio.c'), isFalse);
      // Vacío
      expect(AuthService.isValidEmail(''), isFalse);
    });

    test('Verifies admin seed credentials hash', () {
      final hash = r'$2b$12$x8AdFx3BrOn4ohHoA.WovudASKNXpekv/u2xiYZSDXbY4/DeKu4r.';
      expect(AuthService.verifyPassword('admin123', hash), isTrue);
    });
  });
}
