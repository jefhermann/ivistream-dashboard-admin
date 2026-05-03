import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBluePrimary = AppBrandColors.shade700;
  static const Color colorBlueLight = Color(0xFFebf0f4);
  static const Color colorRedSecondary = Color(0xfff35c49);
  static const Color backgroundBodyColor = Color(0xFF0a0e17);
  static const Color backgroundBodyLightColor = Colors.white;
  static const Color bottomNavigationBarColor = Colors.black;
  static const Color colorGrey = Color(0xFFE5E9EC);
  static const Color colorGrayDark = Color(0xFF888888);
  static const Color colorGrayDarker = Color(0xFF272727);

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class AppBrandColors {
  AppBrandColors._();

  static const Color shade900 = Color(0xFF0078BD);
  static const Color shade700 = Color(0xFF0099D1);
  static const Color shade500 = Color(0xFF00AFEF);
  static const Color shade300 = Color(0xFF36C9FF);
  static const Color shade100 = Color(0xFFB7EBFF);
}
