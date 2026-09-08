import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'models/admin_client.dart';
import 'models/app_section.dart';
import 'models/managed_service.dart';
import 'screens/admin/admin_screens.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/client/client_screens.dart';
import 'screens/client/notifications_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/admin_data_service.dart';

/// Composition root: conecta navegacion, pantallas y estado compartido.
class DrivenYieldApp extends StatefulWidget {
  const DrivenYieldApp({super.key});

  @override
  State<DrivenYieldApp> createState() => _DrivenYieldAppState();
}

class _DrivenYieldAppState extends State<DrivenYieldApp> {
  final AdminDataService _adminData = AdminDataService();
  AppSection _section = AppSection.login;

  @override
  void dispose() {
    _adminData.dispose();
    super.dispose();
  }

  void _navigate(AppSection section) => setState(() => _section = section);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _adminData,
        builder: (context, _) => MaterialApp(
          title: 'Driven Yield Citas',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ColoredBox(color: AppColors.canvas, child: _currentScreen()),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _currentScreen() => switch (_section) {
        AppSection.welcome => WelcomeScreen(navigate: _navigate),
        AppSection.login => LoginScreen(navigate: _navigate),
        AppSection.register => RegisterScreen(navigate: _navigate),
        AppSection.services => ServicesScreen(navigate: _navigate, services: _adminData.activeServices),
        AppSection.booking => BookingScreen(navigate: _navigate, services: _adminData.activeServices),
        AppSection.dashboard => DashboardScreen(navigate: _navigate),
        AppSection.history => HistoryScreen(navigate: _navigate),
        AppSection.notifications => NotificationsScreen(navigate: _navigate),
        AppSection.adminLogin => AdminLoginScreen(navigate: _navigate),
        AppSection.adminDashboard => AdminDashboardScreen(navigate: _navigate, clientCount: _adminData.clients.length, activeServiceCount: _adminData.activeServices.length),
        AppSection.adminClients => AdminClientsScreen(navigate: _navigate, clients: _adminData.clients, onSave: _saveClient, onDelete: _adminData.deleteClient),
        AppSection.adminServices => AdminServicesScreen(navigate: _navigate, services: _adminData.services, onSave: _saveService, onDelete: _adminData.deleteService),
      };

  void _saveClient(AdminClient client) => _adminData.saveClient(client);
  void _saveService(ManagedService service) => _adminData.saveService(service);
}
