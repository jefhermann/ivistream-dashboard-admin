import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    if (token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    if (token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
