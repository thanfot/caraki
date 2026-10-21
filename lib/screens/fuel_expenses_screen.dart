import 'package:flutter/material.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import '../widgets/caraki_animated_widgets.dart';
import '../widgets/caraki_modals.dart';

class FuelExpensesScreen extends StatelessWidget {
  final CarakiState state;

  const FuelExpensesScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      return const Center(child: Text('Επίλεξε ένα όχημα πρώτα.'));
    }

    final fuelEntries = state.currentVehicleFuelEntries;
    final avgConsumption = state.averageConsumptionLPer100Km;
    final fuelCost = state.totalFuelCostForSelected;
    final serviceCost = state.totalServiceCostForSelected;
    final legalCost = state.totalLegalCostForSelected;
    final grandTotal = fuelCost + serviceCost + legalCost;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        // 1. Clean 2-Metric Hero Card
        StaggeredFadeSlide(
          index: 0,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF231F20), Color(0xFF141316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ΜΕΣΗ ΚΑΤΑΝΑΛΩΣΗ',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        avgConsumption != null
                            ? '${avgConsumption.toStringAsFixed(1)} L/100'
                            : '— L/100',
                        style: const TextStyle(
                          color: CarakiTheme.primaryPapaya,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white12),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ΣΥΝΟΛΙΚΑ ΕΞΟΔΑ',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CarakiTheme.formatCurrency(grandTotal),
                        style: const TextStyle(
                          color: CarakiTheme.statusGreen,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Simple Expense Distribution Card
        StaggeredFadeSlide(
          index: 1,
          child: _buildSimpleBreakdown(
            fuelCost: fuelCost,
            serviceCost: serviceCost,
            legalCost: legalCost,
            grandTotal: grandTotal,
          ),
        ),
        const SizedBox(height: 22),

        // 3. Clean Fuel History List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ανεφοδιασμοί',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: () => CarakiModals.showAddFuelSheet(context, state, vehicle),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Προσθήκη'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...List.generate(fuelEntries.length, (index) {
          final entry = fuelEntries[index];
          return StaggeredFadeSlide(
            index: index + 2,
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CarakiTheme.primaryPapaya.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_gas_station_rounded, color: CarakiTheme.primaryPapaya, size: 20),
                ),
                title: Text(
                  '${entry.liters.toStringAsFixed(1)} Λίτρα${entry.stationName.isNotEmpty ? " • ${entry.stationName}" : ""}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                subtitle: Text(
                  '${CarakiTheme.formatDate(entry.date)} • ${CarakiTheme.formatKm(entry.odometerKm)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Text(
                  CarakiTheme.formatCurrency(entry.totalCost),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: CarakiTheme.primaryPapaya,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSimpleBreakdown({
    required double fuelCost,
    required double serviceCost,
    required double legalCost,
    required double grandTotal,
  }) {
    final safeTotal = grandTotal > 0 ? grandTotal : 1.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _SimpleBarRow('Service', serviceCost, serviceCost / safeTotal, CarakiTheme.statusGreen),
            const SizedBox(height: 12),
            _SimpleBarRow('Καύσιμα', fuelCost, fuelCost / safeTotal, CarakiTheme.primaryPapaya),
            const SizedBox(height: 12),
            _SimpleBarRow('ΚΤΕΟ & Ασφάλεια', legalCost, legalCost / safeTotal, CarakiTheme.racingCrimson),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarRow extends StatelessWidget {
  final String label;
  final double amount;
  final double ratio;
  final Color color;

  const _SimpleBarRow(this.label, this.amount, this.ratio, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(
              CarakiTheme.formatCurrency(amount),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedLiquidBar(ratio: ratio.clamp(0.0, 1.0), color: color, height: 6),
      ],
    );
  }
}
