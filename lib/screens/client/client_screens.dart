import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../models/managed_service.dart';
import '../../widgets/layout.dart';
import '../../widgets/navigation_bars.dart';
import '../../services/supabase_service.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.navigate, required this.services});

  final ValueChanged<AppSection> navigate;
  final List<ManagedService> services;

  @override
  Widget build(BuildContext context) => AppPage(
        bottomNavigation: ClientBottomNavigation(active: AppSection.services, navigate: navigate),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 38, 20, 18),
          children: [
            const Text('Servicios Generales', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 5),
            const Text('Selecciona el servicio que necesitas.', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),
            if (services.isEmpty)
              const EmptyState(icon: Icons.design_services_outlined, label: 'No hay servicios activos en este momento.')
            else
              for (final service in services) ...[
                _ServiceCard(service: service, onTap: () => navigate(AppSection.booking)),
                const SizedBox(height: 12),
              ],
          ],
        ),
      );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final ManagedService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(border: Border.all(color: AppColors.accent.withOpacity(.32)), borderRadius: BorderRadius.circular(17)),
            child: Row(
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.accent.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.build_outlined, color: AppColors.accent, size: 27)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(service.description, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.35)),
                      const SizedBox(height: 6),
                      Text(service.price, style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.navigate, required this.services});

  final ValueChanged<AppSection> navigate;
  final List<ManagedService> services;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  int _serviceIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
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
    if (time != null && mounted) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _confirmBooking(ManagedService selectedService) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona fecha y hora')));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      await SupabaseService.createBooking(
        idServicio: int.parse(selectedService.id),
        date: _selectedDate!,
        time: timeString,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cita guardada en Supabase exitosamente!')));
        widget.navigate(AppSection.dashboard);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasServices = widget.services.isNotEmpty;
    final safeServiceIndex = _serviceIndex >= widget.services.length ? widget.services.length - 1 : _serviceIndex;
    final selectedService = hasServices ? widget.services[safeServiceIndex] : null;
    const steps = ['Modulo', 'Fecha', 'Confirmacion'];
    return AppPage(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(onPressed: () => widget.navigate(AppSection.services), icon: const Icon(Icons.arrow_back, size: 17), label: const Text('Volver'), style: TextButton.styleFrom(foregroundColor: Colors.white54, textStyle: const TextStyle(fontSize: 12))),
            const SizedBox(height: 18),
            const Text('PROGRAMACION\nDE', style: TextStyle(fontSize: 37, fontWeight: FontWeight.w900, height: .9)),
            const Text('SERVICIOS', style: TextStyle(color: AppColors.accent, fontSize: 37, fontWeight: FontWeight.w900, height: .9)),
            const SizedBox(height: 14),
            const Text('Completa la secuencia para asegurar tu espacio.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            Row(children: List.generate(3, (index) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: index == 2 ? 0 : 8), decoration: BoxDecoration(color: index <= _step ? AppColors.accent : const Color(0xFF333333), borderRadius: BorderRadius.circular(8)))))),
            const SizedBox(height: 8),
            Text('0${_step + 1} - SELECCION DE ${steps[_step].toUpperCase()}', style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
            const SizedBox(height: 18),
            Expanded(child: _buildStep(selectedService)),
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : PrimaryButton(
                  label: _step == 2 ? 'CONFIRMAR CITA' : 'SIGUIENTE FASE',
                  margin: EdgeInsets.zero,
                  onPressed: hasServices
                      ? () {
                          if (_step < 2) {
                            setState(() => _step++);
                          } else {
                            if (selectedService != null) _confirmBooking(selectedService);
                          }
                        }
                      : () => widget.navigate(AppSection.services),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ManagedService? selectedService) {
    if (widget.services.isEmpty) return const EmptyState(icon: Icons.design_services_outlined, label: 'No hay servicios activos para reservar.');
    if (_step == 0) {
      return ListView.builder(
        itemCount: widget.services.length,
        itemBuilder: (context, index) {
          final service = widget.services[index];
          final selected = index == _serviceIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: selected ? AppColors.accent.withOpacity(0.1) : AppColors.panel,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => setState(() => _serviceIndex = index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: selected ? AppColors.accent : AppColors.line), borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(service.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), const SizedBox(height: 5), Text(service.description, style: const TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 14), Text(service.price, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14))]),
                ),
              ),
            ),
          );
        },
      );
    }
    if (_step == 1) {
      final dateStr = _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'Seleccionar fecha';
      final timeStr = _selectedTime != null ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}' : 'Seleccionar hora';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(17)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SELECCIONA FECHA Y HORA', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.2)), 
          const SizedBox(height: 24), 
          _PickerButton(icon: Icons.calendar_today, label: dateStr, onTap: _pickDate),
          const SizedBox(height: 16), 
          _PickerButton(icon: Icons.access_time, label: timeStr, onTap: _pickTime),
        ]),
      );
    }
    
    final dateStr = _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'No seleccionada';
    final timeStr = _selectedTime != null ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}' : 'No seleccionada';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(17)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('RESUMEN DE CITA', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.2)), const SizedBox(height: 14), _SummaryRow(label: 'Servicio', value: selectedService!.name), _SummaryRow(label: 'Fecha', value: dateStr), _SummaryRow(label: 'Hora', value: timeStr), _SummaryRow(label: 'Monto', value: selectedService.price, valueColor: AppColors.accent, last: true)]),
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
    color: AppColors.field,
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(children: [Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)), const SizedBox(width: 18), Expanded(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w800)))]),
      );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedDay = 10;
  bool _isLoading = false;
  List<String> _dayEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEventsForDay(_selectedDay);
  }

  Future<void> _loadEventsForDay(int day) async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final targetDate = DateTime(now.year, now.month, day);
      final events = await SupabaseService.getBookingsForDay(targetDate);
      
      final List<String> eventStrings = events.map((event) {
        final hora = event['hora']?.toString().substring(0, 5) ?? '00:00'; // "09:00:00" -> "09:00"
        final servicio = event['servicio']?['nombre'] ?? 'Servicio';
        return '$hora - $servicio';
      }).toList();
      
      if (mounted) setState(() => _dayEvents = eventStrings);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDaySelected(int day) {
    setState(() {
      _selectedDay = day;
    });
    _loadEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      bottomNavigation: ClientBottomNavigation(active: AppSection.dashboard, navigate: widget.navigate),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 38, 20, 18),
        children: [
          const Text.rich(TextSpan(text: 'Driven Yield ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1), children: [TextSpan(text: 'Citas', style: TextStyle(color: AppColors.accent))])),
          const SizedBox(height: 8),
          const Text('Visualiza y gestiona todas las citas del taller', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 24),
          const Row(children: [Expanded(child: _StatCard(number: '4', label: 'Pendientes', border: Color(0xFFE8A000))), SizedBox(width: 12), Expanded(child: _StatCard(number: '12', label: 'Confirmadas', border: Color(0xFF5555CC)))]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(17)),
            child: Column(children: [const Text('AGOSTO 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)), const SizedBox(height: 16), const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_Weekday('L'), _Weekday('M'), _Weekday('X'), _Weekday('J'), _Weekday('V'), _Weekday('S'), _Weekday('D')]), const SizedBox(height: 5), GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 36, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1), itemBuilder: (context, index) { if (index < 5) return const SizedBox.shrink(); final day = index - 4; if (day > 31) return const SizedBox.shrink(); final selected = day == _selectedDay; final marked = day == 10 || day == 14; final today = day == 4; return InkWell(onTap: () => _onDaySelected(day), borderRadius: BorderRadius.circular(9), child: Container(margin: const EdgeInsets.all(2), alignment: Alignment.center, decoration: BoxDecoration(color: selected ? AppColors.accent : Colors.transparent, border: today && !selected ? Border.all(color: AppColors.accent) : null, borderRadius: BorderRadius.circular(8)), child: Text('$day', style: TextStyle(color: selected ? Colors.white : (marked ? AppColors.accent : Colors.white60), fontSize: 12, fontWeight: marked || selected ? FontWeight.w800 : FontWeight.w500)))); })]),
          ),
          const SizedBox(height: 14),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(15), child: Center(child: CircularProgressIndicator(color: AppColors.accent)))
          else if (_dayEvents.isEmpty)
            const Padding(padding: EdgeInsets.all(15), child: Center(child: Text('Sin citas para este dia', style: TextStyle(color: Colors.white30, fontSize: 13))))
          else
            ..._dayEvents.map((eventText) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(color: AppColors.panel, borderRadius: BorderRadius.circular(13), child: InkWell(onTap: () => widget.navigate(AppSection.history), borderRadius: BorderRadius.circular(13), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(13)), child: Text(eventText, style: const TextStyle(color: Colors.white70, fontSize: 13))))),
              )
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.number, required this.label, required this.border});
  final String number;
  final String label;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(16), border: Border(bottom: BorderSide(color: border, width: 3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(number, style: const TextStyle(fontSize: 35, height: 1, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11))]));
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700));
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.navigate});
  final ValueChanged<AppSection> navigate;

  @override
  Widget build(BuildContext context) {
    const entries = [
      _HistoryEntry('2026-08-10', '10:00', 'PENDIENTE', 'Mantenimiento Preventivo', r'$120,000 COP', AppColors.warning),
      _HistoryEntry('2026-07-20', '14:00', 'COMPLETADA', 'Revision de Frenos', r'$80,000 COP', Color(0xFF00AA55)),
      _HistoryEntry('2026-06-05', '09:00', 'COMPLETADA', 'Diagnostico Electronico', r'$80,000 COP', Color(0xFF00AA55)),
    ];
    return AppPage(
      bottomNavigation: ClientBottomNavigation(active: AppSection.history, navigate: navigate),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 38, 20, 18),
        children: [
          const Row(children: [CircleAvatar(radius: 24, backgroundColor: AppColors.accent, child: Text('C', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21))), SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Carlos M.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), SizedBox(height: 3), Text('CLIENTE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4))])]),
          const SizedBox(height: 34),
          const Text('HISTORIAL DE CITAS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          for (var index = 0; index < entries.length; index++) _TimelineCard(entry: entries[index], current: index == 0, isLast: index == entries.length - 1),
          PrimaryButton(label: 'NUEVA CITA', onPressed: () => navigate(AppSection.booking)),
        ],
      ),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry(this.date, this.time, this.status, this.title, this.amount, this.color);
  final String date;
  final String time;
  final String status;
  final String title;
  final String amount;
  final Color color;
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.entry, required this.current, required this.isLast});
  final _HistoryEntry entry;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(width: 27, child: Column(children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: current ? AppColors.accent : AppColors.canvas, shape: BoxShape.circle, border: Border.all(color: current ? AppColors.accent : const Color(0xFF444444), width: 2))), if (!isLast) Expanded(child: Container(width: 1, color: AppColors.accent.withOpacity(.3)))])),
          Expanded(child: Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.panel, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text('${entry.date} | ${entry.time}', style: const TextStyle(color: Colors.white54, fontSize: 11))), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: entry.color.withOpacity(.13), borderRadius: BorderRadius.circular(5)), child: Text(entry.status, style: TextStyle(color: entry.color, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: .8)))]), const SizedBox(height: 12), Text(entry.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('Monto: ${entry.amount}', style: const TextStyle(color: Colors.white54, fontSize: 12))]))),
        ]),
      );
}
