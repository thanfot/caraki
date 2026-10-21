import 'package:flutter/material.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import '../widgets/caraki_animated_widgets.dart';
import '../widgets/caraki_modals.dart';

class RemindersScreen extends StatelessWidget {
  final CarakiState state;

  const RemindersScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      return const Center(child: Text('Επίλεξε ένα όχημα πρώτα.'));
    }

    final now = DateTime.now();
    final reminders = state.currentVehicleReminders;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ΚΤΕΟ, Ασφάλεια & Τέλη',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: () => CarakiModals.showReminderSheet(context, state, vehicle),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Προσθήκη'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (reminders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'Δεν υπάρχουν καταχωρημένες υπενθυμίσεις.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...reminders.asMap().entries.map(
                (entry) => StaggeredFadeSlide(
                  index: entry.key,
                  child: _buildReminderCard(context, vehicle, entry.value, now),
                ),
              ),
      ],
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Vehicle vehicle,
    LegalReminder rem,
    DateTime now,
  ) {
    final days = rem.daysRemaining(now);
    final color = CarakiTheme.daysRemainingColor(days);

    String statusText;
    if (days < 0) {
      statusText = 'Έληξε πριν ${days.abs()} ημ.';
    } else if (days == 0) {
      statusText = 'Λήγει Σήμερα!';
    } else {
      statusText = 'Σε $days ημέρες';
    }

    int defaultRenewMonths = 12;
    if (rem.type == LegalObligationType.kteo) defaultRenewMonths = 24;
    if (rem.type == LegalObligationType.insurance) defaultRenewMonths = 6;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BouncyTap(
        onTap: () => CarakiModals.showReminderSheet(context, state, vehicle, existing: rem),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                PulsingUrgentBadge(
                  glowColor: color,
                  active: days <= 15,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(rem.type.icon, color: color, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rem.customTitle,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Λήξη: ${CarakiTheme.formatDate(rem.dueDate)}${rem.cost > 0 ? " • ${CarakiTheme.formatCurrency(rem.cost)}" : ""}',
                        style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        await state.renewReminder(rem, addMonths: defaultRenewMonths);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ανανεώθηκε (+$defaultRenewMonths μήνες)!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Ανανέωση ↻',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CarakiTheme.primaryPapaya,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
