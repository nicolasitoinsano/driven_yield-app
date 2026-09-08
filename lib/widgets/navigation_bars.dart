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
          _NavigationIcon(icon: Icons.home_outlined, selected: active == AppSection.welcome, onTap: () => navigate(AppSection.welcome)),
          _NavigationIcon(icon: Icons.format_list_bulleted, selected: active == AppSection.services, onTap: () => navigate(AppSection.services)),
          _NavigationIcon(icon: Icons.calendar_month_outlined, selected: active == AppSection.dashboard, onTap: () => navigate(AppSection.dashboard)),
          _NavigationIcon(icon: Icons.person_outline, selected: active == AppSection.history, onTap: () => navigate(AppSection.history)),
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
          _NavigationIcon(icon: Icons.space_dashboard_outlined, selected: active == AppSection.adminDashboard, onTap: () => navigate(AppSection.adminDashboard)),
          _NavigationIcon(icon: Icons.people_outline, selected: active == AppSection.adminClients, onTap: () => navigate(AppSection.adminClients)),
          _NavigationIcon(icon: Icons.design_services_outlined, selected: active == AppSection.adminServices, onTap: () => navigate(AppSection.adminServices)),
          _NavigationIcon(icon: Icons.logout_outlined, selected: false, onTap: () => navigate(AppSection.login)),
        ],
      );
}

class _NavigationShell extends StatelessWidget {
  const _NavigationShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: AppColors.field, border: Border(top: BorderSide(color: Color(0xFF222222)))),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: children),
      );
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.icon, required this.selected, required this.onTap});

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        tooltip: '',
        icon: Icon(icon, color: selected ? AppColors.accent : Colors.white38),
      );
}
