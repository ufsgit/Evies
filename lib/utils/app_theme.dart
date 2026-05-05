import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF5C6BC0); // Indigo
  static const Color secondaryColor = Color(0xFF90CAF9); // Light Blue
  static const Color accentColor = Color(0xFFE1BEE7); // Light Purple
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color subtitleColor = Color(0xFF757575);
  static const Color successColor = Color(0xFF2E7D32);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [secondaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient overlayGradient = LinearGradient(
    colors: [primaryColor.withValues(alpha: 0.3), primaryColor.withValues(alpha: 0.0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Borders
  static const double borderRadiusValue = 30.0;
  static const double cardRadiusValue = 20.0;

  static const BorderRadius curvedBorder = BorderRadius.only(
    bottomLeft: Radius.circular(borderRadiusValue),
    bottomRight: Radius.circular(borderRadiusValue),
  );

  static const BorderRadius curvedTopBorder = BorderRadius.only(
    topLeft: Radius.circular(borderRadiusValue),
    topRight: Radius.circular(borderRadiusValue),
  );

  static BorderRadius cardRadius = BorderRadius.circular(cardRadiusValue);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> navbarShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, -5),
    ),
  ];

  // Text Styles
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle bodyText = GoogleFonts.inter(
    fontSize: 14,
    color: textColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 12,
    color: subtitleColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle hintStyle = GoogleFonts.inter(
    color: Colors.grey.shade400,
    fontSize: 14,
  );
}
