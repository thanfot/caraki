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
              const Icon(Icons.directions_car_filled_rounded, size: 72, color: CarakiTheme.primaryPapaya),
              const SizedBox(height: 16),
              const Text(
                'Το Γκαράζ είναι άδειο',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Πρόσθεσε το όχημά σου για να ξεκινήσεις.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => CarakiModals.showAddOrEditVehicleSheet(context, state),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Προσθήκη Οχήματος'),
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

    // Find only the urgent items to keep the dashboard ultra-clean
    final urgentParts = vehicle.partConfigs.values
        .where((cfg) => cfg.healthPercentage(estKm, now) <= 0.30)
        .toList()
      ..sort((a, b) => a.healthPercentage(estKm, now).compareTo(b.healthPercentage(estKm, now)));

    final urgentReminders = state.currentVehicleReminders
        .where((r) => r.daysRemaining(now) <= 35)
        .toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      child: ListView(
        key: ValueKey('dash_${vehicle.id}'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: [
          // 1. Minimal Vehicle Switcher (only if multiple vehicles exist, plus a subtle + button)
          StaggeredFadeSlide(
            index: 0,
            child: _buildMinimalGarageRow(context, vehicle),
          ),
          const SizedBox(height: 18),

          // 2. Clean Centerpiece Cockpit Card (Tachometer + Odometer)
          StaggeredFadeSlide(
            index: 1,
            child: _buildHeroCard(context, vehicle, estKm, healthScore),
          ),
          const SizedBox(height: 20),

          // 3. Two Simple Primary Action Pills
          StaggeredFadeSlide(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: BouncyTap(
                    onTap: () => CarakiModals.showAddServiceEventSheet(context, state, vehicle),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [CarakiTheme.primaryPapaya, Color(0xFFFF7A00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CarakiTheme.primaryPapaya.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_circle_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Νέο Service',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BouncyTap(
                    onTap: () => CarakiModals.showAddFuelSheet(context, state, vehicle),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_gas_station_rounded, color: CarakiTheme.statusAmber, size: 22),
                          SizedBox(width: 8),
                          Text(
                            '+ Καύσιμα',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 4. "Τι χρειάζεται προσοχή" (Max 3 clean items, or a calm "Όλα Τέλεια" card)
          StaggeredFadeSlide(
            index: 3,
            child: _buildNextUpSection(context, vehicle, urgentReminders, urgentParts, estKm, now),
          ),
          const SizedBox(height: 18),

          // 5. Minimal Quick Specs Strip (1 single clean card with 3 key specs)
          StaggeredFadeSlide(
            index: 4,
            child: _buildCompactSpecsStrip(context, vehicle),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalGarageRow(BuildContext context, Vehicle selected) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...state.vehicles.map((v) {
            final isSelected = v.id == selected.id;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: BouncyTap(
                onTap: () => state.selectVehicle(v.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CarakiTheme.primaryPapaya
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? CarakiTheme.primaryPapaya
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        v.type.icon,
                        size: 17,
                        color: isSelected ? Colors.white : CarakiTheme.primaryPapaya,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${v.make} ${v.model}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ],
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
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.add_rounded, size: 20, color: CarakiTheme.primaryPapaya),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Vehicle vehicle,
    int estKm,
    int healthScore,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF221F22), Color(0xFF141316)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreekLicensePlateBadge(plate: vehicle.licensePlate, compact: true),
                    const SizedBox(height: 14),
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} • ${vehicle.fuelType.label}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedTachometerGauge(
                scorePercent: healthScore,
                size: 110,
                onTap: () => onNavigateTab(1),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Clean Odometer Pill
          BouncyTap(
            onTap: () => CarakiModals.showOdometerUpdateDialog(context, state, vehicle),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: CarakiTheme.primaryPapaya, size: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ΧΙΛΙΟΜΕΤΡΑ ΚΟΝΤΕΡ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          AnimatedCounterText(
                            value: estKm,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: CarakiTheme.primaryPapaya.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Ενημέρωση',
                      style: TextStyle(
                        color: Color(0xFFFF8547),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextUpSection(
    BuildContext context,
    Vehicle vehicle,
    List<LegalReminder> urgentReminders,
    List<PartSpecConfig> urgentParts,
    int estKm,
    DateTime now,
  ) {
    final hasAlerts = urgentReminders.isNotEmpty || urgentParts.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Χρειάζονται Προσοχή',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () => onNavigateTab(1),
              child: const Text('Όλα τα μέρη →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (!hasAlerts)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CarakiTheme.statusGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: CarakiTheme.statusGreen, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Όλα σε άριστη κατάσταση!',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Δεν υπάρχει καμία επείγουσα εκκρεμότητα για το όχημά σου.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Show at most 2 urgent reminders and 2 urgent parts so screen stays super clean
          ...urgentReminders.take(2).map((rem) {
            final days = rem.daysRemaining(now);
            final color = CarakiTheme.daysRemainingColor(days);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BouncyTap(
                onTap: () => onNavigateTab(2),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(rem.type.icon, color: color, size: 22),
                    ),
                    title: Text(
                      rem.customTitle,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    subtitle: Text(
                      days >= 0 ? 'Λήγει σε $days ημέρες' : 'Έληξε πριν ${days.abs()} ημέρες',
                      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ),
                ),
              ),
            );
          }),
          ...urgentParts.take(2).map((cfg) {
            final ratio = cfg.healthPercentage(estKm, now);
            final color = CarakiTheme.healthColor(ratio);
            final remKm = cfg.remainingKm(estKm);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BouncyTap(
                onTap: () => CarakiModals.showAddServiceEventSheet(
                  context,
                  state,
                  vehicle,
                  preselectedParts: {cfg.partType},
                ),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cfg.partType.icon, color: color, size: 22),
                    ),
                    title: Text(
                      cfg.partType.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    subtitle: Text(
                      remKm > 0 ? 'Αλλαγή σε ~${CarakiTheme.formatKm(remKm)}' : 'Χρειάζεται άμεση αλλαγή',
                      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(ratio * 100).round()}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12.5),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildCompactSpecsStrip(BuildContext context, Vehicle vehicle) {
    return BouncyTap(
      onTap: () => CarakiModals.showAddOrEditVehicleSheet(context, state, existing: vehicle),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CompactSpecItem(
                icon: Icons.oil_barrel_rounded,
                label: 'Λάδια',
                value: vehicle.oilSpec.split(' ').take(2).join(' '),
              ),
              Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
              _CompactSpecItem(
                icon: Icons.tire_repair_rounded,
                label: 'Ελαστικά',
                value: vehicle.tireDimension.split(' ').take(2).join(' '),
              ),
              Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
              _CompactSpecItem(
                icon: Icons.air_rounded,
                label: 'Πίεση',
                value: vehicle.tirePressurePsi.split('/').first.trim(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompactSpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: CarakiTheme.primaryPapaya),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }
}
