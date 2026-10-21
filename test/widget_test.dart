import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:caraki/data/caraki_repository.dart';
import 'package:caraki/main.dart';
import 'package:caraki/models/caraki_models.dart';

void main() {
  testWidgets('Caraki initializes with demo vehicles and renders Cockpit & tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('el_GR', null);

    final prefs = await SharedPreferences.getInstance();
    final repo = LocalCarakiRepository(prefs);
    final state = CarakiState(repo);
    await state.initialize();

    expect(state.vehicles.length, 2);
    expect(state.selectedVehicle?.make, 'Toyota');

    await tester.pumpWidget(CarakiApp(state: state));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Caraki Cockpit'), findsOneWidget);
    expect(find.textContaining('Toyota Yaris'), findsWidgets);

    // Verify Unified Service Event resets serviced part health to 100%
    final yaris = state.selectedVehicle!;
    final newKm = yaris.estimatedOdometerKm(DateTime.now()) + 100;
    await state.addServiceEvent(
      ServiceEvent(
        id: 'test-srv',
        vehicleId: yaris.id,
        date: DateTime.now(),
        odometerKm: newKm,
        title: 'Αλλαγή Υγρών Φρένων',
        servicedParts: [PartType.brakeFluid],
        totalCost: 45.0,
      ),
    );

    final updatedFluid = state.selectedVehicle!.partConfigs[PartType.brakeFluid]!;
    expect(updatedFluid.lastServiceKm, newKm);
    expect(updatedFluid.healthPercentage(newKm, DateTime.now()), 1.0);
  });
}
