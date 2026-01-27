import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const double _borderRadius = 12.0;

  /// Builds a TextTheme scaled by the given factor
  static TextTheme _buildTextTheme(double scale) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 24 * scale,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 20 * scale,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16 * scale),
      bodyMedium: TextStyle(fontSize: 15 * scale),
      bodySmall: TextStyle(fontSize: 12 * scale),
      labelLarge: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500),
    );
  }

  // --- LIGHT MODE ---
  static ThemeData lightTheme([double textScale = 1.0]) {
    final textTheme = _buildTextTheme(textScale);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.grey[600]!,
        surface: Colors.grey[50]!,
        onSurface: Colors.black,
        error: Colors.red[700]!,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20 * textScale,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.grey[300],
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: Colors.black, size: 24 * textScale);
          }
          return IconThemeData(color: Colors.grey, size: 24 * textScale);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12 * textScale,
            );
          }
          return TextStyle(color: Colors.grey, fontSize: 12 * textScale);
        }),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppColors(
          limitColor: Color(0xFF2E7D32),
          expenseColor: Color(0xFFC62828),
        ),
      ],
    );
  }

  // --- DARK MODE ---
  static ThemeData darkTheme([double textScale = 1.0]) {
    final textTheme = _buildTextTheme(textScale);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,
      colorScheme: ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.grey[400]!,
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
        error: Colors.red[400]!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20 * textScale,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.white24,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: Colors.white, size: 24 * textScale);
          }
          return IconThemeData(color: Colors.grey, size: 24 * textScale);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12 * textScale,
            );
          }
          return TextStyle(color: Colors.grey, fontSize: 12 * textScale);
        }),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppColors(
          limitColor: Color(0xFF66BB6A),
          expenseColor: Color(0xFFEF5350),
        ),
      ],
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color? limitColor;
  final Color? expenseColor;

  const AppColors({this.limitColor, this.expenseColor});

  @override
  AppColors copyWith({Color? limitColor, Color? expenseColor}) {
    return AppColors(
      limitColor: limitColor ?? this.limitColor,
      expenseColor: expenseColor ?? this.expenseColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      limitColor: Color.lerp(limitColor, other.limitColor, t),
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t),
    );
  }
}
