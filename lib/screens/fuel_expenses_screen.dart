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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.65);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        // 1. Clean 2-Metric Summary Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Μέση κατανάλωση',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        avgConsumption != null
                            ? '${avgConsumption.toStringAsFixed(1)} L/100'
                            : '0.0 L/100',
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Συνολικά έξοδα',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CarakiTheme.formatCurrency(grandTotal),
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
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
        _buildSimpleBreakdown(
          fuelCost: fuelCost,
          serviceCost: serviceCost,
          legalCost: legalCost,
          grandTotal: grandTotal,
        ),
        const SizedBox(height: 28),

        // 3. Clean Fuel History List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ανεφοδιασμοί',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            GestureDetector(
              onTap: () => CarakiModals.showAddFuelSheet(context, state, vehicle),
              child: Text(
                'Προσθήκη',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: secondaryText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...List.generate(fuelEntries.length, (index) {
          final entry = fuelEntries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              title: Text(
                '${entry.liters.toStringAsFixed(1)} Λίτρα${entry.stationName.isNotEmpty ? " • ${entry.stationName}" : ""}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                '${CarakiTheme.formatDate(entry.date)} • ${CarakiTheme.formatKm(entry.odometerKm)}',
                style: TextStyle(fontSize: 13, color: secondaryText),
              ),
              trailing: Text(
                CarakiTheme.formatCurrency(entry.totalCost),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: onSurface,
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
            const SizedBox(height: 14),
            _SimpleBarRow('Καύσιμα', fuelCost, fuelCost / safeTotal, CarakiTheme.primaryPapaya),
            const SizedBox(height: 14),
            _SimpleBarRow('ΚΤΕΟ & Ασφάλεια', legalCost, legalCost / safeTotal, CarakiTheme.statusAmber),
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
            Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            Text(
              CarakiTheme.formatCurrency(amount),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedLiquidBar(ratio: ratio.clamp(0.0, 1.0), color: color, height: 6),
      ],
    );
  }
}
