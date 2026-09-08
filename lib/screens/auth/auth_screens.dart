import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../services/auth_service.dart';
import '../../widgets/layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.navigate});

  final ValueChanged<AppSection> navigate;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _remember = true;
  bool _isLoading = false;

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
    _identifierController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.login(
        identifier: _identifierController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, ${user.name}!${user.isAdmin ? ' (Modo Administrador)' : ''}'),
          backgroundColor: AppColors.accent,
        ),
      );

      if (user.isAdmin) {
        widget.navigate(AppSection.adminDashboard);
      } else {
        widget.navigate(AppSection.welcome);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
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
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.build_circle_outlined, size: 55, color: AppColors.accent),
                      const SizedBox(height: 12),
                      const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
                      ),
                      const SizedBox(height: 35),
                      AppTextField(
                        controller: _identifierController,
                        icon: Icons.person_outline,
                        hint: 'Correo electrónico o usuario',
                        focused: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hint: 'Contraseña',
                        obscure: _hidePassword,
                        suffix: IconButton(
                          onPressed: () => setState(() => _hidePassword = !_hidePassword),
                          color: Colors.white54,
                          icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _remember = !_remember),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (value) => setState(() => _remember = value ?? false),
                                  activeColor: AppColors.accent,
                                  side: const BorderSide(color: Colors.white38),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Text('Recordar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Se ha enviado un enlace de recuperación a tu correo.')),
                              );
                            },
                            child: const Text(
                              '¿Olvidó su contraseña?',
                              style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(color: AppColors.accent),
                            )
                          : PrimaryButton(label: 'ENTRAR', onPressed: _handleLogin),
                      const SizedBox(height: 15),
                      TextButton.icon(
                        onPressed: () => widget.navigate(AppSection.adminLogin),
                        icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                        label: const Text('ACCEDER COMO ADMINISTRADOR'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF9A9A),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('O inicia sesión con', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIcon(Icons.facebook),
                          SizedBox(width: 15),
                          _SocialIcon(Icons.g_mobiledata, size: 29),
                          SizedBox(width: 15),
                          _SocialIcon(Icons.apple),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tienes una cuenta? ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          GestureDetector(
                            onTap: () => widget.navigate(AppSection.register),
                            child: const Text('Regístrate', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _brandModelController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _brandModelController.dispose();
    _plateController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final brandModel = _brandModelController.text.trim();
      final brand = brandModel.contains(' ') ? brandModel.split(' ').first : brandModel;
      final model = brandModel.contains(' ') ? brandModel.substring(brand.length).trim() : brandModel;

      final user = await AuthService.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        vehicleBrand: brand.isNotEmpty ? brand : 'Vehículo',
        vehicleModel: model.isNotEmpty ? model : 'Modelo',
        vehiclePlate: _plateController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Cuenta creada exitosamente! Bienvenido, ${user.name}'),
          backgroundColor: AppColors.accent,
        ),
      );
      widget.navigate(AppSection.welcome);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
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
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car_filled_outlined, size: 55, color: AppColors.accent),
                      const SizedBox(height: 12),
                      const Text(
                        'CREAR CUENTA',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
                      ),
                      const SizedBox(height: 35),
                      AppTextField(
                        controller: _nameController,
                        icon: Icons.badge_outlined,
                        hint: 'Nombre completo',
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        hint: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _phoneController,
                        icon: Icons.phone_android_outlined,
                        hint: 'Teléfono',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _brandModelController,
                              icon: Icons.directions_car_outlined,
                              hint: 'Marca/Modelo',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _plateController,
                              icon: Icons.pin_outlined,
                              hint: 'Placa',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hint: 'Contraseña',
                        obscure: _hidePassword,
                        suffix: IconButton(
                          onPressed: () => setState(() => _hidePassword = !_hidePassword),
                          color: Colors.white54,
                          icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(color: AppColors.accent),
                            )
                          : PrimaryButton(label: 'REGISTRARSE', onPressed: _handleRegister),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          GestureDetector(
                            onTap: () => widget.navigate(AppSection.login),
                            child: const Text('Inicia sesión', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
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

class _SocialIcon extends StatelessWidget {
  const _SocialIcon(this.icon, {this.size = 19});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppColors.panel, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
        child: Icon(icon, size: size, color: Colors.white),
      );
}
