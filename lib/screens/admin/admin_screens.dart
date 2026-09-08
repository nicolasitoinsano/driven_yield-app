import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/admin_client.dart';
import '../../models/app_section.dart';
import '../../models/managed_service.dart';
import '../../services/admin_data_service.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/layout.dart';
import '../../widgets/navigation_bars.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.login(
        identifier: _identifierController.text,
        password: _passwordController.text,
        requireAdmin: true,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Acceso concedido. ¡Bienvenido, Administrador ${user.name}!'),
          backgroundColor: AppColors.accent,
        ),
      );
      widget.navigate(AppSection.adminDashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.gpp_bad_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 42, 28, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextButton.icon(
              onPressed: () => widget.navigate(AppSection.login),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Volver al acceso de clientes'),
              style: TextButton.styleFrom(foregroundColor: Colors.white54),
            ),
            const SizedBox(height: 45),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(.14),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.accent.withOpacity(.4)),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent, size: 31),
            ),
            const SizedBox(height: 23),
            const Text('ACCESO\nADMINISTRADOR', style: TextStyle(fontSize: 34, height: .92, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 12),
            const Text('Panel de control para ventas, clientes y servicios del taller.', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.45)),
            const SizedBox(height: 35),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel.withOpacity(0.85),
                border: Border.all(color: const Color(0xFF3A3A3A)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(children: [
                AppTextField(
                  controller: _identifierController,
                  icon: Icons.badge_outlined,
                  hint: 'Correo o usuario de administrador',
                  focused: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  hint: 'Contraseña',
                  obscure: _hidePassword,
                  suffix: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(color: AppColors.accent),
                      )
                    : PrimaryButton(label: 'ENTRAR AL PANEL', onPressed: _handleAdminLogin),
              ]),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text('Acceso seguro exclusivo para administradores autorizados.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
          ]),
        ),
      );
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.navigate,
    required this.adminData,
  });

  final ValueChanged<AppSection> navigate;
  final AdminDataService adminData;

  @override
  Widget build(BuildContext context) {
    final recentBookings = adminData.bookings.take(5).toList();

    return AppPage(
      bottomNavigation: AdminBottomNavigation(active: AppSection.adminDashboard, navigate: navigate),
      child: RefreshIndicator(
        onRefresh: adminData.refreshData,
        color: AppColors.accent,
        backgroundColor: AppColors.panel,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: AdminHeader(
                    title: 'Panel de Administración',
                    subtitle: 'Resumen operativo sincronizado en vivo',
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await adminData.refreshData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos sincronizados con la base de datos.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.accent),
                  tooltip: 'Actualizar datos',
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'VENTAS DEL MES',
              style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              adminData.totalSalesFormatted,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
            ),
            Text(
              adminData.salesComparisonText,
              style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _SalesChart(
              heights: adminData.weeklySalesHeights,
              activeWeekdayIndex: adminData.currentDayIndex,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.people_outline,
                    value: '${adminData.clients.length}',
                    label: 'Clientes',
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.design_services_outlined,
                    value: '${adminData.activeServices.length}',
                    label: 'Servicios activos',
                    color: const Color(0xFFE8A000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.event_available_outlined,
                    value: '${adminData.confirmedBookingsCount}',
                    label: 'Citas confirmadas',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.pending_actions_outlined,
                    value: '${adminData.pendingBookingsCount}',
                    label: 'Por confirmar',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SecondaryActionCard(
              icon: Icons.people_alt_outlined,
              title: 'Administrar clientes',
              subtitle: 'Crear, editar o eliminar perfiles.',
              onTap: () => navigate(AppSection.adminClients),
            ),
            const SizedBox(height: 11),
            SecondaryActionCard(
              icon: Icons.miscellaneous_services_outlined,
              title: 'Administrar servicios',
              subtitle: 'Actualiza catálogo, precios y disponibilidad.',
              onTap: () => navigate(AppSection.adminServices),
            ),
            const SizedBox(height: 26),
            const Text(
              'ÚLTIMAS CITAS EN BASE DE DATOS',
              style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            if (recentBookings.isEmpty)
              const EmptyState(icon: Icons.event_busy_outlined, label: 'No hay citas registradas en la base de datos.')
            else
              for (final booking in recentBookings) ...[
                _AdminBookingCard(
                  booking: booking,
                  onConfirm: () async {
                    final citaId = booking['id_cita'];
                    if (citaId is int) {
                      await adminData.updateBookingStatus(citaId, 'confirmada');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Cita confirmada exitosamente!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  const _AdminBookingCard({required this.booking, required this.onConfirm});
  final Map<String, dynamic> booking;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final clientName = booking['usuario']?['nombre'] ?? 'Cliente';
    final serviceName = booking['servicio']?['nombre'] ?? 'Servicio de taller';
    final rawPrice = booking['monto'] != null && (booking['monto'] as num) > 0
        ? booking['monto']
        : booking['servicio']?['precio'];
    final priceStr = SupabaseService.formatPrice(rawPrice);
    final dateStr = booking['fecha']?.toString() ?? 'Fecha pendiente';
    final timeStr = booking['hora']?.toString().substring(0, 5) ?? '';
    final estado = booking['estado']?.toString().toLowerCase() ?? 'pendiente';

    Color statusColor;
    String statusLabel;
    switch (estado) {
      case 'confirmada':
        statusColor = AppColors.success;
        statusLabel = 'CONFIRMADA';
        break;
      case 'completada':
        statusColor = AppColors.info;
        statusLabel = 'COMPLETADA';
        break;
      case 'cancelada':
        statusColor = Colors.white38;
        statusLabel = 'CANCELADA';
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = 'PENDIENTE';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              Text(
                priceStr,
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            serviceName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(clientName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white38),
              const SizedBox(width: 4),
              Text('$dateStr $timeStr', style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          if (estado == 'pendiente') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_circle_outline, size: 15),
                label: const Text('CONFIRMAR CITA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.heights, required this.activeWeekdayIndex});
  final List<double> heights;
  final int activeWeekdayIndex;

  @override
  Widget build(BuildContext context) {
    final labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      height: 198,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 13),
      decoration: BoxDecoration(
        color: AppColors.panel.withOpacity(0.85),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rendimiento semanal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(
                'Hoy: ${labels[activeWeekdayIndex.clamp(0, 6)]}',
                style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                return _SalesBar(
                  label: labels[i],
                  height: heights.length > i ? heights[i] : 25.0,
                  highlighted: i == activeWeekdayIndex,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesBar extends StatelessWidget {
  const _SalesBar({required this.label, required this.height, this.highlighted = false});
  final String label;
  final double height;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 22,
            height: height,
            decoration: BoxDecoration(
              color: highlighted ? AppColors.accent : AppColors.accent.withOpacity(.35),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 23, height: 1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      );
}

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({
    super.key,
    required this.navigate,
    required this.clients,
    required this.onSave,
    required this.onDelete,
  });

  final ValueChanged<AppSection> navigate;
  final List<AdminClient> clients;
  final ValueChanged<AdminClient> onSave;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) => AppPage(
        bottomNavigation: AdminBottomNavigation(active: AppSection.adminClients, navigate: navigate),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 18),
          children: [
            const AdminHeader(title: 'Clientes', subtitle: 'Gestiona los perfiles de tu taller'),
            const SizedBox(height: 20),
            _ManagerPrimaryAction(
              label: 'NUEVO CLIENTE',
              icon: Icons.person_add_alt_1_outlined,
              onTap: () => _showClientEditor(context, onSave: onSave),
            ),
            const SizedBox(height: 19),
            Text(
              '${clients.length} CLIENTES REGISTRADOS',
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            if (clients.isEmpty)
              const EmptyState(icon: Icons.people_outline, label: 'No hay clientes registrados en la base de datos.')
            else
              for (final client in clients) ...[
                _ClientCard(
                  client: client,
                  onEdit: () => _showClientEditor(context, existing: client, onSave: onSave),
                  onDelete: () => _confirmRemoval(
                    context,
                    type: 'este cliente',
                    onConfirm: () {
                      onDelete(client.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cliente eliminado exitosamente.')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      );
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.onEdit, required this.onDelete});
  final AdminClient client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel.withOpacity(0.85),
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF422020),
              child: Text(
                client.name.isNotEmpty ? client.name.substring(0, 1).toUpperCase() : 'C',
                style: const TextStyle(color: Color(0xFFFFA5A5), fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(client.email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(client.phone, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFB1B1), size: 20),
                  tooltip: 'Editar cliente',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                  tooltip: 'Eliminar cliente',
                ),
              ],
            ),
          ],
        ),
      );
}

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({
    super.key,
    required this.navigate,
    required this.services,
    required this.onSave,
    required this.onToggleActive,
    required this.onDelete,
  });

  final ValueChanged<AppSection> navigate;
  final List<ManagedService> services;
  final ValueChanged<ManagedService> onSave;
  final void Function(String id, bool active) onToggleActive;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) => AppPage(
        bottomNavigation: AdminBottomNavigation(active: AppSection.adminServices, navigate: navigate),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 18),
          children: [
            const AdminHeader(title: 'Servicios', subtitle: 'Edita el catálogo disponible en el taller'),
            const SizedBox(height: 20),
            _ManagerPrimaryAction(
              label: 'CREAR SERVICIO',
              icon: Icons.add_circle_outline,
              onTap: () => _showServiceEditor(context, onSave: onSave),
            ),
            const SizedBox(height: 19),
            Text(
              '${services.length} SERVICIOS EN CATÁLOGO',
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            if (services.isEmpty)
              const EmptyState(icon: Icons.design_services_outlined, label: 'No hay servicios registrados en la base de datos.')
            else
              for (final service in services) ...[
                _ManagedServiceCard(
                  service: service,
                  onEdit: () => _showServiceEditor(context, existing: service, onSave: onSave),
                  onActiveChanged: (active) => onToggleActive(service.id, active),
                  onDelete: () => _confirmRemoval(
                    context,
                    type: 'este servicio',
                    onConfirm: () {
                      onDelete(service.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Servicio eliminado exitosamente.')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      );
}

class _ManagerPrimaryAction extends StatelessWidget {
  const _ManagerPrimaryAction({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 19),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),
      );
}

class _ManagedServiceCard extends StatelessWidget {
  const _ManagedServiceCard({
    required this.service,
    required this.onEdit,
    required this.onActiveChanged,
    required this.onDelete,
  });

  final ManagedService service;
  final VoidCallback onEdit;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel.withOpacity(0.85),
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.build_outlined, color: AppColors.accent, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    service.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFB1B1), size: 20),
                  tooltip: 'Editar servicio',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                  tooltip: 'Eliminar servicio',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              service.description,
              style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.35),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Text(
                  service.price,
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  service.active ? 'ACTIVO' : 'INACTIVO',
                  style: TextStyle(
                    color: service.active ? AppColors.success : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
                Switch(
                  value: service.active,
                  onChanged: onActiveChanged,
                  activeColor: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      );
}

Future<void> _showClientEditor(
  BuildContext context, {
  AdminClient? existing,
  required ValueChanged<AdminClient> onSave,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final email = TextEditingController(text: existing?.email ?? '');
  final phone = TextEditingController(text: existing?.phone ?? '');

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.panel.withOpacity(0.95),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 22),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Nuevo cliente' : 'Editar cliente',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 19),
            AppTextField(controller: name, hint: 'Nombre completo', icon: Icons.person_outline),
            const SizedBox(height: 11),
            AppTextField(
              controller: email,
              hint: 'Correo electrónico (ej. cliente@dominio.com)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 11),
            AppTextField(
              controller: phone,
              hint: 'Teléfono (ej. 3001234567)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: existing == null ? 'CREAR CLIENTE' : 'GUARDAR CAMBIOS',
              onPressed: () {
                final cleanName = name.text.trim();
                final cleanEmail = email.text.trim();
                final cleanPhone = phone.text.trim();

                if (cleanName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa el nombre del cliente.')),
                  );
                  return;
                }
                if (!AuthService.isValidEmail(cleanEmail)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingresa un correo con dominio completo (ej. cliente@dominio.com).'),
                    ),
                  );
                  return;
                }
                if (!AuthService.isValidColombianPhone(cleanPhone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El teléfono debe tener al menos 10 dígitos y empezar por 3 (ej. 3001234567).'),
                    ),
                  );
                  return;
                }

                onSave(AdminClient(
                  id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                  name: cleanName,
                  email: cleanEmail,
                  phone: cleanPhone,
                ));
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existing == null ? 'Cliente registrado exitosamente.' : 'Cliente actualizado exitosamente.'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showServiceEditor(
  BuildContext context, {
  ManagedService? existing,
  required ValueChanged<ManagedService> onSave,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final description = TextEditingController(text: existing?.description ?? '');
  final price = TextEditingController(text: existing?.price ?? '');
  var active = existing?.active ?? true;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.panel.withOpacity(0.95),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Crear servicio' : 'Editar servicio',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 19),
              AppTextField(controller: name, hint: 'Nombre del servicio', icon: Icons.design_services_outlined),
              const SizedBox(height: 11),
              AppTextField(controller: description, hint: 'Descripción', icon: Icons.notes_outlined, maxLines: 3),
              const SizedBox(height: 11),
              AppTextField(controller: price, hint: 'Precio (ej. 120,000 COP)', icon: Icons.sell_outlined),
              const SizedBox(height: 5),
              SwitchListTile(
                value: active,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.success,
                title: const Text('Servicio activo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text('Se muestra disponible para los clientes en la app.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onChanged: (value) => setSheetState(() => active = value),
              ),
              PrimaryButton(
                label: existing == null ? 'CREAR SERVICIO' : 'GUARDAR CAMBIOS',
                margin: const EdgeInsets.only(top: 13),
                onPressed: () {
                  final cleanName = name.text.trim();
                  final cleanPrice = price.text.trim();
                  if (cleanName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, ingresa el nombre del servicio.')),
                    );
                    return;
                  }
                  if (cleanPrice.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, ingresa el precio del servicio.')),
                    );
                    return;
                  }

                  onSave(ManagedService(
                    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    name: cleanName,
                    description: description.text.trim(),
                    price: cleanPrice,
                    active: active,
                  ));
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existing == null ? 'Servicio creado exitosamente.' : 'Servicio actualizado exitosamente.'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _confirmRemoval(BuildContext context, {required String type, required VoidCallback onConfirm}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel.withOpacity(0.95),
      title: const Text('Eliminar registro', style: TextStyle(fontWeight: FontWeight.w900)),
      content: Text(
        '¿Estás seguro de eliminar $type? Esta acción no se puede deshacer.',
        style: const TextStyle(color: Colors.white60, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text('ELIMINAR'),
        ),
      ],
    ),
  );
  if (confirmed ?? false) onConfirm();
}
