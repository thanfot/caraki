import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import '../widgets/caraki_modals.dart';

class GarageSettingsScreen extends StatelessWidget {
  final CarakiState state;

  const GarageSettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // 1. Garage Header & Add Vehicle Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Τα Οχήματά μου (Γκαράζ)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ενεργά οχήματα: ${state.vehicles.length}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => CarakiModals.showAddOrEditVehicleSheet(context, state),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Προσθήκη Οχήματος'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...state.vehicles.map((v) => _buildVehicleGarageCard(context, v, now)),
        const SizedBox(height: 22),

        // 2. Appearance / Theme Mode Selector
        const Text(
          'Εμφάνιση & Θέμα (Automotive UI)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Επιλογή Θέματος Εφαρμογής',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Σκούρο (Dark)'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Φωτεινό (Light)'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Αυτόματο'),
                      ),
                    ],
                    selected: {state.themeMode},
                    onSelectionChanged: (s) => state.setThemeMode(s.first),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 3. Data Management, Backup & Demo Controls
        const Text(
          'Δεδομένα, Backup & Demo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x222563EB),
                  child: Icon(Icons.upload_file_rounded, color: CarakiTheme.primaryElectricBlue),
                ),
                title: const Text(
                  'Εξαγωγή Πλήρους Backup (JSON)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                subtitle: const Text(
                  'Αντιγραφή όλων των οχημάτων, service και καυσίμων στο πρόχειρο',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () async {
                  final jsonStr = await state.exportBackup();
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Το πλήρες Backup (JSON) αντιγράφηκε στο πρόχειρο!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x2210B981),
                  child: Icon(Icons.download_rounded, color: CarakiTheme.statusGreen),
                ),
                title: const Text(
                  'Εισαγωγή Backup (JSON)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                subtitle: const Text(
                  'Επαναφορά δεδομένων από αποθηκευμένο JSON backup',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => _showImportBackupDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x22F59E0B),
                  child: Icon(Icons.restore_rounded, color: CarakiTheme.statusAmber),
                ),
                title: const Text(
                  'Επαναφορά Προ-φορτωμένων Demo Οχημάτων',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                subtitle: const Text(
                  'Φόρτωση ξανά του Toyota Yaris Hybrid & της Yamaha MT-07',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () async {
                  await state.resetDemoData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Τα Demo οχήματα και το ιστορικό τους επαναφέρθηκαν!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x22EF4444),
                  child: Icon(Icons.delete_forever_rounded, color: CarakiTheme.statusRed),
                ),
                title: const Text(
                  'Διαγραφή Demo / Ξεκίνα από την αρχή',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: CarakiTheme.statusRed,
                  ),
                ),
                subtitle: const Text(
                  'Εκκαθάριση όλων των στοιχείων για να βάλεις μόνο το δικό σου όχημα',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => _confirmClearAllData(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleGarageCard(BuildContext context, Vehicle v, DateTime now) {
    final isSelected = state.selectedVehicle?.id == v.id;
    final health = v.overallHealthScore(now);
    final healthColor = CarakiTheme.healthColor(health / 100.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected
              ? CarakiTheme.primaryElectricBlue
              : Colors.grey.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => state.selectVehicle(v.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: CarakiTheme.primaryElectricBlue.withValues(alpha: 0.15),
                    child: Icon(v.type.icon, color: CarakiTheme.primaryElectricBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                v.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: CarakiTheme.primaryElectricBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ΕΝΕΡΓΟ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            GreekLicensePlateBadge(plate: v.licensePlate, compact: true),
                            const SizedBox(width: 10),
                            Text(
                              '~${CarakiTheme.formatKm(v.estimatedOdometerKm(now))}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Υγεία: $health%',
                      style: TextStyle(
                        color: healthColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Λάδια: ${v.oilSpec} • Ελαστικά: ${v.tireDimension}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    tooltip: 'Επεξεργασία οχήματος',
                    onPressed: () => CarakiModals.showAddOrEditVehicleSheet(
                      context,
                      state,
                      existing: v,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: CarakiTheme.statusRed),
                    tooltip: 'Διαγραφή οχήματος',
                    onPressed: () => state.deleteVehicle(v.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImportBackupDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Εισαγωγή Backup (JSON)'),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Επικόλλησε εδώ το JSON backup του Caraki...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ακύρωση'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await state.importBackup(ctrl.text.trim());
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Το Backup εισήχθη με επιτυχία!')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Μη έγκυρη μορφή JSON Backup.')),
                  );
                }
              }
            },
            child: const Text('Εισαγωγή'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Διαγραφή Demo & Όλων των Δεδομένων;'),
        content: const Text(
          'Θέλεις να διαγραφούν τα προ-φορτωμένα Demo οχήματα και να ξεκινήσεις με καθαρό Γκαράζ;',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ακύρωση'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: CarakiTheme.statusRed),
            onPressed: () async {
              await state.clearAllData();
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Όλα τα δεδομένα διαγράφηκαν. Πρόσθεσε το πρώτο σου όχημα!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Διαγραφή & Εκκίνηση'),
          ),
        ],
      ),
    );
  }
}
