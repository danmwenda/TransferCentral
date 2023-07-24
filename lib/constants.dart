import 'dart:ui';

import 'package:flutter/material.dart';

class routeNames {
  static const String splashScreen = '/splash';
  static const String homeScreenRoute = '/home';
  static const String favoriteTeamsDialogRoute = '/favoriteTeams';
  static const String teamNewsScreenRoute = '/teamNews';
}
class AppColors {
  static const int _primaryColorValue = 0xFF158744;

  static const MaterialColor primaryColor = MaterialColor(
    _primaryColorValue,
    <int, Color>{
      50: Color(0xFFF4FAF9),
      100: Color(0xFFE7F5F0),
      200: Color(0xFFD1ECE0),
      300: Color(0xFFB9E3CF),
      400: Color(0xFFA4DCC1),
      500: Color(_primaryColorValue),
      600: Color(0xFF1BB04A),
      700: Color(0xFF19A143),
      800: Color(0xFF17983C),
      900: Color(0xFF138A32),
    },
  );
}

