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

class _LoginScreenState extends State<LoginScreen> {
  bool _hidePassword = true;
  bool _remember = true;

  @override
  Widget build(BuildContext context) => AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 52, 32, 28),
          child: Column(
            children: [
              const Text('INICIAR SESION', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3)),
              const SizedBox(height: 46),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2A2A2A), AppColors.panel]),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF353535)),
                ),
                child: Column(
                  children: [
                    const AppTextField(icon: Icons.person_outline, hint: 'Correo electronico o usuario', focused: true),
                    const SizedBox(height: 15),
                    AppTextField(
                      icon: Icons.lock_outline,
                      hint: 'Contrasena',
                      obscure: _hidePassword,
                      suffix: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), color: Colors.white54, icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _remember = !_remember),
                          child: Row(
                            children: [
                              Checkbox(value: _remember, onChanged: (value) => setState(() => _remember = value ?? false), activeColor: AppColors.accent, side: const BorderSide(color: Colors.white38), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              const Text('Recordar contrasena', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Se ha enviado un enlace de recuperacion a tu correo.')));
                          },
                          child: const Text('Olvido su contrasena?', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PrimaryButton(label: 'ENTRAR', onPressed: () => widget.navigate(AppSection.welcome)),
              TextButton.icon(
                onPressed: () => widget.navigate(AppSection.adminLogin),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: const Text('ACCEDER COMO ADMINISTRADOR'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF9A9A), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              const SizedBox(height: 15),
              const Text('O inicia sesion con', style: TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 15),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [_SocialIcon(Icons.facebook), SizedBox(width: 18), _SocialIcon(Icons.g_mobiledata, size: 29), SizedBox(width: 18), _SocialIcon(Icons.apple)]),
              const SizedBox(height: 27),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No tienes una cuenta? ', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  GestureDetector(onTap: () => widget.navigate(AppSection.register), child: const Text('Registrate', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700))),
                ],
              ),
            ],
          ),
        ),
      );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.navigate});

  final ValueChanged<AppSection> navigate;

  @override
  Widget build(BuildContext context) => AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 52, 32, 28),
          child: Column(
            children: [
              const Text('REGISTRO', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3)),
              const SizedBox(height: 46),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A2A2A), AppColors.panel]), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF353535))),
                child: Column(
                  children: [
                    const AppTextField(hint: 'Nombre completo'),
                    const SizedBox(height: 15),
                    const AppTextField(hint: 'Correo electronico'),
                    const SizedBox(height: 15),
                    const AppTextField(hint: 'Contrasena', obscure: true),
                    PrimaryButton(label: 'CREAR CUENTA', onPressed: () => navigate(AppSection.services)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Ya tienes una cuenta? ', style: TextStyle(color: Colors.white38, fontSize: 12)), GestureDetector(onTap: () => navigate(AppSection.login), child: const Text('Inicia sesion', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700)))]),
            ],
          ),
        ),
      );
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon(this.icon, {this.size = 19});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.panel, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF333333))), child: Icon(icon, size: size, color: Colors.white));
}
