import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../models/managed_service.dart';
import '../../widgets/layout.dart';
import '../../widgets/navigation_bars.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/notificacion_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/notification_bell.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, required this.navigate, required this.services});
  final ValueChanged<AppSection> navigate;
  final List<ManagedService> services;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = widget.services.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image matching welcome screen
          Image.network(
            'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?auto=format&fit=crop&w=1200&q=80',
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
                    AppColors.canvas.withOpacity(0.7),
                    AppColors.canvas.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                    children: [
                      FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.3))),
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.4, curve: Curves.easeOut))),
                          child: const Text('SERVICIOS', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -1.0, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.5))),
                        child: const Text('Encuentra el servicio adecuado para tu auto y agenda en segundos.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                      ),
                      const SizedBox(height: 20),

                      // Buscador de servicios intuitivo
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.panel.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Buscar servicio (ej: aceite, frenos, alineación)...',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accent, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredServices.length} SERVICIOS DISPONIBLES',
                            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                          if (_searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Text('Limpiar filtro', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (filteredServices.isEmpty)
                        FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 1.0))),
                          child: const EmptyState(icon: Icons.search_off_rounded, label: 'No se encontraron servicios con ese término de búsqueda.'),
                        )
                      else
                        for (int i = 0; i < filteredServices.length; i++) ...[
                          _AnimatedServiceCard(
                            service: filteredServices[i],
                            index: i,
                            animation: _anim,
                            onTap: () {
                              final origIndex = widget.services.indexOf(filteredServices[i]);
                              globalSelectedServiceIndex = origIndex >= 0 ? origIndex : 0;
                              widget.navigate(AppSection.booking);
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                    ],
                  ),
                ),
                ClientBottomNavigation(active: AppSection.services, navigate: widget.navigate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedServiceCard extends StatefulWidget {
  const _AnimatedServiceCard({required this.service, required this.index, required this.animation, required this.onTap});
  final ManagedService service;
  final int index;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  State<_AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = 0.3 + (widget.index * 0.1);
    final end = start + 0.4;
    final curve = CurvedAnimation(
      parent: widget.animation,
      curve: Interval(start > 1.0 ? 1.0 : start, end > 1.0 ? 1.0 : end, curve: Curves.easeOutBack),
    );

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(curve),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: widget.animation, curve: Interval(start > 1.0 ? 1.0 : start, (start + 0.2) > 1.0 ? 1.0 : (start + 0.2)))),
        child: GestureDetector(
          onTapDown: (_) => _hoverController.forward(),
          onTapUp: (_) {
            _hoverController.reverse();
            globalSelectedServiceIndex = widget.index;
            widget.onTap();
          },
          onTapCancel: () => _hoverController.reverse(),
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, spreadRadius: -5, offset: const Offset(0, 8))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFF881111)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.handyman_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.service.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                        const SizedBox(height: 5),
                        Text(widget.service.description, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text(widget.service.price, style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w800)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('AGENDAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int globalSelectedServiceIndex = 0;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.navigate, required this.services});

  final ValueChanged<AppSection> navigate;
  final List<ManagedService> services;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  int _step = 0; // 0 = Date/Time, 1 = Confirm
  late final Set<String> _selectedServiceIds;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _selectedServiceIds = {};
    if (widget.services.isNotEmpty) {
      final initialIndex = globalSelectedServiceIndex.clamp(0, widget.services.length - 1);
      _selectedServiceIds.add(widget.services[initialIndex].id);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  List<ManagedService> get _selectedServices =>
      widget.services.where((s) => _selectedServiceIds.contains(s.id)).toList();

  double get _totalPrice =>
      _selectedServices.fold<double>(0.0, (sum, s) => sum + SupabaseService.parsePrice(s.price));

  void _toggleService(ManagedService service) {
    setState(() {
      if (_selectedServiceIds.contains(service.id)) {
        if (_selectedServiceIds.length > 1) {
          _selectedServiceIds.remove(service.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes seleccionar al menos un servicio para la cita.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } else {
        _selectedServiceIds.add(service.id);
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? (now.hour >= 20 ? now.add(const Duration(days: 1)) : now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.panel,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);

      // Si ya se había elegido una hora, revalidar para la nueva fecha
      if (_selectedTime != null) {
        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
        if (isToday) {
          final apptDateTime = DateTime(date.year, date.month, date.day, _selectedTime!.hour, _selectedTime!.minute);
          if (apptDateTime.isBefore(now)) {
            setState(() => _selectedTime = null);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La hora que tenías seleccionada ya pasó para el día de hoy. Por favor selecciona una nueva hora.'),
                backgroundColor: Colors.orangeAccent,
              ),
            );
            return;
          }
        }

        final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
        final isBooked = await SupabaseService.isTimeSlotBooked(date, timeString);
        if (isBooked && mounted) {
          setState(() => _selectedTime = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La hora $timeString ya está ocupada para este día. Por favor elige otra hora.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    TimeOfDay initial = _selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
    if (_selectedTime == null) {
      if (_selectedDate != null && _selectedDate!.year == now.year && _selectedDate!.month == now.month && _selectedDate!.day == now.day) {
        if (now.hour >= 9 && now.hour < 21) {
          initial = TimeOfDay(hour: (now.hour + 1).clamp(9, 21), minute: 0);
        } else {
          initial = const TimeOfDay(hour: 9, minute: 0);
        }
      } else {
        initial = const TimeOfDay(hour: 9, minute: 0);
      }
    }

    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'HORARIO DE ATENCIÓN: 9:00 AM - 9:00 PM',
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.panel,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (time == null || !mounted) return;

    // 1. Validar que esté entre 9:00 AM y 9:00 PM
    if (!SupabaseService.isValidOperatingHour(time.hour, time.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario no permitido. Las citas solo se pueden agendar entre las 9:00 AM y las 9:00 PM.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Validar que no sea antes de la hora actual si la fecha es hoy
    if (_selectedDate != null) {
      final isToday = _selectedDate!.year == now.year &&
          _selectedDate!.month == now.month &&
          _selectedDate!.day == now.day;
      if (isToday) {
        final apptDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          time.hour,
          time.minute,
        );
        if (apptDateTime.isBefore(now)) {
          final nowStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No puedes seleccionar una hora anterior a la hora actual ($nowStr).'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      // 3. Validar disponibilidad de horario (evitar duplicados)
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final isBooked = await SupabaseService.isTimeSlotBooked(_selectedDate!, timeString);
      if (isBooked && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El horario $timeString ya se encuentra reservado por otra cita en este día. Por favor selecciona otra hora.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _selectedTime = time);
  }

  Future<void> _confirmBooking(List<ManagedService> selectedServices) async {
    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona al menos un servicio')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora')),
      );
      return;
    }

    if (!SupabaseService.isValidOperatingHour(_selectedTime!.hour, _selectedTime!.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las citas solo se pueden agendar entre las 9:00 AM y las 9:00 PM.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final now = DateTime.now();
    final apptDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (apptDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes agendar una cita antes de la hora actual.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    final namesSummary = selectedServices.map((s) => s.name).join(', ');
    final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    try {
      await SupabaseService.createBooking(
        services: selectedServices,
        date: _selectedDate!,
        time: timeString,
      );

      await NotificationService.instance.showBookingResult(
        success: true,
        message: 'Tu cita para "$namesSummary" quedó registrada correctamente.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cita guardada exitosamente!')),
        );
        widget.navigate(AppSection.dashboard);
      }
    } catch (e) {
      final errorMessage = 'No pudimos registrar tu cita: $e';

      await NotificationService.instance.showBookingResult(success: false, message: errorMessage);
      await NotificacionService.notifyBookingFailed(mensaje: errorMessage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasServices = widget.services.isNotEmpty;
    const steps = ['Servicios y Horario', 'Confirmación'];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?auto=format&fit=crop&w=1200&q=80',
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
                  colors: [AppColors.canvas.withOpacity(0.7), AppColors.canvas.withOpacity(0.95)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.3))),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          if (_step == 1) {
                            setState(() => _step = 0);
                          } else {
                            widget.navigate(AppSection.services);
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios, size: 14),
                        label: const Text('Volver'),
                        style: TextButton.styleFrom(foregroundColor: Colors.white70, padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.1, 0.4))),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.1, 0.4, curve: Curves.easeOut))),
                      child: const Text('RESERVA DE\nSERVICIO', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.0, color: Colors.white, letterSpacing: -1.0)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.5))),
                    child: const Text('Completa la secuencia para asegurar tu espacio.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 24),
                  
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.3, 0.6))),
                    child: Row(
                      children: List.generate(2, (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index == 1 ? 0 : 8),
                          decoration: BoxDecoration(color: index <= _step ? AppColors.accent : Colors.white12, borderRadius: BorderRadius.circular(8)),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.3, 0.6))),
                    child: Text('0${_step + 1} - ${steps[_step].toUpperCase()}', style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.8))),
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.8, curve: Curves.easeOut))),
                        child: _buildStep(),
                      ),
                    ),
                  ),
                  
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.6, 1.0))),
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                      : SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: hasServices
                                ? () async {
                                    if (_step < 1) {
                                      if (_selectedServices.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Selecciona al menos un servicio para continuar')),
                                        );
                                        return;
                                      }
                                      if (_selectedDate == null || _selectedTime == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Selecciona fecha y hora para continuar')),
                                        );
                                        return;
                                      }
                                      if (!SupabaseService.isValidOperatingHour(_selectedTime!.hour, _selectedTime!.minute)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Las citas solo se pueden agendar entre las 9:00 AM y las 9:00 PM.')),
                                        );
                                        return;
                                      }
                                      final now = DateTime.now();
                                      final apptDateTime = DateTime(
                                        _selectedDate!.year,
                                        _selectedDate!.month,
                                        _selectedDate!.day,
                                        _selectedTime!.hour,
                                        _selectedTime!.minute,
                                      );
                                      if (apptDateTime.isBefore(now)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No puedes agendar antes de la hora actual.')),
                                        );
                                        return;
                                      }
                                      final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                                      final isBooked = await SupabaseService.isTimeSlotBooked(_selectedDate!, timeStr);
                                      if (isBooked) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('El horario $timeStr ya está reservado. Por favor elige otro.')),
                                        );
                                        return;
                                      }
                                      setState(() => _step++);
                                    } else {
                                      _confirmBooking(_selectedServices);
                                    }
                                  }
                                : () => widget.navigate(AppSection.services),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 10,
                              shadowColor: AppColors.accent.withOpacity(0.5),
                            ),
                            child: Text(_step == 1 ? 'CONFIRMAR CITA' : 'CONTINUAR', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    if (widget.services.isEmpty) {
      return const EmptyState(icon: Icons.design_services_outlined, label: 'No hay servicios activos para reservar.');
    }

    if (_step == 0) {
      final now = DateTime.now();
      final isToday = _selectedDate != null &&
          _selectedDate!.year == now.year &&
          _selectedDate!.month == now.month &&
          _selectedDate!.day == now.day;
      final dateStr = _selectedDate != null
          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}${isToday ? ' (Hoy)' : ''}'
          : 'Seleccionar fecha';
      final timeStr = _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : 'Seleccionar hora (9:00 AM - 9:00 PM)';

      return ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Selector de Servicios (uno o más, sin duplicados)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('1. SERVICIOS ', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                          ),
                          child: Text(
                            '${_selectedServices.length} sel.',
                            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Total: ${SupabaseService.formatPrice(_totalPrice)}',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Toca para seleccionar uno o más servicios (sin duplicados):', style: TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 12),
                ...widget.services.map((s) {
                  final isSelected = _selectedServiceIds.contains(s.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _toggleService(s),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent.withOpacity(0.16) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.accent : Colors.white12,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.accent : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              s.price,
                              style: TextStyle(
                                color: isSelected ? AppColors.accent : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Selección de Fecha
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. FECHA DE LA CITA', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                const SizedBox(height: 14),
                _PickerButton(icon: Icons.calendar_month_rounded, label: dateStr, onTap: _pickDate),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Selección de Hora con reloj (9 AM a 9 PM)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('3. HORA DE LA CITA', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text('9:00 AM - 9:00 PM', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Horario de atención permitido. No se admiten horas pasadas ni horarios ocupados.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 14),
                _PickerButton(icon: Icons.access_time_rounded, label: timeStr, onTap: _pickTime),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Step 1: Confirmation
    final dateStr = _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'No seleccionada';
    final timeStr = _selectedTime != null ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}' : 'No seleccionada';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.panel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RESUMEN DE RESERVA', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
              const StatusBadge(status: 'pendiente'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('SERVICIOS SELECCIONADOS:', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          ..._selectedServices.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.accent, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                Text(s.price, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )),
          const Divider(color: Colors.white12, height: 24),
          _SummaryRow(label: 'Fecha solicitada', value: dateStr),
          _SummaryRow(label: 'Hora acordada', value: timeStr),
          _SummaryRow(
            label: 'Monto Total Estimado',
            value: SupabaseService.formatPrice(_totalPrice),
            valueColor: AppColors.accent,
            last: true,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Se enviará un recordatorio y confirmación en tiempo real a tu perfil.',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.valueColor = Colors.white, this.last = false});
  final String label;
  final String value;
  final Color valueColor;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: Row(children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 18),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w900)))
        ]),
      );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedDay = DateTime.now().day;
  bool _isLoadingEvents = false;
  List<String> _dayEvents = [];
  Set<int> _markedDays = {};
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _loadMonthData();
    _loadEventsForDay(_selectedDay);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _loadMonthData() async {
    try {
      final now = DateTime.now();
      final bookings = await SupabaseService.getBookingsForMonth(now.year, now.month);
      final Set<int> days = {};
      for (var b in bookings) {
        if (b['fecha'] != null) {
          final date = DateTime.parse(b['fecha'].toString());
          days.add(date.day);
        }
      }
      if (mounted) setState(() => _markedDays = days);
    } catch (e) {
      debugPrint('Error loading month: $e');
    }
  }

  Future<void> _loadEventsForDay(int day) async {
    setState(() => _isLoadingEvents = true);
    try {
      final now = DateTime.now();
      final targetDate = DateTime(now.year, now.month, day);
      final events = await SupabaseService.getBookingsForDay(targetDate);
      
      final List<String> eventStrings = events.map((event) {
        final hora = event['hora']?.toString().substring(0, 5) ?? '00:00';
        final servicio = (event['notas'] != null && event['notas'].toString().startsWith('Servicios:'))
            ? event['notas'].toString().replaceFirst('Servicios: ', '')
            : (event['servicio']?['nombre'] ?? 'Servicio');
        return '$hora - $servicio';
      }).toList();
      
      if (mounted) setState(() => _dayEvents = eventStrings);
    } catch (e) {
      debugPrint('Error loading day: $e');
    } finally {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  void _onDaySelected(int day) {
    setState(() => _selectedDay = day);
    _loadEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayWeekday = DateTime(now.year, now.month, 1).weekday; // 1 = Lunes, 7 = Domingo

    return Scaffold(
      backgroundColor: AppColors.canvas,
      bottomNavigationBar: ClientBottomNavigation(active: AppSection.dashboard, navigate: widget.navigate),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?auto=format&fit=crop&w=1200&q=80',
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
                    AppColors.canvas.withOpacity(0.7),
                    AppColors.canvas.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
              children: [
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.3))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text.rich(TextSpan(text: 'Mis ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1.0, color: Colors.white, letterSpacing: -1.0), children: [TextSpan(text: 'Citas', style: TextStyle(color: AppColors.accent))])),
                      ),
                      NotificationBell(onTap: () => widget.navigate(AppSection.notifications)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.1, 0.4))),
                  child: const Text('Visualiza y gestiona todas las citas del taller', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const SizedBox(height: 24),
                
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.5))),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.5, curve: Curves.easeOut))),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.panel.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_getMonthName(now.month)} ${now.year}'.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
                              const Icon(Icons.calendar_month_outlined, color: AppColors.accent, size: 20),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_Weekday('L'), _Weekday('M'), _Weekday('X'), _Weekday('J'), _Weekday('V'), _Weekday('S'), _Weekday('D')]),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 42,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                            itemBuilder: (context, index) {
                              final dayOffset = index - (firstDayWeekday - 1);
                              final day = dayOffset + 1;
                              if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
                              
                              final selected = day == _selectedDay;
                              final marked = _markedDays.contains(day);
                              final isToday = day == DateTime.now().day;
                              
                              return InkWell(
                                onTap: () => _onDaySelected(day),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.accent : Colors.transparent,
                                    border: isToday && !selected ? Border.all(color: AppColors.accent.withOpacity(0.5), width: 2) : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$day', style: TextStyle(color: selected ? Colors.white : (marked ? Colors.white : Colors.white60), fontSize: 13, fontWeight: marked || selected ? FontWeight.w900 : FontWeight.w600)),
                                      if (marked)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(color: selected ? Colors.white : AppColors.accent, shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.4, 0.8))),
                  child: const Text('CITAS DEL DÍA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white54)),
                ),
                const SizedBox(height: 12),
                
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.5, 0.9))),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.5, 0.9, curve: Curves.easeOut))),
                    child: Builder(
                      builder: (context) {
                        if (_isLoadingEvents) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: AppColors.accent)));
                        if (_dayEvents.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.panel.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12, style: BorderStyle.solid)),
                            child: const Center(child: Text('No tienes citas agendadas para este día.', style: TextStyle(color: Colors.white54, fontSize: 13))),
                          );
                        }
                        return Column(
                          children: _dayEvents.map((eventText) => 
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.panel.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.access_time_filled, color: AppColors.accent, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: Text(eventText, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                                ],
                              ),
                            )
                          ).toList(),
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700));
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  int _currentTab = 0; // 0 = Citas, 1 = Vehículos, 2 = Perfil
  
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _loadData();
  }
  
  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SupabaseService.getUserProfile();
      final bookings = await SupabaseService.getUserBookings();
      final vehicles = await SupabaseService.getUserVehicles();
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _bookings = bookings;
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(int id) async {
    try {
      await SupabaseService.cancelBooking(id);
      await _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita cancelada exitosamente')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cancelar: $e')));
    }
  }

  void _showEditBookingDialog(Map<String, dynamic> booking) {
    DateTime selectedDate = DateTime.parse(booking['fecha'].toString());
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(booking['hora'].toString().split(':')[0]),
      minute: int.parse(booking['hora'].toString().split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (contextStateful, setStateDialog) {
          final dateStr = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
          final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
          
          return AlertDialog(
            backgroundColor: AppColors.canvas,
            title: const Text('Reprogramar Cita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona nueva fecha y hora (9:00 AM a 9:00 PM):', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                _PickerButton(
                  icon: Icons.calendar_month_outlined,
                  label: dateStr,
                  onTap: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 90)),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.panel)),
                        child: child!,
                      ),
                    );
                    if (d != null) setStateDialog(() => selectedDate = d);
                  },
                ),
                const SizedBox(height: 16),
                _PickerButton(
                  icon: Icons.access_time_outlined,
                  label: '$timeStr (9 AM - 9 PM)',
                  onTap: () async {
                    final t = await showTimePicker(
                      context: dialogContext,
                      initialTime: selectedTime,
                      helpText: 'HORARIO: 9:00 AM - 9:00 PM',
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.panel)),
                        child: child!,
                      ),
                    );
                    if (t != null) {
                      if (!SupabaseService.isValidOperatingHour(t.hour, t.minute)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Las citas solo se pueden agendar entre las 9:00 AM y las 9:00 PM.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      final now = DateTime.now();
                      final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
                      if (isToday) {
                        final appt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, t.hour, t.minute);
                        if (appt.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No puedes reprogramar a una hora anterior a la actual.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                      }
                      setStateDialog(() => selectedTime = t);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
                onPressed: () async {
                  if (!SupabaseService.isValidOperatingHour(selectedTime.hour, selectedTime.minute)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Las citas solo se pueden agendar entre las 9:00 AM y las 9:00 PM.'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }

                  final now = DateTime.now();
                  final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
                  if (isToday) {
                    final appt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                    if (appt.isBefore(now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No puedes reprogramar a una hora anterior a la actual.'), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }
                  }

                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  setState(() => _isLoading = true);
                  try {
                    await SupabaseService.updateBookingDate(booking['id_cita'], selectedDate, timeStr);
                    await _loadData();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cita reprogramada exitosamente!')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAddVehicleDialog() {
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final plateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.canvas,
        title: const Text('Nuevo Vehículo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brandCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Marca (ej. Chevrolet, Mazda)',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Modelo o Línea (ej. Spark 2020)',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [LengthLimitingTextInputFormatter(6)],
              style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Placa (ej. ABC123)',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            onPressed: () async {
              final brand = brandCtrl.text.trim();
              final model = modelCtrl.text.trim();
              final plate = AuthService.normalizePlate(plateCtrl.text);

              if (brand.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa la marca del vehículo')));
                return;
              }
              if (!AuthService.isValidPlate(plate)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La placa debe tener 3 letras y 3 números (ej. ABC123). No se permite 000000.')));
                return;
              }

              Navigator.pop(dialogContext);
              if (!mounted) return;
              setState(() => _isLoading = true);
              try {
                await SupabaseService.addVehicle(brand, model, plate);
                await _loadData();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehículo agregado exitosamente')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog(Map<String, dynamic> vehicle) {
    final brandCtrl = TextEditingController(text: vehicle['marca'] ?? '');
    final modelCtrl = TextEditingController(text: vehicle['modelo'] ?? '');
    final plateCtrl = TextEditingController(text: vehicle['placa'] ?? '');
    final int vehicleId = int.tryParse(vehicle['id_vehiculo'].toString()) ?? 0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.canvas,
        title: const Text('Editar Vehículo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brandCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Marca',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Modelo o Línea',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [LengthLimitingTextInputFormatter(6)],
              style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Placa (ej. ABC123)',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            onPressed: () async {
              final brand = brandCtrl.text.trim();
              final model = modelCtrl.text.trim();
              final plate = AuthService.normalizePlate(plateCtrl.text);

              if (brand.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa la marca del vehículo')));
                return;
              }
              if (!AuthService.isValidPlate(plate)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La placa debe tener 3 letras y 3 números (ej. ABC123). No se permite 000000.')));
                return;
              }

              Navigator.pop(dialogContext);
              if (!mounted) return;
              setState(() => _isLoading = true);
              try {
                await SupabaseService.updateVehicle(
                  vehicleId: vehicleId,
                  brand: brand,
                  model: model,
                  plate: plate,
                );
                await _loadData();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehículo actualizado exitosamente')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile?['nombre'] ?? '');
    final emailCtrl = TextEditingController(text: _profile?['correo'] ?? _profile?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile?['telefono'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.canvas,
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white54, size: 20),
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico (ej. usuario@gmail.com)',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 20),
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Teléfono (ej. 3001234567)',
                  prefixIcon: const Icon(Icons.phone_android_outlined, color: Colors.white54, size: 20),
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final email = emailCtrl.text.trim();
              final phone = phoneCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa tu nombre')));
                return;
              }
              if (!AuthService.isValidEmail(email)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa un correo electrónico válido con dominio (ej. usuario@dominio.com)')));
                return;
              }
              if (!AuthService.isValidColombianPhone(phone)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El teléfono debe tener mínimo 10 dígitos y empezar por 3')));
                return;
              }

              Navigator.pop(dialogContext);
              if (!mounted) return;
              setState(() => _isLoading = true);
              try {
                await SupabaseService.updateUserProfile(
                  name: name,
                  email: email,
                  phone: phone,
                );
                await _loadData();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Perfil actualizado exitosamente!')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      bottomNavigationBar: ClientBottomNavigation(active: AppSection.history, navigate: widget.navigate),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?auto=format&fit=crop&w=1200&q=80',
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
                  colors: [AppColors.canvas.withOpacity(0.7), AppColors.canvas.withOpacity(0.95)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.4))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 28, backgroundColor: AppColors.accent, child: Text(_profile?['nombre']?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_profile?['nombre'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(_profile?['correo'] ?? _profile?['email'] ?? 'Sin correo', style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          IconButton(onPressed: _showEditProfileDialog, icon: const Icon(Icons.edit_outlined, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Tabs
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.2, 0.5))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildTab(0, 'Citas', Icons.calendar_month_outlined),
                          const SizedBox(width: 12),
                          _buildTab(1, 'Vehículos', Icons.directions_car_outlined),
                          const SizedBox(width: 12),
                          _buildTab(2, 'Perfil', Icons.person_outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Content
                  Expanded(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.3, 0.8))),
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.3, 0.8, curve: Curves.easeOut))),
                        child: _buildTabContent(),
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final active = _currentTab == index;
    return Expanded(
      child: Material(
        color: active ? AppColors.accent : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _currentTab = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: active ? AppColors.accent : Colors.white12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: active ? Colors.white : Colors.white54, size: 20),
                const SizedBox(height: 6),
                Text(title, style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_currentTab == 0) {
      if (_bookings.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy_rounded, size: 48, color: Colors.white30),
                const SizedBox(height: 12),
                const Text('No tienes citas agendadas aún.', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => widget.navigate(AppSection.booking),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agendar mi primera cita'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                ),
              ],
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        itemCount: _bookings.length,
        itemBuilder: (context, i) {
          final b = _bookings[i];
          final rawStatus = b['estado']?.toString() ?? 'pendiente';
          final isCanceled = rawStatus.toLowerCase() == 'cancelada';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.panel.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text('${b['fecha']}  ${b['hora']?.toString().substring(0, 5)}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    StatusBadge(status: rawStatus),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  (b['notas'] != null && b['notas'].toString().startsWith('Servicios:'))
                      ? b['notas'].toString().replaceFirst('Servicios: ', '')
                      : (b['servicio']?['nombre'] ?? 'Servicio'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  SupabaseService.formatPrice(
                    b['monto'] != null && (b['monto'] as num) > 0
                        ? b['monto']
                        : b['servicio']?['precio'],
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
                const SizedBox(height: 16),
                if (!isCanceled) Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditBookingDialog(b),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Reprogramar'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelBooking(b['id_cita']),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else if (_currentTab == 1) {
      return Column(
        children: [
          Expanded(
            child: _vehicles.isEmpty 
            ? const Center(child: Text('No tienes vehículos registrados.', style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                itemCount: _vehicles.length,
                itemBuilder: (context, i) {
                  final v = _vehicles[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panel.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.directions_car, color: AppColors.accent)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v['marca'] ?? 'Desconocida', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('Modelo: ${v['modelo']} | Placa: ${v['placa']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                          tooltip: 'Editar vehículo',
                          onPressed: () => _showEditVehicleDialog(v),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showAddVehicleDialog,
                icon: const Icon(Icons.add),
                label: const Text('AGREGAR VEHÍCULO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ),
          ),
        ],
      );
    } else {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.panel.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DATOS PERSONALES', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    TextButton.icon(
                      onPressed: _showEditProfileDialog,
                      icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.accent),
                      label: const Text('EDITAR', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w800)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.person_outline, label: 'Nombre', value: _profile?['nombre'] ?? '-'),
                const Divider(color: Colors.white12, height: 32),
                _InfoRow(icon: Icons.email_outlined, label: 'Correo', value: _profile?['correo'] ?? _profile?['email'] ?? '-'),
                const Divider(color: Colors.white12, height: 32),
                _InfoRow(icon: Icons.phone_outlined, label: 'Teléfono', value: _profile?['telefono'] ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Here we would call Supabase auth sign out if we were using it:
                // await Supabase.instance.client.auth.signOut();
                widget.navigate(AppSection.login);
              },
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.accent, size: 20),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ],
  );
}
