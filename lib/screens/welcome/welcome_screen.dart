import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../services/auth_service.dart';
import '../../widgets/navigation_bars.dart';

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
    final userName = AuthService.currentUser?.name.split(' ').first ?? 'Conductor';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      bottomNavigationBar: ClientBottomNavigation(active: AppSection.welcome, navigate: widget.navigate),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hero Image Background
          Image.network(
            'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.canvas.withOpacity(0.2),
                  AppColors.canvas.withOpacity(0.85),
                  AppColors.canvas,
                ],
                stops: const [0.0, 0.45, 0.75],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Top User Badge
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.35)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_user_outlined, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '¡HOLA, ${userName.toUpperCase()}!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => widget.navigate(AppSection.notifications),
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          tooltip: 'Notificaciones',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main Title
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: const Interval(0.15, 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DRIVEN\nYIELD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tu taller automotriz de confianza. Cuidado experto y agenda rápida para tu vehículo.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Action Cards (Atajos rápidos de usabilidad)
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: const Interval(0.3, 0.65)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.calendar_month_rounded,
                            title: 'Agendar Cita',
                            subtitle: 'En 3 pasos',
                            color: AppColors.accent,
                            onTap: () => widget.navigate(AppSection.booking),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.format_list_bulleted_rounded,
                            title: 'Servicios',
                            subtitle: 'Precios y tipos',
                            color: const Color(0xFF388E3C),
                            onTap: () => widget.navigate(AppSection.services),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.75)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.event_available_rounded,
                            title: 'Mis Citas',
                            subtitle: 'Revisa tu horario',
                            color: const Color(0xFF1976D2),
                            onTap: () => widget.navigate(AppSection.dashboard),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.directions_car_rounded,
                            title: 'Mi Vehículo',
                            subtitle: 'Datos y perfil',
                            color: const Color(0xFFE65100),
                            onTap: () => widget.navigate(AppSection.history),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Main CTA Button
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: const Interval(0.5, 0.85)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => widget.navigate(AppSection.booking),
                        icon: const Icon(Icons.bolt_rounded, size: 22),
                        label: const Text(
                          'AGENDAR CITA AHORA',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Info Card
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: const Interval(0.6, 1.0)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.panel.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INFORMACIÓN DEL TALLER',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: AppColors.accent, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Av. Principal #123, Taller Driven Yield',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.schedule_outlined, color: AppColors.accent, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Lunes a Sábado: 8:00 AM - 6:00 PM',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.panel.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
