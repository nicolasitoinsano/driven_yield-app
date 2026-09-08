import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
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
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          
          // Gradient Overlay to make text readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.canvas.withOpacity(0.1),
                  AppColors.canvas.withOpacity(0.8),
                  AppColors.canvas.withOpacity(1.0),
                ],
                stops: const [0.0, 0.5, 0.8],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  // Welcome Header
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.4))),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.4, curve: Curves.easeOut))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('BIENVENIDO A TU TALLER DE CONFIANZA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main Title
                  SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.6, curve: Curves.easeOut))),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.6))),
                      child: const Text('DRIVEN\nYIELD', style: TextStyle(color: Colors.white, fontSize: 58, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -1.5)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Subtitle & Description
                  SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.8, curve: Curves.easeOut))),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.8))),
                      child: const Text(
                        'Nos alegra tenerte aquí.\n\nExperimenta el mejor cuidado para tu vehículo con mecánicos expertos, tecnología de punta y la tranquilidad de saber que tu auto está en las mejores manos.',
                        style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // CTA Buttons
                  SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.5, 0.9, curve: Curves.elasticOut))),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.5, 0.9))),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => widget.navigate(AppSection.services),
                              icon: const Icon(Icons.calendar_month_outlined, size: 22),
                              label: const Text('AGENDAR CITA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 10,
                                shadowColor: AppColors.accent.withOpacity(0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => widget.navigate(AppSection.services),
                              icon: const Icon(Icons.build_outlined, size: 22),
                              label: const Text('VER SERVICIOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Contact Info Card
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.6, 1.0))),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.panel.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('INFORMACIÓN DE CONTACTO', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(child: Text('Av. Principal 1234, Ciudad Autocity', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.phone_outlined, color: AppColors.accent, size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(child: Text('+1 (555) 123-4567\ncontacto@drivenyield.com', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4))),
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
          ),
        ],
      ),
    );
  }
}
