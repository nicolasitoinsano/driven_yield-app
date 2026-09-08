import 'package:flutter_test/flutter_test.dart';
import 'package:driven_yield/services/supabase_service.dart';
import 'package:driven_yield/models/managed_service.dart';

void main() {
  group('Operating Hours Validation Tests (9:00 AM to 9:00 PM)', () {
    test('Accepts hours strictly within 9:00 AM to 9:00 PM', () {
      expect(SupabaseService.isValidOperatingHour(9, 0), isTrue); // 9:00 AM
      expect(SupabaseService.isValidOperatingHour(9, 30), isTrue); // 9:30 AM
      expect(SupabaseService.isValidOperatingHour(12, 0), isTrue); // 12:00 PM
      expect(SupabaseService.isValidOperatingHour(15, 45), isTrue); // 3:45 PM
      expect(SupabaseService.isValidOperatingHour(20, 59), isTrue); // 8:59 PM
      expect(SupabaseService.isValidOperatingHour(21, 0), isTrue); // 9:00 PM sharp
    });

    test('Rejects hours earlier than 9:00 AM', () {
      expect(SupabaseService.isValidOperatingHour(8, 59), isFalse); // 8:59 AM
      expect(SupabaseService.isValidOperatingHour(8, 0), isFalse); // 8:00 AM
      expect(SupabaseService.isValidOperatingHour(0, 0), isFalse); // Midnight
      expect(SupabaseService.isValidOperatingHour(6, 30), isFalse); // 6:30 AM
    });

    test('Rejects hours later than 9:00 PM', () {
      expect(SupabaseService.isValidOperatingHour(21, 1), isFalse); // 9:01 PM
      expect(SupabaseService.isValidOperatingHour(21, 15), isFalse); // 9:15 PM
      expect(SupabaseService.isValidOperatingHour(22, 0), isFalse); // 10:00 PM
      expect(SupabaseService.isValidOperatingHour(23, 30), isFalse); // 11:30 PM
    });
  });

  group('Past Date and Time Validation Tests', () {
    final fixedNow = DateTime(2026, 9, 8, 14, 30); // 2:30 PM

    test('Accepts future time on the same day', () {
      final today = DateTime(2026, 9, 8);
      // 3:00 PM is after 2:30 PM
      expect(SupabaseService.isFutureDateTime(today, 15, 0, now: fixedNow), isTrue);
      // 9:00 PM is after 2:30 PM
      expect(SupabaseService.isFutureDateTime(today, 21, 0, now: fixedNow), isTrue);
    });

    test('Rejects past time on the same day', () {
      final today = DateTime(2026, 9, 8);
      // 10:00 AM is before 2:30 PM
      expect(SupabaseService.isFutureDateTime(today, 10, 0, now: fixedNow), isFalse);
      // 2:15 PM is before 2:30 PM
      expect(SupabaseService.isFutureDateTime(today, 14, 15, now: fixedNow), isFalse);
      // 2:30 PM exactly is not after
      expect(SupabaseService.isFutureDateTime(today, 14, 30, now: fixedNow), isFalse);
    });

    test('Accepts future date regardless of hour', () {
      final tomorrow = DateTime(2026, 9, 9);
      expect(SupabaseService.isFutureDateTime(tomorrow, 9, 0, now: fixedNow), isTrue);
    });

    test('Rejects past date regardless of hour', () {
      final yesterday = DateTime(2026, 9, 7);
      expect(SupabaseService.isFutureDateTime(yesterday, 18, 0, now: fixedNow), isFalse);
    });
  });

  group('Price Parsing and Multi-Service Calculations', () {
    test('Correctly parses different price formats', () {
      expect(SupabaseService.parsePrice(35000), 35000.0);
      expect(SupabaseService.parsePrice('35000'), 35000.0);
      expect(SupabaseService.parsePrice(r'$35,000'), 35000.0);
      expect(SupabaseService.parsePrice(r'$120.000'), 120000.0);
      expect(SupabaseService.parsePrice(r'$ 250,500'), 250500.0);
    });

    test('Accurately sums total price for multiple services', () {
      final services = [
        const ManagedService(id: '1', name: 'Cambio de Aceite', description: '', price: r'$120,000', active: true),
        const ManagedService(id: '2', name: 'Alineación y Balanceo', description: '', price: r'$65,000', active: true),
        const ManagedService(id: '3', name: 'Revisión de Frenos', description: '', price: r'$45,000', active: true),
      ];

      final total = services.fold<double>(0.0, (sum, s) => sum + SupabaseService.parsePrice(s.price));
      expect(total, 230000.0);
      expect(SupabaseService.formatPrice(total), r'$230,000');
    });

    test('Handles single service sum correctly', () {
      final services = [
        const ManagedService(id: '1', name: 'Diagnóstico', description: '', price: r'$50,000', active: true),
      ];
      final total = services.fold<double>(0.0, (sum, s) => sum + SupabaseService.parsePrice(s.price));
      expect(total, 50000.0);
      expect(SupabaseService.formatPrice(total), r'$50,000');
    });
  });
}
