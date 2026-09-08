import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

import 'dart:ui';
class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child, this.bottomNavigation});

  final Widget child;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.canvas,
        bottomNavigationBar: bottomNavigation,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.canvas.withOpacity(0.8),
                      AppColors.canvas.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.margin = const EdgeInsets.only(top: 20)});

  final String label;
  final VoidCallback onPressed;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: margin,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        ),
      );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.hint,
    this.icon,
    this.suffix,
    this.obscure = false,
    this.focused = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String hint;
  final IconData? icon;
  final Widget? suffix;
  final bool obscure;
  final bool focused;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focused ? AppColors.accent : const Color(0xFF363636)),
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.field,
        hintText: hint,
        labelText: controller == null ? null : hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        prefixIcon: icon == null ? null : Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        enabledBorder: outline,
        focusedBorder: outline.copyWith(borderSide: const BorderSide(color: AppColors.accent)),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.admin_panel_settings_outlined, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
        decoration: BoxDecoration(color: AppColors.panel.withOpacity(0.85), border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white30),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      );
}

class SecondaryActionCard extends StatelessWidget {
  const SecondaryActionCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.panel.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(.12), borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: AppColors.accent),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        ),
      );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.toLowerCase().trim();
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (cleanStatus) {
      case 'confirmada':
      case 'completada':
        bg = AppColors.success.withOpacity(0.18);
        fg = AppColors.success;
        label = 'Confirmada';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelada':
        bg = AppColors.danger.withOpacity(0.18);
        fg = AppColors.danger;
        label = 'Cancelada';
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = AppColors.warning.withOpacity(0.18);
        fg = AppColors.warning;
        label = 'Pendiente';
        icon = Icons.hourglass_top_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

