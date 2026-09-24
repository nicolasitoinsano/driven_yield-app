import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_section.dart';

class ClientBottomNavigation extends StatelessWidget {
  const ClientBottomNavigation({super.key, required this.active, required this.navigate});

  final AppSection active;
  final ValueChanged<AppSection> navigate;

  @override
  Widget build(BuildContext context) => _NavigationShell(
        children: [
          _NavigationItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            selected: active == AppSection.welcome,
            onTap: () => navigate(AppSection.welcome),
          ),
          _NavigationItem(
            icon: Icons.miscellaneous_services_rounded,
            label: 'Servicios',
            selected: active == AppSection.services,
            onTap: () => navigate(AppSection.services),
          ),
          _NavigationItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendario',
            selected: active == AppSection.dashboard,
            onTap: () => navigate(AppSection.dashboard),
          ),
          _NavigationItem(
            icon: Icons.person_rounded,
            label: 'Mi Cuenta',
            selected: active == AppSection.history,
            onTap: () => navigate(AppSection.history),
          ),
        ],
      );
}

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({super.key, required this.active, required this.navigate});

  final AppSection active;
  final ValueChanged<AppSection> navigate;

  @override
  Widget build(BuildContext context) => _NavigationShell(
        children: [
          _NavigationItem(
            icon: Icons.space_dashboard_rounded,
            label: 'Panel',
            selected: active == AppSection.adminDashboard,
            onTap: () => navigate(AppSection.adminDashboard),
          ),
          _NavigationItem(
            icon: Icons.people_alt_rounded,
            label: 'Clientes',
            selected: active == AppSection.adminClients,
            onTap: () => navigate(AppSection.adminClients),
          ),
          _NavigationItem(
            icon: Icons.design_services_rounded,
            label: 'Servicios',
            selected: active == AppSection.adminServices,
            onTap: () => navigate(AppSection.adminServices),
          ),
          _NavigationItem(
            icon: Icons.logout_rounded,
            label: 'Salir',
            selected: false,
            onTap: () => navigate(AppSection.login),
          ),
        ],
      );
}

class _NavigationShell extends StatelessWidget {
  const _NavigationShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: const Border(
            top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: children,
          ),
        ),
      );
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent.withOpacity(0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.accent : Colors.white54,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? Colors.white : Colors.white54,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
