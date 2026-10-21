import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarakiTheme {
  // Authentic Automotive Palette: High-contrast Obsidian, Warm Titanium, Signal Orange
  static const Color primaryPapaya = Color(0xFFFF4D00);
  static const Color racingCrimson = Color(0xFFE52535);
  static const Color warmGold = Color(0xFFF59E0B);

  // Backward-compatible aliases
  static const Color primaryElectricBlue = primaryPapaya;
  static const Color accentCyan = Color(0xFFFF7300);

  // High-contrast semantic status colors
  static const Color statusGreen = Color(0xFF1ED760);
  static const Color statusAmber = Color(0xFFFFA800);
  static const Color statusRed = Color(0xFFFF3B30);

  static Color healthColor(double ratio) {
    if (ratio <= 0.15) return statusRed;
    if (ratio <= 0.35) return statusAmber;
    return statusGreen;
  }

  static Color daysRemainingColor(int days) {
    if (days <= 7) return statusRed;
    if (days <= 30) return statusAmber;
    return statusGreen;
  }

  static String formatKm(int km) {
    final fmt = NumberFormat('#,###', 'el_GR');
    return '${fmt.format(km)} χλμ';
  }

  static String formatCurrency(double amount) {
    final fmt = NumberFormat.currency(locale: 'el_GR', symbol: '€', decimalDigits: 2);
    return fmt.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static ThemeData darkTheme() {
    const bgObsidian = Color(0xFF000000); // True OLED Black for maximum contrast
    const cardSurface = Color(0xFF161618); // Solid iOS Dark Elevated Surface (no borders!)
    const secondarySurface = Color(0xFF242428);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgObsidian,
      colorScheme: const ColorScheme.dark(
        primary: primaryPapaya,
        onPrimary: Colors.white,
        secondary: Color(0xFFFF7300),
        onSecondary: Colors.black,
        surface: cardSurface,
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerHighest: secondarySurface,
        error: statusRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgObsidian,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // Zero colored or glowing borders! Pure surface hierarchy.
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPapaya,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPapaya,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0D0D0F),
        indicatorColor: secondarySurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            );
          }
          return const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E8E93), // Native iOS secondary label color
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondarySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static ThemeData lightTheme() {
    const bgStone = Color(0xFFF2F2F7); // Native iOS grouped background
    const cardWhite = Color(0xFFFFFFFF);
    const secondaryFill = Color(0xFFE5E5EA);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgStone,
      colorScheme: const ColorScheme.light(
        primary: primaryPapaya,
        onPrimary: Colors.white,
        secondary: Color(0xFF1C1C1E),
        surface: cardWhite,
        onSurface: Color(0xFF000000),
        surfaceContainerHighest: secondaryFill,
        error: statusRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgStone,
        foregroundColor: Color(0xFF000000),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: secondaryFill,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            );
          }
          return const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E8E93),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Clean Greek License Plate Widget
class GreekLicensePlateBadge extends StatelessWidget {
  final String plate;
  final bool compact;

  const GreekLicensePlateBadge({
    super.key,
    required this.plate,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 6,
              vertical: compact ? 3 : 4,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF003399),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              'GR',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 2 : 3,
            ),
            child: Text(
              plate.toUpperCase(),
              style: TextStyle(
                color: const Color(0xFF111113),
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
