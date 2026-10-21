import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import 'caraki_animated_widgets.dart';

class CarakiModals {
  static Widget _buildSheetHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSave,
    String saveLabel = 'Αποθήκευση',
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 4.5,
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Ακύρωση',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: onSave,
                child: Text(
                  saveLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: CarakiTheme.primaryPapaya,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 1. Clean Odometer Update Sheet
  static Future<void> showOdometerUpdateDialog(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle,
  ) async {
    final now = DateTime.now();
    final estimated = vehicle.estimatedOdometerKm(now);
    final odoCtrl = TextEditingController(text: estimated.toString());
    final avgCtrl = TextEditingController(text: vehicle.averageMonthlyKm.toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Future<void> save() async {
          final newKm = int.tryParse(odoCtrl.text.trim()) ?? vehicle.currentOdometerKm;
          final newAvg = int.tryParse(avgCtrl.text.trim()) ?? vehicle.averageMonthlyKm;
          await state.updateOdometer(
            vehicle.id,
            newKm,
            newMonthlyAvgKm: newAvg.clamp(50, 20000),
          );
          if (ctx.mounted) Navigator.of(ctx).pop();
        }

        final secondary = Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6);

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHeader(ctx, title: 'Χιλιόμετρα Κοντέρ', onSave: save),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Τρέχουσα ένδειξη (χλμ)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: secondary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: odoCtrl,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                              decoration: const InputDecoration(
                                suffixText: 'χλμ',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Μέσος όρος ανά μήνα (για αυτόματη εκτίμηση)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: secondary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: avgCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                suffixText: 'χλμ / μήνα',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: save,
                        child: const Text(
                          'Ενημέρωση Κοντέρ',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 2. Redesigned Clean Service Event Page with Quick Presets & Interactive Pill Chips
  static Future<void> showAddServiceEventSheet(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle, {
    Set<PartType>? preselectedParts,
  }) async {
    final now = DateTime.now();
    DateTime selectedDate = now;
    final selectedParts = <PartType>{...(preselectedParts ?? {PartType.engineOil})};
    bool showExtraDetails = false;

    final titleCtrl = TextEditingController(
      text: preselectedParts != null && preselectedParts.length == 1
          ? preselectedParts.first.title
          : 'Τακτικό Service',
    );
    final odoCtrl = TextEditingController(
      text: vehicle.estimatedOdometerKm(now).toString(),
    );
    final costCtrl = TextEditingController(text: '');
    final workshopCtrl = TextEditingController(text: '');
    final notesCtrl = TextEditingController(text: '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final onSurface = Theme.of(ctx).colorScheme.onSurface;
            final secondary = onSurface.withValues(alpha: 0.6);

            Future<void> save() async {
              if (selectedParts.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Επίλεξε τουλάχιστον 1 εργασία.')),
                );
                return;
              }
              final odo = int.tryParse(odoCtrl.text.trim()) ?? vehicle.currentOdometerKm;
              final cost = double.tryParse(costCtrl.text.replaceAll(',', '.').trim()) ?? 0.0;
              final event = ServiceEvent(
                id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
                vehicleId: vehicle.id,
                date: selectedDate,
                odometerKm: odo,
                title: titleCtrl.text.trim().isEmpty
                    ? 'Service (${selectedParts.length} εργασίες)'
                    : titleCtrl.text.trim(),
                servicedParts: selectedParts.toList(),
                totalCost: cost,
                workshopName: workshopCtrl.text.trim(),
                notes: notesCtrl.text.trim(),
              );
              await state.addServiceEvent(event);
              if (ctx.mounted) Navigator.of(ctx).pop();
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.88,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    _buildSheetHeader(ctx, title: 'Νέο Service', onSave: save),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          MediaQuery.of(ctx).viewInsets.bottom + 32,
                        ),
                        children: [
                          // Section 1: Core Fields in a single clean iOS card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: titleCtrl,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                    decoration: const InputDecoration(
                                      labelText: 'Τίτλος εργασίας',
                                      hintText: 'π.χ. Λάδια & Φίλτρα',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: odoCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                          decoration: const InputDecoration(
                                            labelText: 'Χιλιόμετρα',
                                            suffixText: 'χλμ',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: costCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                          decoration: const InputDecoration(
                                            labelText: 'Κόστος',
                                            hintText: '0',
                                            suffixText: '€',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: ctx,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now().add(const Duration(days: 1)),
                                      );
                                      if (picked != null) {
                                        setModalState(() => selectedDate = picked);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Ημερομηνία',
                                            style: TextStyle(color: secondary, fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            CarakiTheme.formatDate(selectedDate),
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Section 2: Quick Presets + Clean Selectable Part Pills
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Τι αλλάχτηκε;',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${selectedParts.length} επιλεγμένα',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Quick Presets Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _PresetPill(
                                  label: 'Μικρό Service (Λάδια/Φίλτρα)',
                                  onTap: () {
                                    setModalState(() {
                                      selectedParts
                                        ..clear()
                                        ..addAll([
                                          PartType.engineOil,
                                          PartType.airCabinFilter,
                                        ]);
                                      titleCtrl.text = 'Μικρό Service (Λάδια & Φίλτρα)';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _PresetPill(
                                  label: 'Μεγάλο Service',
                                  onTap: () {
                                    setModalState(() {
                                      selectedParts
                                        ..clear()
                                        ..addAll([
                                          PartType.engineOil,
                                          PartType.airCabinFilter,
                                          PartType.sparkPlugs,
                                          PartType.brakeFluid,
                                        ]);
                                      titleCtrl.text = 'Μεγάλο Service';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _PresetPill(
                                  label: 'Ελαστικά',
                                  onTap: () {
                                    setModalState(() {
                                      selectedParts
                                        ..clear()
                                        ..addAll([
                                          PartType.tiresChange,
                                          PartType.tiresRotation,
                                        ]);
                                      titleCtrl.text = 'Αλλαγή Ελαστικών';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Clean 2-column grid of compact part tiles (no bulky subtitles or checkboxes)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: PartType.values.map((pt) {
                                  final isSelected = selectedParts.contains(pt);
                                  return BouncyTap(
                                    onTap: () {
                                      setModalState(() {
                                        if (isSelected) {
                                          selectedParts.remove(pt);
                                        } else {
                                          selectedParts.add(pt);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? CarakiTheme.primaryPapaya
                                            : Theme.of(ctx).colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSelected ? Icons.check_rounded : pt.icon,
                                            size: 16,
                                            color: isSelected ? Colors.white : secondary,
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            pt.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected ? Colors.white : onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Section 3: Collapsible Optional Workshop & Notes
                          if (!showExtraDetails)
                            Center(
                              child: TextButton.icon(
                                onPressed: () => setModalState(() => showExtraDetails = true),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Προσθήκη συνεργείου ή σημείωσης (προαιρετικό)'),
                              ),
                            )
                          else
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: workshopCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Συνεργείο',
                                        hintText: 'π.χ. AutoService Παπαδόπουλος',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: notesCtrl,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        labelText: 'Σημειώσεις',
                                        hintText: 'Μάρκα ανταλλακτικών, παρατηρήσεις...',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: save,
                              child: const Text(
                                'Αποθήκευση Service',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// 3. Clean Component Details & Interval Sheet
  static Future<void> showEditPartConfigSheet(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle,
    PartSpecConfig config,
  ) async {
    final kmIntervalCtrl = TextEditingController(text: config.intervalKm.toString());
    final monthsIntervalCtrl = TextEditingController(text: config.intervalMonths.toString());
    final lastKmCtrl = TextEditingController(text: config.lastServiceKm.toString());
    final notesCtrl = TextEditingController(text: config.notes);
    DateTime lastDate = config.lastServiceDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> save() async {
              final updated = config.copyWith(
                intervalKm: int.tryParse(kmIntervalCtrl.text.trim()) ?? config.intervalKm,
                intervalMonths: int.tryParse(monthsIntervalCtrl.text.trim()) ?? config.intervalMonths,
                lastServiceKm: int.tryParse(lastKmCtrl.text.trim()) ?? config.lastServiceKm,
                lastServiceDate: lastDate,
                notes: notesCtrl.text.trim(),
              );
              await state.updatePartConfig(vehicle.id, updated);
              if (ctx.mounted) Navigator.of(ctx).pop();
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetHeader(ctx, title: config.partType.title, onSave: save),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Τελευταία Αλλαγή',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: lastKmCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            labelText: 'Χιλιόμετρα',
                                            suffixText: 'χλμ',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(14),
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: ctx,
                                              initialDate: lastDate,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            );
                                            if (picked != null) {
                                              setModalState(() => lastDate = picked);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Ημερομηνία',
                                            ),
                                            child: Text(
                                              CarakiTheme.formatDate(lastDate),
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Διάστημα Επόμενης Αλλαγής',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: kmIntervalCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            labelText: 'Κάθε (Χλμ)',
                                            suffixText: 'χλμ',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: monthsIntervalCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            labelText: 'Κάθε (Μήνες)',
                                            suffixText: 'μήνες',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: notesCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Σημείωση (π.χ. τύπος ανταλλακτικού)',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    showAddServiceEventSheet(
                                      context,
                                      state,
                                      vehicle,
                                      preselectedParts: {config.partType},
                                    );
                                  },
                                  child: const Text(
                                    'Έγινε Αλλαγή Τώρα',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: save,
                                  child: const Text(
                                    'Αποθήκευση',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 4. Clean Legal Reminder Sheet (KTEO, Insurance, KEK, Road Tax)
  static Future<void> showReminderSheet(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle, {
    LegalReminder? existing,
  }) async {
    LegalObligationType selectedType = existing?.type ?? LegalObligationType.kteo;
    DateTime dueDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 365));
    final titleCtrl = TextEditingController(
      text: existing?.customTitle ?? selectedType.title,
    );
    final costCtrl = TextEditingController(
      text: existing != null && existing.cost > 0 ? existing.cost.toStringAsFixed(0) : '',
    );
    final providerCtrl = TextEditingController(text: existing?.providerOrCenter ?? '');
    final phoneCtrl = TextEditingController(text: existing?.emergencyPhone ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> save() async {
              final cost = double.tryParse(costCtrl.text.replaceAll(',', '.').trim()) ?? 0.0;
              final reminder = LegalReminder(
                id: existing?.id ?? 'rem-${DateTime.now().millisecondsSinceEpoch}',
                vehicleId: vehicle.id,
                type: selectedType,
                customTitle: titleCtrl.text.trim().isEmpty
                    ? selectedType.title
                    : titleCtrl.text.trim(),
                issueDate: existing?.issueDate ?? DateTime.now(),
                dueDate: dueDate,
                cost: cost,
                providerOrCenter: providerCtrl.text.trim(),
                emergencyPhone: phoneCtrl.text.trim(),
              );
              await state.addOrUpdateReminder(reminder);
              if (ctx.mounted) Navigator.of(ctx).pop();
            }

            final onSurface = Theme.of(ctx).colorScheme.onSurface;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetHeader(
                      ctx,
                      title: existing == null ? 'Νέα Υπενθύμιση' : 'Επεξεργασία',
                      onSave: save,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clean Category Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: LegalObligationType.values.map((t) {
                                final isSelected = t == selectedType;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: BouncyTap(
                                    onTap: () {
                                      setModalState(() {
                                        selectedType = t;
                                        if (existing == null) titleCtrl.text = t.title;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? CarakiTheme.primaryPapaya
                                            : Theme.of(ctx).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        t.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: titleCtrl,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                    decoration: const InputDecoration(
                                      labelText: 'Τίτλος',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(14),
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: ctx,
                                              initialDate: dueDate,
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2035),
                                            );
                                            if (picked != null) {
                                              setModalState(() => dueDate = picked);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Ημερομηνία Λήξης',
                                            ),
                                            child: Text(
                                              CarakiTheme.formatDate(dueDate),
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: costCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                          decoration: const InputDecoration(
                                            labelText: 'Κόστος',
                                            hintText: '0',
                                            suffixText: '€',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: providerCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Εταιρεία / Κέντρο (προαιρετικό)',
                                      hintText: 'π.χ. Autovision, Anytime',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Τηλέφωνο Οδικής / Ραντεβού (προαιρετικό)',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: save,
                              child: const Text(
                                'Αποθήκευση Υπενθύμισης',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 5. Clean Fuel Fill-up Sheet
  static Future<void> showAddFuelSheet(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle,
  ) async {
    final now = DateTime.now();
    DateTime selectedDate = now;

    final odoCtrl = TextEditingController(
      text: (vehicle.estimatedOdometerKm(now) + 120).toString(),
    );
    final litersCtrl = TextEditingController(text: '');
    final totalCostCtrl = TextEditingController(text: '');
    final stationCtrl = TextEditingController(text: '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> save() async {
              final odo = int.tryParse(odoCtrl.text.trim()) ?? vehicle.currentOdometerKm;
              final total = double.tryParse(totalCostCtrl.text.replaceAll(',', '.').trim()) ?? 0.0;
              final liters = double.tryParse(litersCtrl.text.replaceAll(',', '.').trim()) ??
                  (total > 0 ? total / 1.85 : 0.0);
              final pricePerLiter = liters > 0 ? total / liters : 1.85;

              final entry = FuelEntry(
                id: 'fuel-${DateTime.now().millisecondsSinceEpoch}',
                vehicleId: vehicle.id,
                date: selectedDate,
                odometerKm: odo,
                liters: liters,
                pricePerLiter: pricePerLiter,
                totalCost: total,
                isFullTank: true,
                stationName: stationCtrl.text.trim(),
              );
              await state.addFuelEntry(entry);
              if (ctx.mounted) Navigator.of(ctx).pop();
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetHeader(ctx, title: 'Καταγραφή Καυσίμων', onSave: save),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: totalCostCtrl,
                                          autofocus: true,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                          decoration: const InputDecoration(
                                            labelText: 'Ποσό (€)',
                                            hintText: '50',
                                            suffixText: '€',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: litersCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                          decoration: const InputDecoration(
                                            labelText: 'Λίτρα',
                                            hintText: '28.5',
                                            suffixText: 'L',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: odoCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            labelText: 'Χιλιόμετρα κοντέρ',
                                            suffixText: 'χλμ',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: stationCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Πρατήριο (προαιρ.)',
                                            hintText: 'π.χ. Shell',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: save,
                              child: const Text(
                                'Αποθήκευση Ανεφοδιασμού',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 6. Clean Add / Edit Vehicle Sheet
  static Future<void> showAddOrEditVehicleSheet(
    BuildContext context,
    CarakiState state, {
    Vehicle? existing,
  }) async {
    VehicleType selectedType = existing?.type ?? VehicleType.car;
    FuelType selectedFuel = existing?.fuelType ?? FuelType.petrol;

    final makeCtrl = TextEditingController(text: existing?.make ?? '');
    final modelCtrl = TextEditingController(text: existing?.model ?? '');
    final yearCtrl = TextEditingController(text: (existing?.year ?? 2022).toString());
    final plateCtrl = TextEditingController(text: existing?.licensePlate ?? '');
    final odoCtrl = TextEditingController(text: (existing?.currentOdometerKm ?? 45000).toString());
    final hpCtrl = TextEditingController(text: (existing?.horsepower ?? 110).toString());

    final oilSpecCtrl = TextEditingController(text: existing?.oilSpec ?? '5W-30');
    final tireDimCtrl = TextEditingController(text: existing?.tireDimension ?? '205/55 R16');
    final tirePsiCtrl = TextEditingController(text: existing?.tirePressurePsi ?? '33 PSI');
    final vinCtrl = TextEditingController(text: existing?.vin ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> save() async {
              final make = makeCtrl.text.trim().isEmpty ? 'Όχημα' : makeCtrl.text.trim();
              final model = modelCtrl.text.trim().isEmpty ? 'Μοντέλο' : modelCtrl.text.trim();
              final odo = int.tryParse(odoCtrl.text.trim()) ?? 0;
              final now = DateTime.now();

              final partConfigs = existing?.partConfigs ??
                  {
                    for (final pt in PartType.values)
                      pt: PartSpecConfig(
                        partType: pt,
                        intervalKm: pt.defaultIntervalKm,
                        intervalMonths: pt.defaultIntervalMonths,
                        lastServiceKm: odo,
                        lastServiceDate: now,
                      ),
                  };

              final vehicle = Vehicle(
                id: existing?.id ?? 'veh-${DateTime.now().millisecondsSinceEpoch}',
                type: selectedType,
                make: make,
                model: model,
                year: int.tryParse(yearCtrl.text.trim()) ?? 2022,
                licensePlate: plateCtrl.text.trim().isEmpty ? 'ΑΒΓ-1234' : plateCtrl.text.trim(),
                vin: vinCtrl.text.trim(),
                horsepower: int.tryParse(hpCtrl.text.trim()) ?? 100,
                fuelType: selectedFuel,
                currentOdometerKm: odo,
                lastOdometerUpdate: existing?.lastOdometerUpdate ?? now,
                oilSpec: oilSpecCtrl.text.trim(),
                tireDimension: tireDimCtrl.text.trim(),
                tirePressurePsi: tirePsiCtrl.text.trim(),
                partConfigs: partConfigs,
                isDemo: false,
              );

              await state.addOrUpdateVehicle(vehicle);
              if (ctx.mounted) Navigator.of(ctx).pop();
            }

            final onSurface = Theme.of(ctx).colorScheme.onSurface;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.88,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    _buildSheetHeader(
                      ctx,
                      title: existing == null ? 'Νέο Όχημα' : 'Επεξεργασία Οχήματος',
                      onSave: save,
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          MediaQuery.of(ctx).viewInsets.bottom + 32,
                        ),
                        children: [
                          // Vehicle Type Selector Pills
                          Row(
                            children: VehicleType.values.map((vt) {
                              final isSelected = vt == selectedType;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: BouncyTap(
                                    onTap: () => setModalState(() => selectedType = vt),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? CarakiTheme.primaryPapaya
                                            : Theme.of(ctx).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            vt.icon,
                                            size: 20,
                                            color: isSelected ? Colors.white : onSurface,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            vt.label.split(' ').first,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected ? Colors.white : onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Βασικά Στοιχεία',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: makeCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Μάρκα',
                                            hintText: 'π.χ. Toyota',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: modelCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Μοντέλο',
                                            hintText: 'π.χ. Yaris',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: plateCtrl,
                                          textCapitalization: TextCapitalization.characters,
                                          decoration: const InputDecoration(
                                            labelText: 'Πινακίδα',
                                            hintText: 'ΙΖΜ-8492',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: yearCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            labelText: 'Έτος',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: odoCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            labelText: 'Χιλιόμετρα',
                                            suffixText: 'χλμ',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: hpCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Ίπποι (HP)',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<FuelType>(
                                    initialValue: selectedFuel,
                                    decoration: const InputDecoration(labelText: 'Καύσιμο'),
                                    items: FuelType.values
                                        .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => selectedFuel = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          const Text(
                            'Τεχνικές Προδιαγραφές (Προαιρετικό)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: oilSpecCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Τύπος Λαδιών (π.χ. 5W-30)',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: tireDimCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Ελαστικά',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: tirePsiCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Πίεση (PSI)',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: vinCtrl,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: const InputDecoration(
                                      labelText: 'Αριθμός Πλαισίου (VIN)',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: save,
                              child: Text(
                                existing == null ? 'Προσθήκη Οχήματος' : 'Αποθήκευση Αλλαγών',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PresetPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetPill({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
