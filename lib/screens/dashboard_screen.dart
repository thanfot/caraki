import 'package:flutter/material.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import '../widgets/caraki_animated_widgets.dart';
import '../widgets/caraki_modals.dart';

class DashboardScreen extends StatelessWidget {
  final CarakiState state;
  final ValueChanged<int> onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_filled_rounded, size: 64, color: CarakiTheme.primaryPapaya),
              const SizedBox(height: 16),
              const Text(
                'Το Γκαράζ είναι άδειο',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Πρόσθεσε το όχημά σου για να ξεκινήσεις.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => CarakiModals.showAddOrEditVehicleSheet(context, state),
                child: const Text('Προσθήκη Οχήματος'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => state.resetDemoData(),
                child: const Text('Φόρτωση Demo Οχήματος'),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final estKm = vehicle.estimatedOdometerKm(now);
    final healthScore = vehicle.overallHealthScore(now);

    final urgentParts = vehicle.partConfigs.values
        .where((cfg) => cfg.healthPercentage(estKm, now) <= 0.30)
        .toList()
      ..sort((a, b) => a.healthPercentage(estKm, now).compareTo(b.healthPercentage(estKm, now)));

    final urgentReminders = state.currentVehicleReminders
        .where((r) => r.daysRemaining(now) <= 35)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        // 1. Clean Vehicle Switcher
        _buildGarageSelector(context, vehicle),
        const SizedBox(height: 20),

        // 2. Clean Vehicle Card (Headline FIRST, no badge above headline, no colored borders)
        _buildVehicleMainCard(context, vehicle, estKm, healthScore),
        const SizedBox(height: 14),

        // 3. Two Solid Action Buttons
        Row(
          children: [
            Expanded(
              child: BouncyTap(
                onTap: () => CarakiModals.showAddServiceEventSheet(context, state, vehicle),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: CarakiTheme.primaryPapaya,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Καταχώρηση Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BouncyTap(
                onTap: () => CarakiModals.showAddFuelSheet(context, state, vehicle),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Καταγραφή Καυσίμων',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // 4. Priority Items (Clean grouped list)
        _buildPrioritySection(context, vehicle, urgentReminders, urgentParts, estKm, now),
        const SizedBox(height: 28),

        // 5. Clean Vertical Key-Value Specs Card (No 3-icon-boxes-in-a-row)
        _buildCleanSpecsCard(context, vehicle),
      ],
    );
  }

  Widget _buildGarageSelector(BuildContext context, Vehicle selected) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...state.vehicles.map((v) {
            final isSelected = v.id == selected.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BouncyTap(
                onTap: () => state.selectVehicle(v.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? onSurface
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Center(
                    child: Text(
                      '${v.make} ${v.model}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected
                            ? Theme.of(context).scaffoldBackgroundColor
                            : onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          BouncyTap(
            onTap: () => CarakiModals.showAddOrEditVehicleSheet(context, state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(Icons.add_rounded, size: 18, color: onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleMainCard(
    BuildContext context,
    Vehicle vehicle,
    int estKm,
    int healthScore,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.65);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline FIRST (no badge above headline!)
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.year} • ${vehicle.fuelType.label} • ${vehicle.horsepower} HP',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GreekLicensePlateBadge(plate: vehicle.licensePlate, compact: true),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedTachometerGauge(
                  scorePercent: healthScore,
                  size: 98,
                  onTap: () => onNavigateTab(1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BouncyTap(
              onTap: () => CarakiModals.showOdometerUpdateDialog(context, state, vehicle),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Χιλιόμετρα κοντέρ',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedCounterText(
                          value: estKm,
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Ενημέρωση',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySection(
    BuildContext context,
    Vehicle vehicle,
    List<LegalReminder> urgentReminders,
    List<PartSpecConfig> urgentParts,
    int estKm,
    DateTime now,
  ) {
    final hasAlerts = urgentReminders.isNotEmpty || urgentParts.isNotEmpty;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Επόμενες Εργασίες',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            GestureDetector(
              onTap: () => onNavigateTab(1),
              child: Text(
                'Προβολή όλων',
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
        if (!hasAlerts)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: CarakiTheme.statusGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Δεν υπάρχει καμία εκκρεμότητα συντήρησης.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                ...urgentReminders.take(2).map((rem) {
                  final days = rem.daysRemaining(now);
                  final color = CarakiTheme.daysRemainingColor(days);
                  return ListTile(
                    onTap: () => onNavigateTab(2),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    title: Text(
                      rem.customTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    subtitle: Text(
                      days >= 0 ? 'Λήγει σε $days ημέρες' : 'Έληξε πριν ${days.abs()} ημέρες',
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
                  );
                }),
                ...urgentParts.take(2).map((cfg) {
                  final ratio = cfg.healthPercentage(estKm, now);
                  final color = CarakiTheme.healthColor(ratio);
                  final remKm = cfg.remainingKm(estKm);
                  return ListTile(
                    onTap: () => CarakiModals.showAddServiceEventSheet(
                      context,
                      state,
                      vehicle,
                      preselectedParts: {cfg.partType},
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    title: Text(
                      cfg.partType.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    subtitle: Text(
                      remKm > 0 ? 'Αλλαγή σε ${CarakiTheme.formatKm(remKm)}' : 'Απαιτείται αλλαγή',
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    trailing: Text(
                      '${(ratio * 100).round()}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCleanSpecsCard(BuildContext context, Vehicle vehicle) {
    final secondaryText = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Τεχνικά Στοιχεία',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            GestureDetector(
              onTap: () => CarakiModals.showAddOrEditVehicleSheet(context, state, existing: vehicle),
              child: Text(
                'Επεξεργασία',
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
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              children: [
                _SpecLineRow(label: 'Λάδια κινητήρα', value: vehicle.oilSpec),
                const Divider(height: 22, thickness: 0.5),
                _SpecLineRow(label: 'Διάσταση ελαστικών', value: vehicle.tireDimension),
                const Divider(height: 22, thickness: 0.5),
                _SpecLineRow(label: 'Πίεση ελαστικών', value: vehicle.tirePressurePsi),
                if (vehicle.vin.isNotEmpty) ...[
                  const Divider(height: 22, thickness: 0.5),
                  _SpecLineRow(label: 'Αριθμός πλαισίου (VIN)', value: vehicle.vin),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecLineRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecLineRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5,
              color: onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
