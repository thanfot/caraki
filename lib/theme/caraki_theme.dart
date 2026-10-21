import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarakiTheme {
  // Warm Motorsport Palette (Papaya Orange, Racing Red, Asphalt Carbon, Warm Ivory)
  static const Color primaryPapaya = Color(0xFFFF5500);
  static const Color racingCrimson = Color(0xFFE11D48);
  static const Color warmGold = Color(0xFFF59E0B);

  // Backward-compatible aliases so modals/screens use the new warm palette seamlessly
  static const Color primaryElectricBlue = primaryPapaya;
  static const Color accentCyan = Color(0xFFFF8A00);

  // Automotive status colors (Emerald Mint, Warm Amber, Racing Red)
  static const Color statusGreen = Color(0xFF00D68F);
  static const Color statusAmber = Color(0xFFFF9F1C);
  static const Color statusRed = Color(0xFFFF334B);

  /// Returns status color based on health ratio (0.0 to 1.0)
  static Color healthColor(double ratio) {
    if (ratio <= 0.15) return statusRed;
    if (ratio <= 0.35) return statusAmber;
    return statusGreen;
  }

  /// Returns status color based on remaining days for legal reminders
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
    const bgCarbon = Color(0xFF121214); // True Warm Asphalt Carbon
    const cardGraphite = Color(0xFF1C1C21); // Matte Graphite Surface
    const surfaceElevated = Color(0xFF27272E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgCarbon,
      colorScheme: const ColorScheme.dark(
        primary: primaryPapaya,
        onPrimary: Colors.white,
        secondary: Color(0xFFFF8A00),
        onSecondary: Colors.black,
        surface: cardGraphite,
        surfaceContainerHighest: surfaceElevated,
        error: statusRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF5F5F7),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardGraphite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.07), width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPapaya,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPapaya,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF18181C),
        indicatorColor: primaryPapaya.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF6D24),
            );
          }
          return TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.55),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPapaya, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static ThemeData lightTheme() {
    const bgIvory = Color(0xFFF6F4F0); // Warm Porsche Chalk / Alabaster
    const cardPure = Color(0xFFFFFFFF);
    const surfaceSand = Color(0xFFEBE7E0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgIvory,
      colorScheme: const ColorScheme.light(
        primary: primaryPapaya,
        onPrimary: Colors.white,
        secondary: Color(0xFFD97706),
        surface: cardPure,
        surfaceContainerHighest: surfaceSand,
        error: statusRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF18181B),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardPure,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE5E0D8), width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPapaya,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPapaya,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryPapaya.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: primaryPapaya,
            );
          }
          return const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF71717A),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAF8F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD6D1C7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD6D1C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPapaya, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Greek/EU Styled License Plate Widget with embossed metallic look
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFEAEAEA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF18181B), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 6,
              vertical: compact ? 2.5 : 4,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF003399),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: const Color(0xFFFFCC00),
                  size: compact ? 8 : 10,
                ),
                Text(
                  'GR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 7 : 8.5,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 11,
              vertical: compact ? 2 : 3,
            ),
            child: Text(
              plate.toUpperCase(),
              style: TextStyle(
                color: const Color(0xFF111113),
                fontSize: compact ? 12.5 : 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
