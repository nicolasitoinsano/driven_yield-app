import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/admin_client.dart';
import '../../models/app_section.dart';
import '../../models/managed_service.dart';
import '../../widgets/layout.dart';
import '../../widgets/navigation_bars.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) => AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 42, 28, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextButton.icon(onPressed: () => widget.navigate(AppSection.login), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Volver al acceso de clientes'), style: TextButton.styleFrom(foregroundColor: Colors.white54)),
            const SizedBox(height: 45),
            Container(width: 58, height: 58, decoration: BoxDecoration(color: AppColors.accent.withOpacity(.14), borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.accent.withOpacity(.4))), child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent, size: 31)),
            const SizedBox(height: 23),
            const Text('ACCESO\nADMINISTRADOR', style: TextStyle(fontSize: 34, height: .92, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 12),
            const Text('Gestiona las ventas, los clientes y los servicios del taller.', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.45)),
            const SizedBox(height: 35),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: const Color(0xFF3A3A3A)), borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                const AppTextField(icon: Icons.badge_outlined, hint: 'Correo de administrador', focused: true),
                const SizedBox(height: 14),
                AppTextField(icon: Icons.lock_outline, hint: 'Contrasena', obscure: _hidePassword, suffix: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), color: Colors.white54)),
                PrimaryButton(label: 'ENTRAR AL PANEL', onPressed: () => widget.navigate(AppSection.adminDashboard)),
              ]),
            ),
            const SizedBox(height: 18),
            const Center(child: Text('Vista de demostracion: no valida credenciales.', style: TextStyle(color: Colors.white30, fontSize: 11))),
          ]),
        ),
      );
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.navigate, required this.clientCount, required this.activeServiceCount});
  final ValueChanged<AppSection> navigate;
  final int clientCount;
  final int activeServiceCount;

  @override
  Widget build(BuildContext context) => AppPage(
        bottomNavigation: AdminBottomNavigation(active: AppSection.adminDashboard, navigate: navigate),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 18),
          children: [
            const AdminHeader(title: 'Panel de Administracion', subtitle: 'Resumen operativo de hoy'),
            const SizedBox(height: 22),
            const Text('VENTAS DEL MES', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
            const SizedBox(height: 8),
            const Text(r'$3,840,000', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900)),
            const Text('+18.5% frente al mes anterior', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            const _SalesChart(),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: _MetricCard(icon: Icons.people_outline, value: '$clientCount', label: 'Clientes', color: AppColors.info)), const SizedBox(width: 12), Expanded(child: _MetricCard(icon: Icons.design_services_outlined, value: '$activeServiceCount', label: 'Servicios activos', color: const Color(0xFFE8A000)))]),
            const SizedBox(height: 12),
            const Row(children: [Expanded(child: _MetricCard(icon: Icons.event_available_outlined, value: '16', label: 'Citas confirmadas', color: AppColors.success)), SizedBox(width: 12), Expanded(child: _MetricCard(icon: Icons.pending_actions_outlined, value: '4', label: 'Por confirmar', color: AppColors.warning))]),
            const SizedBox(height: 22),
            SecondaryActionCard(icon: Icons.people_alt_outlined, title: 'Administrar clientes', subtitle: 'Crear, editar o eliminar perfiles.', onTap: () => navigate(AppSection.adminClients)),
            const SizedBox(height: 11),
            SecondaryActionCard(icon: Icons.miscellaneous_services_outlined, title: 'Administrar servicios', subtitle: 'Actualiza catalogo, precios y estado.', onTap: () => navigate(AppSection.adminServices)),
          ],
        ),
      );
}

class _SalesChart extends StatelessWidget {
  const _SalesChart();
  @override
  Widget build(BuildContext context) => Container(
        height: 198,
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 13),
        decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(18)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rendimiento semanal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), SizedBox(height: 17), Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_SalesBar(label: 'L', height: 40), _SalesBar(label: 'M', height: 65), _SalesBar(label: 'X', height: 50), _SalesBar(label: 'J', height: 85), _SalesBar(label: 'V', height: 75), _SalesBar(label: 'S', height: 100, highlighted: true), _SalesBar(label: 'D', height: 60)]))]),
      );
}

class _SalesBar extends StatelessWidget {
  const _SalesBar({required this.label, required this.height, this.highlighted = false});
  final String label;
  final double height;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 22, height: height, decoration: BoxDecoration(color: highlighted ? AppColors.accent : AppColors.accent.withOpacity(.35), borderRadius: BorderRadius.circular(7))), const SizedBox(height: 7), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10))]);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 21), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 23, height: 1, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10))]));
}

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({super.key, required this.navigate, required this.clients, required this.onSave, required this.onDelete});
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
            _ManagerPrimaryAction(label: 'NUEVO CLIENTE', icon: Icons.person_add_alt_1_outlined, onTap: () => _showClientEditor(context, onSave: onSave)),
            const SizedBox(height: 19),
            Text('${clients.length} CLIENTES REGISTRADOS', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            if (clients.isEmpty)
              const EmptyState(icon: Icons.people_outline, label: 'No hay clientes registrados.')
            else
              for (final client in clients) ...[
                _ClientCard(client: client, onEdit: () => _showClientEditor(context, existing: client, onSave: onSave), onDelete: () => _confirmRemoval(context, type: 'este cliente', onConfirm: () => onDelete(client.id))),
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
        decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          CircleAvatar(backgroundColor: const Color(0xFF422020), child: Text(client.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFFFFA5A5), fontWeight: FontWeight.w900))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(client.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(height: 3), Text(client.email, style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 2), Text(client.phone, style: const TextStyle(color: Colors.white38, fontSize: 11))])),
          Column(children: [IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFB1B1), size: 20), tooltip: 'Editar cliente'), IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20), tooltip: 'Eliminar cliente')]),
        ]),
      );
}

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key, required this.navigate, required this.services, required this.onSave, required this.onDelete});
  final ValueChanged<AppSection> navigate;
  final List<ManagedService> services;
  final ValueChanged<ManagedService> onSave;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) => AppPage(
        bottomNavigation: AdminBottomNavigation(active: AppSection.adminServices, navigate: navigate),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 18),
          children: [
            const AdminHeader(title: 'Servicios', subtitle: 'Edita el catalogo disponible'),
            const SizedBox(height: 20),
            _ManagerPrimaryAction(label: 'CREAR SERVICIO', icon: Icons.add_circle_outline, onTap: () => _showServiceEditor(context, onSave: onSave)),
            const SizedBox(height: 19),
            Text('${services.length} SERVICIOS EN CATALOGO', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            if (services.isEmpty)
              const EmptyState(icon: Icons.design_services_outlined, label: 'No hay servicios registrados.')
            else
              for (final service in services) ...[
                _ManagedServiceCard(service: service, onEdit: () => _showServiceEditor(context, existing: service, onSave: onSave), onActiveChanged: (active) => onSave(service.copyWith(active: active)), onDelete: () => _confirmRemoval(context, type: 'este servicio', onConfirm: () => onDelete(service.id))),
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
  Widget build(BuildContext context) => SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onTap, icon: Icon(icon, size: 19), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1)), style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)))));
}

class _ManagedServiceCard extends StatelessWidget {
  const _ManagedServiceCard({required this.service, required this.onEdit, required this.onActiveChanged, required this.onDelete});
  final ManagedService service;
  final VoidCallback onEdit;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: AppColors.accent.withOpacity(.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.build_outlined, color: AppColors.accent, size: 21)), const SizedBox(width: 11), Expanded(child: Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))), IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFB1B1), size: 20), tooltip: 'Editar servicio'), IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20), tooltip: 'Eliminar servicio')]),
          const SizedBox(height: 10),
          Text(service.description, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.35)),
          const SizedBox(height: 13),
          Row(children: [Text(service.price, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 13)), const Spacer(), Text(service.active ? 'ACTIVO' : 'INACTIVO', style: TextStyle(color: service.active ? AppColors.success : Colors.white38, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7)), Switch(value: service.active, onChanged: onActiveChanged, activeColor: AppColors.success)]),
        ]),
      );
}

Future<void> _showClientEditor(BuildContext context, {AdminClient? existing, required ValueChanged<AdminClient> onSave}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final email = TextEditingController(text: existing?.email ?? '');
  final phone = TextEditingController(text: existing?.phone ?? '');
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.panel,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 22),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(existing == null ? 'Nuevo cliente' : 'Editar cliente', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 19), AppTextField(controller: name, hint: 'Nombre completo', icon: Icons.person_outline), const SizedBox(height: 11), AppTextField(controller: email, hint: 'Correo electronico', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress), const SizedBox(height: 11), AppTextField(controller: phone, hint: 'Telefono', icon: Icons.phone_outlined, keyboardType: TextInputType.phone), PrimaryButton(label: existing == null ? 'CREAR CLIENTE' : 'GUARDAR CAMBIOS', onPressed: () { if (name.text.trim().isEmpty) return; onSave(AdminClient(id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), email: email.text.trim(), phone: phone.text.trim())); Navigator.of(sheetContext).pop(); })])),
    ),
  );
  name.dispose(); email.dispose(); phone.dispose();
}

Future<void> _showServiceEditor(BuildContext context, {ManagedService? existing, required ValueChanged<ManagedService> onSave}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final description = TextEditingController(text: existing?.description ?? '');
  final price = TextEditingController(text: existing?.price ?? '');
  var active = existing?.active ?? true;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.panel,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 22),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(existing == null ? 'Crear servicio' : 'Editar servicio', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 19), AppTextField(controller: name, hint: 'Nombre del servicio', icon: Icons.design_services_outlined), const SizedBox(height: 11), AppTextField(controller: description, hint: 'Descripcion', icon: Icons.notes_outlined, maxLines: 3), const SizedBox(height: 11), AppTextField(controller: price, hint: 'Precio (ej. 120,000 COP)', icon: Icons.sell_outlined), const SizedBox(height: 5), SwitchListTile(value: active, contentPadding: EdgeInsets.zero, activeColor: AppColors.success, title: const Text('Servicio activo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), subtitle: const Text('Se muestra disponible para los clientes.', style: TextStyle(color: Colors.white54, fontSize: 11)), onChanged: (value) => setSheetState(() => active = value)), PrimaryButton(label: existing == null ? 'CREAR SERVICIO' : 'GUARDAR CAMBIOS', margin: const EdgeInsets.only(top: 13), onPressed: () { if (name.text.trim().isEmpty) return; onSave(ManagedService(id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), description: description.text.trim(), price: price.text.trim(), active: active)); Navigator.of(sheetContext).pop(); })])),
      ),
    ),
  );
  name.dispose(); description.dispose(); price.dispose();
}

Future<void> _confirmRemoval(BuildContext context, {required String type, required VoidCallback onConfirm}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: const Text('Eliminar registro', style: TextStyle(fontWeight: FontWeight.w900)),
      content: Text('Esta seguro de eliminar $type? Esta accion no se puede deshacer.', style: const TextStyle(color: Colors.white60, fontSize: 13)),
      actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('CANCELAR')), FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), style: FilledButton.styleFrom(backgroundColor: AppColors.accent), child: const Text('ELIMINAR'))],
    ),
  );
  if (confirmed ?? false) onConfirm();
}
