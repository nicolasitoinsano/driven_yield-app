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
}
