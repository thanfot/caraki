import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/caraki_repository.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fuel_expenses_screen.dart';
import 'screens/garage_settings_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/service_book_screen.dart';
import 'theme/caraki_theme.dart';
import 'widgets/caraki_modals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('el_GR', null);
  final prefs = await SharedPreferences.getInstance();
  final repo = LocalCarakiRepository(prefs);
  final appState = CarakiState(repo);
  await appState.initialize();

  runApp(CarakiApp(state: appState));
}

class CarakiApp extends StatelessWidget {
  final CarakiState state;

  const CarakiApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Caraki — Ψηφιακό Βιβλίο Αυτοκινήτου',
          debugShowCheckedModeBanner: false,
          theme: CarakiTheme.lightTheme(),
          darkTheme: CarakiTheme.darkTheme(),
          themeMode: state.themeMode,
          locale: const Locale('el', 'GR'),
          supportedLocales: const [
            Locale('el', 'GR'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CarakiMainShell(state: state),
        );
      },
    );
  }
}

class CarakiMainShell extends StatefulWidget {
  final CarakiState state;

  const CarakiMainShell({super.key, required this.state});

  @override
  State<CarakiMainShell> createState() => _CarakiMainShellState();
}

class _CarakiMainShellState extends State<CarakiMainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.state.selectedVehicle;
    final now = DateTime.now();

    int alertCount = 0;
    if (vehicle != null) {
      final estKm = vehicle.estimatedOdometerKm(now);
      final urgentParts = vehicle.partConfigs.values
          .where((c) => c.healthPercentage(estKm, now) <= 0.30)
          .length;
      final urgentReminders = widget.state.currentVehicleReminders
          .where((r) => r.daysRemaining(now) <= 30)
          .length;
      alertCount = urgentParts + urgentReminders;
    }

    final titles = [
      'Caraki Cockpit',
      'Βιβλίο Service & Εξαρτήματα',
      'Υπενθυμίσεις & ΚΤΕΟ',
      'Καύσιμα & Έξοδα',
      'Γκαράζ & Ρυθμίσεις',
    ];

    final pages = <Widget>[
      DashboardScreen(
        key: const ValueKey('page_0'),
        state: widget.state,
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
      ServiceBookScreen(
        key: const ValueKey('page_1'),
        state: widget.state,
      ),
      RemindersScreen(
        key: const ValueKey('page_2'),
        state: widget.state,
      ),
      FuelExpensesScreen(
        key: const ValueKey('page_3'),
        state: widget.state,
      ),
      GarageSettingsScreen(
        key: const ValueKey('page_4'),
        state: widget.state,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [CarakiTheme.primaryPapaya, Color(0xFFFF8800)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CarakiTheme.primaryPapaya.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.sports_motorsports_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      titles[_currentIndex],
                      key: ValueKey('title_$_currentIndex'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17.5),
                    ),
                  ),
                  if (vehicle != null)
                    Text(
                      '${vehicle.fullName} • ${vehicle.licensePlate}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (vehicle != null)
            IconButton(
              tooltip: 'Γρήγορη ενημέρωση χιλιομέτρων κοντέρ',
              onPressed: () => CarakiModals.showOdometerUpdateDialog(
                context,
                widget.state,
                vehicle,
              ),
              icon: const Icon(Icons.speed_rounded, color: CarakiTheme.primaryPapaya),
            ),
          IconButton(
            tooltip: 'Εναλλαγή Σκούρου / Φωτεινού Θέματος',
            onPressed: () {
              final next = widget.state.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              widget.state.setThemeMode(next);
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Icon(
                widget.state.themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey(widget.state.themeMode),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 340),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.03, 0.02),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: pages[_currentIndex],
      ),
      floatingActionButton: vehicle == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (_currentIndex == 2) {
                  CarakiModals.showReminderSheet(context, widget.state, vehicle);
                } else if (_currentIndex == 3) {
                  CarakiModals.showAddFuelSheet(context, widget.state, vehicle);
                } else if (_currentIndex == 4) {
                  CarakiModals.showAddOrEditVehicleSheet(context, widget.state);
                } else {
                  CarakiModals.showAddServiceEventSheet(context, widget.state, vehicle);
                }
              },
              icon: Icon(
                _currentIndex == 2
                    ? Icons.add_alert_rounded
                    : _currentIndex == 3
                        ? Icons.local_gas_station_rounded
                        : _currentIndex == 4
                            ? Icons.directions_car_rounded
                            : Icons.build_circle_rounded,
              ),
              label: Text(
                _currentIndex == 2
                    ? '+ Υπενθύμιση'
                    : _currentIndex == 3
                        ? '+ Καύσιμα'
                        : _currentIndex == 4
                            ? '+ Όχημα'
                            : '+ Νέο Service',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed_rounded),
            label: 'Καντράν',
          ),
          const NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman_rounded),
            label: 'Service',
          ),
          NavigationDestination(
            icon: Badge(
              backgroundColor: CarakiTheme.statusRed,
              isLabelVisible: alertCount > 0,
              label: Text('$alertCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              backgroundColor: CarakiTheme.statusRed,
              isLabelVisible: alertCount > 0,
              label: Text('$alertCount'),
              child: const Icon(Icons.notifications_active_rounded),
            ),
            label: 'ΚΤΕΟ & Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station_rounded),
            label: 'Καύσιμα',
          ),
          const NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage_rounded),
            label: 'Γκαράζ',
          ),
        ],
      ),
    );
  }
}
