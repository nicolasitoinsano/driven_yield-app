import 'package:url_launcher/url_launcher.dart';

/// Servicio de Geolocalización y Mapas para el taller Driven Yield.
/// Gestiona la ubicación geográfica, trazado de rutas en tiempo real
/// (Google Maps, Waze, Apple Maps) y atención telefónica.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  // Coordenadas oficiales y datos del taller Driven Yield (Bogotá, Colombia)
  static const double workshopLatitude = 4.6533;
  static const double workshopLongitude = -74.0836;
  static const String workshopName = 'Driven Yield — Taller Automotriz';
  static const String workshopAddress = 'Carrera 30 #45-12, Bogotá, Colombia';
  static const String workshopPhone = '+573001234567';
  static const String workshopPhoneFormatted = '+57 300 123 4567';
  static const String workshopHours = 'Lun - Sáb: 8:00 AM - 6:00 PM';

  /// Retorna la información estructurada de la ubicación del taller.
  Map<String, dynamic> getWorkshopDetails() {
    return {
      'name': workshopName,
      'address': workshopAddress,
      'phone': workshopPhoneFormatted,
      'hours': workshopHours,
      'latitude': workshopLatitude,
      'longitude': workshopLongitude,
    };
  }

  /// Abre la navegación GPS y el marcador del taller en Google Maps.
  Future<bool> openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$workshopLatitude,$workshopLongitude',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final webUri = Uri.parse(
        'https://maps.google.com/?q=$workshopLatitude,$workshopLongitude',
      );
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Abre la navegación GPS paso a paso en la app Waze.
  Future<bool> openWaze() async {
    final uri = Uri.parse(
      'https://waze.com/ul?ll=$workshopLatitude,$workshopLongitude&navigate=yes',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Abre los mapas nativos de Apple Maps (iOS / macOS).
  Future<bool> openAppleMaps() async {
    final uri = Uri.parse(
      'https://maps.apple.com/?daddr=$workshopLatitude,$workshopLongitude&q=${Uri.encodeComponent(workshopName)}',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Inicia una llamada telefónica directa al taller.
  Future<bool> callWorkshop() async {
    final uri = Uri.parse('tel:$workshopPhone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
