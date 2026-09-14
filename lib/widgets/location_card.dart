import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../services/location_service.dart';

/// Tarjeta visual e interactiva que muestra la ubicación del taller Driven Yield,
/// horarios de atención y botones para trazado de ruta con Google Maps / Waze.
class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    const details = LocationService.workshopAddress;
    const phone = LocationService.workshopPhoneFormatted;
    const hours = LocationService.workshopHours;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sede Principal Driven Yield',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Taller Mecánico & Detallado Automotriz',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Banner con mapa visual estilizado y coordenadas
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.panel,
                  AppColors.accent.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(Icons.map_rounded, size: 120, color: AppColors.accent),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.gps_fixed_rounded, color: AppColors.accent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'GPS: 4.5936° N, 74.1205° W',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bogotá, Colombia',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dirección y Horario
          _buildInfoRow(
            icon: Icons.place_outlined,
            title: 'Dirección:',
            value: details,
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 18),
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: details));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Dirección copiada al portapapeles!')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            title: 'Horario:',
            value: hours,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone_android_rounded,
            title: 'Contacto:',
            value: phone,
          ),
          const SizedBox(height: 16),

          // Botones de trazado de ruta en tiempo real
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.directions_car_rounded, size: 18),
                  label: const Text(
                    'Trazar Ruta',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () => LocationService.instance.openGoogleMaps(),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.navigation_rounded, color: Colors.cyanAccent, size: 18),
                label: const Text('Waze', style: TextStyle(fontSize: 13)),
                onPressed: () => LocationService.instance.openWaze(),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.greenAccent,
                ),
                icon: const Icon(Icons.call_rounded, size: 20),
                onPressed: () => LocationService.instance.callWorkshop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
