import 'package:flutter/material.dart';

class AppStyles {
  static const String fontFamily = 'Gilroy';

  static var light = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
  );

  static var regular = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static var medium = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );

  static var semiBold = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
  );

  static var bold = const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w900,
  );
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppGradients {
  static const List<LinearGradient> cycle = [
    LinearGradient(
      colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF059669), Color(0xFF0EA5E9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}


