import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'IviStream Admin';

  // Changer selon l'environnement
  static String get apiBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      // localhost ou 127.0.0.1 → dev
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:3000/api';
      }
    }
    // Firebase Hosting ou autre → prod
    return 'https://backend-production-bdeb4.up.railway.app/api';
  }
}
