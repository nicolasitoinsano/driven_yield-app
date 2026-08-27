import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child, this.bottomNavigation});

  final Widget child;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(child: child),
          if (bottomNavigation != null) bottomNavigation!,
        ],
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
        decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(16)),
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
        color: AppColors.panel,
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
