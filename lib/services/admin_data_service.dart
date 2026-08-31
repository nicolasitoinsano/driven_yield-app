import 'package:flutter/foundation.dart';
import '../models/admin_client.dart';
import '../models/managed_service.dart';
import 'supabase_service.dart';

class AdminDataService extends ChangeNotifier {
  List<AdminClient> _clients = [];
  List<ManagedService> _services = [];

  AdminDataService() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _services = await SupabaseService.getServices();
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando datos de Supabase: $e');
    }
  }

  List<AdminClient> get clients => List.unmodifiable(_clients);
  List<ManagedService> get services => List.unmodifiable(_services);
  List<ManagedService> get activeServices => List.unmodifiable(_services.where((service) => service.active));

  void saveClient(AdminClient client) {
    final index = _clients.indexWhere((item) => item.id == client.id);
    if (index == -1) {
      _clients.add(client);
    } else {
      _clients[index] = client;
    }
    notifyListeners();
  }

  void deleteClient(String id) {
    _clients.removeWhere((client) => client.id == id);
    notifyListeners();
  }

  void saveService(ManagedService service) {
    final index = _services.indexWhere((item) => item.id == service.id);
    if (index == -1) {
      _services.add(service);
    } else {
      _services[index] = service;
    }
    notifyListeners();
  }

  void deleteService(String id) {
    _services.removeWhere((service) => service.id == id);
    notifyListeners();
  }
}
