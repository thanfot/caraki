import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';

class CarakiModals {
  /// 1. Quick Odometer Update & Monthly Check-up Dialog
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CarakiTheme.primaryElectricBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.speed_rounded, color: CarakiTheme.primaryElectricBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ενημέρωση Χιλιομέτρων Κοντέρ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${vehicle.fullName} • ${vehicle.licensePlate}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CarakiTheme.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CarakiTheme.accentCyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: CarakiTheme.accentCyan, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Τελευταία καταγραφή: ${CarakiTheme.formatKm(vehicle.currentOdometerKm)} (${CarakiTheme.formatDate(vehicle.lastOdometerUpdate)}).\nΈξυπνη εκτίμηση σήμερα: ~${CarakiTheme.formatKm(estimated)}',
                        style: const TextStyle(fontSize: 12.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: odoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Σημερινά Χιλιόμετρα Κοντέρ (χλμ)',
                  prefixIcon: Icon(Icons.add_road_rounded),
                  suffixText: 'χλμ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avgCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Μέσος όρος χιλιομέτρων ανά μήνα (για εκτίμηση)',
                  prefixIcon: Icon(Icons.trending_up_rounded),
                  suffixText: 'χλμ / μήνα',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () async {
                    final newKm = int.tryParse(odoCtrl.text.trim()) ?? vehicle.currentOdometerKm;
                    final newAvg = int.tryParse(avgCtrl.text.trim()) ?? vehicle.averageMonthlyKm;
                    await state.updateOdometer(
                      vehicle.id,
                      newKm,
                      newMonthlyAvgKm: newAvg.clamp(50, 20000),
                    );
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Το κοντέρ ενημερώθηκε στα ${CarakiTheme.formatKm(newKm)}!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text(
                    'Αποθήκευση & Επανυπολογισμός Service',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 2. Unified Service Event Dialog with Multi-Part Checklist
  static Future<void> showAddServiceEventSheet(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle, {
    Set<PartType>? preselectedParts,
  }) async {
    final now = DateTime.now();
    DateTime selectedDate = now;
    final selectedParts = <PartType>{...(preselectedParts ?? {PartType.engineOil})};

    final titleCtrl = TextEditingController(
      text: preselectedParts != null && preselectedParts.length == 1
          ? 'Συντήρηση: ${preselectedParts.first.title}'
          : 'Τακτικό Service & Έλεγχος',
    );
    final odoCtrl = TextEditingController(
      text: vehicle.estimatedOdometerKm(now).toString(),
    );
    final costCtrl = TextEditingController(text: '120');
    final workshopCtrl = TextEditingController(text: '');
    final phoneCtrl = TextEditingController(text: '');
    final receiptCtrl = TextEditingController(text: '');
    final notesCtrl = TextEditingController(text: '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CarakiTheme.statusGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.build_circle_rounded, color: CarakiTheme.statusGreen, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Καταχώρηση Εργασίας / Service',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Τσέκαρε όσα αλλάχτηκαν για να μηδενίσουν οι μπάρες υγείας τους!',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Τίτλος Service (π.χ. Γενικό Service, Αλλαγή Ελαστικών)',
                        prefixIcon: Icon(Icons.title_rounded),
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
                            decoration: const InputDecoration(
                              labelText: 'Χιλιόμετρα (Κοντέρ)',
                              prefixIcon: Icon(Icons.speed_rounded),
                              suffixText: 'χλμ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Συνολικό Κόστος',
                              prefixIcon: Icon(Icons.euro_rounded),
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
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ημερομηνία Πραγματοποίησης',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(
                          CarakiTheme.formatDate(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Checklist Εργασιών & Ανταλλακτικών',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Επιλεγμένα: ${selectedParts.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: CarakiTheme.primaryElectricBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...PartType.values.map((pt) {
                      final isChecked = selectedParts.contains(pt);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setModalState(() {
                              if (isChecked) {
                                selectedParts.remove(pt);
                              } else {
                                selectedParts.add(pt);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? CarakiTheme.primaryElectricBlue.withValues(alpha: 0.14)
                                  : Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isChecked
                                    ? CarakiTheme.primaryElectricBlue
                                    : Colors.transparent,
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  pt.icon,
                                  size: 22,
                                  color: isChecked
                                      ? CarakiTheme.primaryElectricBlue
                                      : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.65),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pt.title,
                                        style: TextStyle(
                                          fontWeight: isChecked ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      Text(
                                        pt.subtitle,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (val) {
                                    setModalState(() {
                                      if (val == true) {
                                        selectedParts.add(pt);
                                      } else {
                                        selectedParts.remove(pt);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: workshopCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Συνεργείο / Τεχνικός',
                              prefixIcon: Icon(Icons.storefront_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Τηλέφωνο Συνεργείου',
                              prefixIcon: Icon(Icons.phone_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: receiptCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Αριθμός Απόδειξης / Τιμολογίου (Προαιρετικό)',
                        prefixIcon: Icon(Icons.receipt_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Σημειώσεις (μάρκα ανταλλακτικών, εγγύηση, παρατηρήσεις)',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (selectedParts.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Επίλεξε τουλάχιστον 1 εργασία/εξάρτημα από τη λίστα!'),
                              ),
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
                            workshopPhone: phoneCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                            receiptCodeOrRef: receiptCtrl.text.trim().isEmpty ? null : receiptCtrl.text.trim(),
                          );
                          await state.addServiceEvent(event);
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Το Service αποθηκεύτηκε & ενημερώθηκαν ${selectedParts.length} εξαρτήματα!',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'Καταχώρηση Service & Ανανέωση Εξαρτημάτων',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
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

  /// 3. Edit Component Interval & Last Service Config Dialog
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(config.partType.icon, color: CarakiTheme.primaryElectricBlue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.partType.title,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Ρύθμιση ορίων αλλαγής & τελευταίου ελέγχου',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: kmIntervalCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Όριο Αλλαγής (Χλμ)',
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
                              labelText: 'Όριο Αλλαγής (Μήνες)',
                              suffixText: 'μήνες',
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
                            controller: lastKmCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Χλμ Τελευταίας Αλλαγής',
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
                                labelText: 'Ημ/νία Τελευταίας Αλλαγής',
                              ),
                              child: Text(CarakiTheme.formatDate(lastDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Σημείωση / Τύπος ανταλλακτικού (π.χ. Michelin, Castrol 5W-30)',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              showAddServiceEventSheet(
                                context,
                                state,
                                vehicle,
                                preselectedParts: {config.partType},
                              );
                            },
                            icon: const Icon(Icons.autorenew_rounded),
                            label: const Text('Έγινε Αλλαγή Τώρα'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final updated = config.copyWith(
                                intervalKm: int.tryParse(kmIntervalCtrl.text.trim()) ?? config.intervalKm,
                                intervalMonths: int.tryParse(monthsIntervalCtrl.text.trim()) ?? config.intervalMonths,
                                lastServiceKm: int.tryParse(lastKmCtrl.text.trim()) ?? config.lastServiceKm,
                                lastServiceDate: lastDate,
                                notes: notesCtrl.text.trim(),
                              );
                              await state.updatePartConfig(vehicle.id, updated);
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            },
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Αποθήκευση'),
                          ),
                        ),
                      ],
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

  /// 4. Add/Edit Legal Reminder (KTEO, Insurance, KEK, Road Tax, Custom)
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
      text: existing != null ? existing.cost.toStringAsFixed(2) : '55.00',
    );
    final providerCtrl = TextEditingController(text: existing?.providerOrCenter ?? '');
    final policyCtrl = TextEditingController(text: existing?.policyOrRefNumber ?? '');
    final phoneCtrl = TextEditingController(text: existing?.emergencyPhone ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null
                          ? 'Νέα Υπενθύμιση / Υποχρέωση'
                          : 'Επεξεργασία: ${existing.customTitle}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<LegalObligationType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Κατηγορία Υποχρέωσης',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      items: LegalObligationType.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Icon(t.icon, size: 18),
                              const SizedBox(width: 8),
                              Text(t.title),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedType = val;
                            if (existing == null) {
                              titleCtrl.text = val.title;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Τίτλος Υπενθύμισης',
                        prefixIcon: Icon(Icons.label_rounded),
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
                                prefixIcon: Icon(Icons.event_rounded),
                              ),
                              child: Text(
                                CarakiTheme.formatDate(dueDate),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Κόστος (€)',
                              prefixIcon: Icon(Icons.euro_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: providerCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Εταιρεία / Κέντρο (π.χ. Autovision ΚΤΕΟ, Anytime)',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: policyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Αρ. Συμβολαίου / Δελτίου',
                              prefixIcon: Icon(Icons.badge_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Τηλ. Οδικής / Κέντρου',
                              prefixIcon: Icon(Icons.phone_in_talk_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Σημειώσεις (καλύψεις, δικαιολογητικά, κωδικός πληρωμής RF)',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () async {
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
                            policyOrRefNumber: policyCtrl.text.trim(),
                            emergencyPhone: phoneCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                          );
                          await state.addOrUpdateReminder(reminder);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.notifications_active_rounded),
                        label: const Text(
                          'Αποθήκευση Υπενθύμισης',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
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

  /// 5. Add Fuel Fill-up Sheet
  static Future<void> showAddFuelSheet(
    BuildContext context,
    CarakiState state,
    Vehicle vehicle,
  ) async {
    final now = DateTime.now();
    DateTime selectedDate = now;
    bool isFullTank = true;

    final odoCtrl = TextEditingController(
      text: (vehicle.estimatedOdometerKm(now) + 150).toString(),
    );
    final litersCtrl = TextEditingController(text: '32.0');
    final pricePerLiterCtrl = TextEditingController(text: '1.849');
    final totalCostCtrl = TextEditingController(text: '59.17');
    final stationCtrl = TextEditingController(text: '');
    final notesCtrl = TextEditingController(text: '');

    void recalcTotal() {
      final l = double.tryParse(litersCtrl.text.replaceAll(',', '.')) ?? 0;
      final p = double.tryParse(pricePerLiterCtrl.text.replaceAll(',', '.')) ?? 0;
      if (l > 0 && p > 0) {
        totalCostCtrl.text = (l * p).toStringAsFixed(2);
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CarakiTheme.statusAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_gas_station_rounded, color: CarakiTheme.statusAmber),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Καταγραφή Ανεφοδιασμού Καυσίμου',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Ενημερώνει αυτόματα και τα χιλιόμετρα του οχήματος!',
                                style: TextStyle(fontSize: 12.5, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: odoCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Χιλιόμετρα Κοντέρ',
                              prefixIcon: Icon(Icons.speed_rounded),
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
                                initialDate: selectedDate,
                                firstDate: DateTime(2015),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Ημερομηνία',
                                prefixIcon: Icon(Icons.calendar_today_rounded),
                              ),
                              child: Text(CarakiTheme.formatDate(selectedDate)),
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
                            controller: litersCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => recalcTotal(),
                            decoration: const InputDecoration(
                              labelText: 'Λίτρα (L)',
                              suffixText: 'L',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: pricePerLiterCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => recalcTotal(),
                            decoration: const InputDecoration(
                              labelText: 'Τιμή / Λίτρο',
                              suffixText: '€/L',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: totalCostCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Σύνολο (€)',
                              suffixText: '€',
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
                            controller: stationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Πρατήριο (π.χ. Shell, EKO)',
                              prefixIcon: Icon(Icons.ev_station_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          label: const Text('Πλήρες Γέμισμα'),
                          selected: isFullTank,
                          onSelected: (val) => setModalState(() => isFullTank = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Σημείωση (π.χ. Ταξίδι Εθνική Οδό, 98 οκτάνια)',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final odo = int.tryParse(odoCtrl.text.trim()) ?? vehicle.currentOdometerKm;
                          final liters = double.tryParse(litersCtrl.text.replaceAll(',', '.').trim()) ?? 0.0;
                          final price = double.tryParse(pricePerLiterCtrl.text.replaceAll(',', '.').trim()) ?? 0.0;
                          final total = double.tryParse(totalCostCtrl.text.replaceAll(',', '.').trim()) ?? (liters * price);

                          final entry = FuelEntry(
                            id: 'fuel-${DateTime.now().millisecondsSinceEpoch}',
                            vehicleId: vehicle.id,
                            date: selectedDate,
                            odometerKm: odo,
                            liters: liters,
                            pricePerLiter: price,
                            totalCost: total,
                            isFullTank: isFullTank,
                            stationName: stationCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                          );
                          await state.addFuelEntry(entry);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.add_task_rounded),
                        label: const Text(
                          'Αποθήκευση Ανεφοδιασμού',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
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

  /// 6. Add / Edit Vehicle in Garage Dialog
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
    final avgKmCtrl = TextEditingController(text: (existing?.averageMonthlyKm ?? 1000).toString());

    final vinCtrl = TextEditingController(text: existing?.vin ?? '');
    final engineCtrl = TextEditingController(text: existing?.engineCode ?? '');
    final ccCtrl = TextEditingController(text: (existing?.engineCc ?? 1400).toString());
    final hpCtrl = TextEditingController(text: (existing?.horsepower ?? 110).toString());
    final colorCtrl = TextEditingController(text: existing?.colorName ?? 'Ασημί / Γκρι');

    final oilSpecCtrl = TextEditingController(text: existing?.oilSpec ?? '5W-30 Full Synthetic');
    final tireDimCtrl = TextEditingController(text: existing?.tireDimension ?? '205/55 R16');
    final tirePsiCtrl = TextEditingController(text: existing?.tirePressurePsi ?? '33 PSI Εμπρός / 31 PSI Πίσω');
    final batterySpecCtrl = TextEditingController(text: existing?.batterySpec ?? '12V 60Ah EFB');
    final wiperCtrl = TextEditingController(text: existing?.wiperSize ?? '600mm / 400mm');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
                  ),
                  children: [
                    Text(
                      existing == null ? 'Προσθήκη Νέου Οχήματος στο Γκαράζ' : 'Επεξεργασία Οχήματος',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<VehicleType>(
                      segments: VehicleType.values
                          .map((vt) => ButtonSegment(
                                value: vt,
                                icon: Icon(vt.icon),
                                label: Text(vt.label),
                              ))
                          .toList(),
                      selected: {selectedType},
                      onSelectionChanged: (s) => setModalState(() => selectedType = s.first),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: makeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Μάρκα (π.χ. Toyota, VW)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: modelCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Μοντέλο (π.χ. Yaris, Golf)',
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
                              labelText: 'Πινακίδα (π.χ. ΙΖΜ-8492)',
                              prefixIcon: Icon(Icons.pin_rounded),
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
                              labelText: 'Έτος Κυκλοφορίας',
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
                              labelText: 'Τρέχοντα Χιλιόμετρα',
                              suffixText: 'χλμ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: avgKmCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Μέσος Όρος / Μήνα',
                              suffixText: 'χλμ',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FuelType>(
                      initialValue: selectedFuel,
                      decoration: const InputDecoration(
                        labelText: 'Καύσιμο / Κινητήρας',
                        prefixIcon: Icon(Icons.local_gas_station_rounded),
                      ),
                      items: FuelType.values
                          .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedFuel = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Τεχνική Ταυτότητα & Quick Specs (για γρήγορη εύρεση)',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vinCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Αριθμός Πλαισίου (VIN - 17 χαρακτήρες)',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: engineCtrl,
                            decoration: const InputDecoration(labelText: 'Κωδικός Κινητήρα'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: ccCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Κυβικά (cc)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: hpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Ίπποι (HP)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: oilSpecCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Προδιαγραφή Λαδιών (π.χ. 5W-30 API SP • 4.2L)',
                        prefixIcon: Icon(Icons.oil_barrel_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tireDimCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Διάσταση Ελαστικών',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: tirePsiCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Πίεση Ελαστικών (PSI/Bar)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: batterySpecCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Τύπος Μπαταρίας',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: wiperCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Υαλοκαθαριστήρες (mm)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () async {
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
                            engineCode: engineCtrl.text.trim(),
                            engineCc: int.tryParse(ccCtrl.text.trim()) ?? 1400,
                            horsepower: int.tryParse(hpCtrl.text.trim()) ?? 100,
                            fuelType: selectedFuel,
                            colorName: colorCtrl.text.trim(),
                            currentOdometerKm: odo,
                            lastOdometerUpdate: existing?.lastOdometerUpdate ?? now,
                            averageMonthlyKm: int.tryParse(avgKmCtrl.text.trim()) ?? 1000,
                            oilSpec: oilSpecCtrl.text.trim(),
                            tireDimension: tireDimCtrl.text.trim(),
                            tirePressurePsi: tirePsiCtrl.text.trim(),
                            batterySpec: batterySpecCtrl.text.trim(),
                            wiperSize: wiperCtrl.text.trim(),
                            partConfigs: partConfigs,
                            isDemo: false,
                          );

                          await state.addOrUpdateVehicle(vehicle);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          existing == null ? 'Προσθήκη Οχήματος' : 'Αποθήκευση Αλλαγών',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
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
