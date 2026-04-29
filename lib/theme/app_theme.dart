import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const bg       = Color(0xFF0A0C10);
  static const surface  = Color(0xFF111318);
  static const surface2 = Color(0xFF181C24);
  static const border   = Color(0xFF252B3B);
  static const accent   = Color(0xFF00E5A0);
  static const blue     = Color(0xFF0099FF);
  static const orange   = Color(0xFFFF6B35);
  static const profit   = Color(0xFF00E5A0);
  static const loss     = Color(0xFFFF4560);
  static const warn     = Color(0xFFFFD60A);
  static const text     = Color(0xFFE8ECF4);
  static const muted    = Color(0xFF6B7898);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: C.bg,
  colorScheme: const ColorScheme.dark(
    surface: C.surface,
    primary: C.accent,
    secondary: C.blue,
    error: C.loss,
    onSurface: C.text,
    onPrimary: C.bg,
  ),
  textTheme: GoogleFonts.interTextTheme(const TextTheme(
    displayLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: C.text),
    displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: C.text),
    headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.text),
    titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.text),
    bodyMedium:    TextStyle(fontSize: 13, color: C.text),
    bodySmall:     TextStyle(fontSize: 12, color: C.muted),
    labelSmall:    TextStyle(fontSize: 10, color: C.muted, letterSpacing: 1.2),
  )),
  appBarTheme: AppBarTheme(
    backgroundColor: C.surface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(color: C.text),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: C.text,
    ),
  ),
  cardTheme: CardThemeData(
    color: C.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: C.border),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: C.surface2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: C.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: C.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: C.accent),
    ),
    hintStyle: const TextStyle(color: C.muted, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: C.surface,
    selectedItemColor: C.accent,
    unselectedItemColor: C.muted,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
  dividerTheme: const DividerThemeData(color: C.border, thickness: 1, space: 1),
);
