import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle subHeading = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyBoldWhite = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle bodyBold13 = GoogleFonts.inter(
    fontSize: 13,
    color: Colors.grey[700],
  );

  static TextStyle small = GoogleFonts.inter(
    fontSize: 13,
    color: Colors.grey[700],
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    color: Colors.grey[600],
  );
}
