import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../widgets/layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.navigate});

  final ValueChanged<AppSection> navigate;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _hidePassword = true;
  bool _remember = true;
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background image
          Image.network(
            'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=1000&q=80',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),
          
          // Dynamic Island Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.panel.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white24, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.build_circle_outlined, size: 55, color: AppColors.accent),
                      const SizedBox(height: 12),
                      const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
                      const SizedBox(height: 35),
                      const AppTextField(icon: Icons.person_outline, hint: 'Correo electrónico o usuario', focused: true),
                      const SizedBox(height: 16),
                      AppTextField(
                        icon: Icons.lock_outline,
                        hint: 'Contraseña',
                        obscure: _hidePassword,
                        suffix: IconButton(
                          onPressed: () => setState(() => _hidePassword = !_hidePassword), 
                          color: Colors.white54, 
                          icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _remember = !_remember),
                            child: Row(
                              children: [
                                Checkbox(value: _remember, onChanged: (value) => setState(() => _remember = value ?? false), activeColor: AppColors.accent, side: const BorderSide(color: Colors.white38), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                const Text('Recordar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Se ha enviado un enlace de recuperación a tu correo.')));
                            },
                            child: const Text('¿Olvidó su contraseña?', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      PrimaryButton(label: 'ENTRAR', onPressed: () => widget.navigate(AppSection.welcome)),
                      const SizedBox(height: 15),
                      TextButton.icon(
                        onPressed: () => widget.navigate(AppSection.adminLogin),
                        icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                        label: const Text('ACCEDER COMO ADMINISTRADOR'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF9A9A), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 15),
                      const Text('O inicia sesión con', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [_SocialIcon(Icons.facebook), SizedBox(width: 15), _SocialIcon(Icons.g_mobiledata, size: 29), SizedBox(width: 15), _SocialIcon(Icons.apple)]
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tienes una cuenta? ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          GestureDetector(
                            onTap: () => widget.navigate(AppSection.register), 
                            child: const Text('Regístrate', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700))
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.navigate});

  final ValueChanged<AppSection> navigate;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=1000&q=80',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.panel.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white24, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car_filled_outlined, size: 55, color: AppColors.accent),
                      const SizedBox(height: 12),
                      const Text('CREAR CUENTA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
                      const SizedBox(height: 35),
                      
                      const AppTextField(icon: Icons.badge_outlined, hint: 'Nombre completo'),
                      const SizedBox(height: 14),
                      const AppTextField(icon: Icons.email_outlined, hint: 'Correo electrónico', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      const AppTextField(icon: Icons.phone_android_outlined, hint: 'Teléfono', keyboardType: TextInputType.phone),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Expanded(child: AppTextField(icon: Icons.directions_car_outlined, hint: 'Marca/Modelo')),
                          SizedBox(width: 12),
                          Expanded(child: AppTextField(icon: Icons.pin_outlined, hint: 'Placa')),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        icon: Icons.lock_outline, 
                        hint: 'Contraseña', 
                        obscure: _hidePassword,
                        suffix: IconButton(
                          onPressed: () => setState(() => _hidePassword = !_hidePassword), 
                          color: Colors.white54, 
                          icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)
                        ),
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(label: 'REGISTRARSE', onPressed: () => widget.navigate(AppSection.services)),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Colors.white70, fontSize: 13)), 
                          GestureDetector(
                            onTap: () => widget.navigate(AppSection.login), 
                            child: const Text('Inicia sesión', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700))
                          )
                        ]
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon(this.icon, {this.size = 19});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: 44, 
    height: 44, 
    decoration: BoxDecoration(
      color: AppColors.panel, 
      shape: BoxShape.circle, 
      border: Border.all(color: Colors.white24)
    ), 
    child: Icon(icon, size: size, color: Colors.white)
  );
}
