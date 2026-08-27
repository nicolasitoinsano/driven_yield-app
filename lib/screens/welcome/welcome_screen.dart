import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../widgets/layout.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 42, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.4))),
              child: const Text('TALLER AUTOMOTRIZ', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
            ),
            const SizedBox(height: 18),
            SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.6, curve: Curves.easeOut))),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.6))),
                child: const Text('MAXIMO\nRENDI\nMIENTO', style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 50, fontWeight: FontWeight.w900, height: .9, letterSpacing: -1.5)),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.8))),
              child: const Text('Expertos en el cuidado y mantenimiento de tu vehiculo. Trabajamos con repuestos originales y mecánicos certificados.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.5, 0.9))),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => widget.navigate(AppSection.dashboard),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12)),
                    child: const Text('SOLICITAR SERVICIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => widget.navigate(AppSection.services),
                    child: const Text('CONOCER MAS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 44),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.6, 1.0))),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(17)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.accent, size: 24),
                        SizedBox(width: 12),
                        Expanded(child: Text('Av. Principal 1234, Ciudad Autocity', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12))),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, color: AppColors.accent, size: 24),
                        SizedBox(width: 12),
                        Expanded(child: Text('+1 (555) 123-4567 | contacto@maximotaller.com', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
