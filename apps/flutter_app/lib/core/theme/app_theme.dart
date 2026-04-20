import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color pine = Color(0xFF28584A);
  static const Color cream = Color(0xFFF8F3EA);
  static const Color sand = Color(0xFFE7D9C4);
  static const Color ink = Color(0xFF1A1F1D);

  static CupertinoThemeData get light {
    final textStyle = GoogleFonts.manrope(
      color: ink,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
    );

    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: pine,
      scaffoldBackgroundColor: cream,
      barBackgroundColor: const Color(0xFFF1E8D9),
      textTheme: CupertinoTextThemeData(
        textStyle: textStyle,
        navTitleTextStyle: GoogleFonts.manrope(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        navLargeTitleTextStyle: GoogleFonts.manrope(
          color: ink,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}
