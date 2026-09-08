import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ibbvkithrrhpbdrnqnha.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliYnZraXRocnJocGJkcm5xbmhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0OTcyMTMsImV4cCI6MjA5ODA3MzIxM30.hGay-zzzD5NiL8YU8BT1No22TXbSypL6w-sO1rvbBcs',
  );

  // Notificaciones locales: necesarias para la alerta de éxito/error al
  // registrar una cita (NotificationService.showBookingResult).
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  try {
    await Firebase.initializeApp();
    await FcmService.instance.init();
  } catch (e) {
    print('Firebase no está configurado, omitiendo inicialización: $e');
  }

  runApp(const DrivenYieldApp());
}
