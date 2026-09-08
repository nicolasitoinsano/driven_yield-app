import 'package:flutter/foundation.dart';
import '../models/admin_client.dart';
import '../models/managed_service.dart';
import 'supabase_service.dart';

class AdminDataService extends ChangeNotifier {
  List<AdminClient> _clients = [];
  List<ManagedService> _services = [];
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;

  AdminDataService() {
    refreshData();
  }

  bool get isLoading => _isLoading;
  List<AdminClient> get clients => List.unmodifiable(_clients);
  List<ManagedService> get services => List.unmodifiable(_services);
  List<ManagedService> get activeServices =>
      List.unmodifiable(_services.where((service) => service.active));
  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = await Future.wait([
        SupabaseService.getServices(),
        SupabaseService.getClients(),
        SupabaseService.getAllBookingsAdmin(),
      ]);

      _services = futures[0] as List<ManagedService>;

      final clientData = futures[1] as List<Map<String, dynamic>>;
      _clients = clientData.map((c) {
        final email = c['email'] ?? c['correo'] ?? '';
        return AdminClient(
          id: c['id_usuario'].toString(),
          name: c['nombre']?.toString() ?? 'Sin nombre',
          email: email.toString().isNotEmpty ? email.toString() : 'Sin correo',
          phone: c['telefono']?.toString() ?? 'Sin teléfono',
        );
      }).toList();

      _bookings = futures[2] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('Error cargando datos de Supabase (Admin): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTRICAS CALCULADAS EN TIEMPO REAL CON LA BASE DE DATOS ---

  /// Ventas acumuladas de las citas en el mes actual (o histórico si el mes inicia)
  double get totalSalesMonth {
    final now = DateTime.now();
    double total = 0.0;
    for (final b in _bookings) {
      final estado = b['estado']?.toString().toLowerCase() ?? '';
      if (estado == 'cancelada') continue;

      final dateStr = b['fecha']?.toString() ?? '';
      final date = DateTime.tryParse(dateStr);
      if (date != null && date.year == now.year && date.month == now.month) {
        final monto = b['monto'];
        final numMonto = (monto is num)
            ? monto.toDouble()
            : double.tryParse(monto?.toString() ?? '0') ?? 0.0;
        if (numMonto > 0) {
          total += numMonto;
        } else {
          final servPrice = b['servicio']?['precio'];
          final numServPrice = (servPrice is num)
              ? servPrice.toDouble()
              : double.tryParse(servPrice?.toString() ?? '0') ?? 0.0;
          total += numServPrice;
        }
      }
    }

    if (total == 0.0 && _bookings.isNotEmpty) {
      for (final b in _bookings) {
        final estado = b['estado']?.toString().toLowerCase() ?? '';
        if (estado == 'cancelada') continue;
        final monto = b['monto'];
        final numMonto = (monto is num)
            ? monto.toDouble()
            : double.tryParse(monto?.toString() ?? '0') ?? 0.0;
        if (numMonto > 0) {
          total += numMonto;
        } else {
          final servPrice = b['servicio']?['precio'];
          final numServPrice = (servPrice is num)
              ? servPrice.toDouble()
              : double.tryParse(servPrice?.toString() ?? '0') ?? 0.0;
          total += numServPrice;
        }
      }
    }

    return total;
  }

  String get totalSalesFormatted => SupabaseService.formatPrice(totalSalesMonth);

  /// Texto descriptivo de ventas
  String get salesComparisonText {
    final now = DateTime.now();
    final currentMonthBookings = _bookings.where((b) {
      final estado = b['estado']?.toString().toLowerCase() ?? '';
      if (estado == 'cancelada') return false;
      final date = DateTime.tryParse(b['fecha']?.toString() ?? '');
      return date != null && date.year == now.year && date.month == now.month;
    }).length;

    if (currentMonthBookings > 0) {
      return '$currentMonthBookings citas activas este mes';
    } else {
      return '${_bookings.length} citas registradas en total';
    }
  }

  /// Citas confirmadas o completadas
  int get confirmedBookingsCount {
    return _bookings.where((b) {
      final estado = b['estado']?.toString().toLowerCase() ?? '';
      return estado == 'confirmada' || estado == 'completada';
    }).length;
  }

  /// Citas pendientes por confirmar
  int get pendingBookingsCount {
    return _bookings.where((b) {
      final estado = b['estado']?.toString().toLowerCase() ?? '';
      return estado == 'pendiente';
    }).length;
  }

  /// Alturas dinámicas de las barras para los días de la semana:
  /// L (Lunes=1), M (Martes=2), X (Miércoles=3), J (Jueves=4), V (Viernes=5), S (Sábado=6), D (Domingo=7)
  List<double> get weeklySalesHeights {
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (final b in _bookings) {
      final date = DateTime.tryParse(b['fecha']?.toString() ?? '');
      if (date != null) {
        final wd = date.weekday; // 1 (Lunes) a 7 (Domingo)
        weekdayCounts[wd] = (weekdayCounts[wd] ?? 0) + 1;
      }
    }

    int maxCount = 0;
    for (final count in weekdayCounts.values) {
      if (count > maxCount) maxCount = count;
    }

    if (maxCount == 0) {
      return [25.0, 25.0, 25.0, 25.0, 25.0, 25.0, 25.0];
    }

    return List.generate(7, (index) {
      final day = index + 1;
      final count = weekdayCounts[day] ?? 0;
      // Escala entre 20.0 y 110.0 px
      return 20.0 + ((count / maxCount) * 90.0);
    });
  }

  /// Índice del día actual (0=Lunes, 6=Domingo) para destacar en la gráfica
  int get currentDayIndex => DateTime.now().weekday - 1;

  // --- OPERACIONES CRUD ---

  Future<void> saveClient(AdminClient client) async {
    final exists = _clients.any((item) => item.id == client.id);
    if (!exists) {
      await SupabaseService.addClient(client.name, client.email, client.phone);
    } else {
      await SupabaseService.updateClient(client.id, client.name, client.email, client.phone);
    }
    await refreshData();
  }

  Future<void> deleteClient(String id) async {
    await SupabaseService.deleteClient(id);
    await refreshData();
  }

  Future<void> saveService(ManagedService service) async {
    final exists = _services.any((item) => item.id == service.id);
    if (!exists) {
      await SupabaseService.addService(service.name, service.description, service.price, service.active);
    } else {
      await SupabaseService.updateService(service.id, service.name, service.description, service.price, service.active);
    }
    await refreshData();
  }

  Future<void> toggleServiceActive(String id, bool active) async {
    await SupabaseService.updateServiceActive(id, active);
    await refreshData();
  }

  Future<void> deleteService(String id) async {
    await SupabaseService.deleteService(id);
    await refreshData();
  }

  Future<void> updateBookingStatus(int citaId, String status) async {
    await SupabaseService.updateBookingStatus(citaId, status);
    await refreshData();
  }
}
