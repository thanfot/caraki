import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import '../widgets/caraki_animated_widgets.dart';
import '../widgets/caraki_modals.dart';

class GarageSettingsScreen extends StatelessWidget {
  final CarakiState state;

  const GarageSettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.65);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        // 1. Garage Vehicles Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Οχήματα',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            GestureDetector(
              onTap: () => CarakiModals.showAddOrEditVehicleSheet(context, state),
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

        ...state.vehicles.map((v) => _buildVehicleGarageCard(context, v, now)),
        const SizedBox(height: 24),

        // 2. Appearance Section
        const Text(
          'Εμφάνιση',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _ThemePill(
                  label: 'Σκούρο',
                  isSelected: state.themeMode == ThemeMode.dark,
                  onTap: () => state.setThemeMode(ThemeMode.dark),
                ),
                const SizedBox(width: 8),
                _ThemePill(
                  label: 'Φωτεινό',
                  isSelected: state.themeMode == ThemeMode.light,
                  onTap: () => state.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ThemePill(
                  label: 'Αυτόματο',
                  isSelected: state.themeMode == ThemeMode.system,
                  onTap: () => state.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. Data & Backup Section
        const Text(
          'Δεδομένα',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                title: const Text(
                  'Αντιγραφή Backup (JSON)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: Text(
                  'Εξαγωγή όλων των δεδομένων στο πρόχειρο',
                  style: TextStyle(fontSize: 12.5, color: secondaryText),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
                onTap: () async {
                  final jsonStr = await state.exportBackup();
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Το Backup αντιγράφηκε στο πρόχειρο.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 18, endIndent: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                title: const Text(
                  'Εισαγωγή Backup',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: Text(
                  'Επαναφορά από αποθηκευμένο JSON',
                  style: TextStyle(fontSize: 12.5, color: secondaryText),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
                onTap: () => _showImportBackupDialog(context),
              ),
              const Divider(height: 1, indent: 18, endIndent: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                title: const Text(
                  'Επαναφορά Demo Οχημάτων',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: Text(
                  'Φόρτωση Toyota Yaris & Yamaha MT-07',
                  style: TextStyle(fontSize: 12.5, color: secondaryText),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
                onTap: () async {
                  await state.resetDemoData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Τα Demo οχήματα επαναφέρθηκαν.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 18, endIndent: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                title: const Text(
                  'Διαγραφή όλων των δεδομένων',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: CarakiTheme.statusRed,
                  ),
                ),
                subtitle: Text(
                  'Ξεκίνα από την αρχή με άδειο Γκαράζ',
                  style: TextStyle(fontSize: 12.5, color: secondaryText),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BouncyTap(
        onTap: () => state.selectVehicle(v.id),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CarakiTheme.primaryPapaya
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    v.type.icon,
                    color: isSelected ? Colors.white : onSurface,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${v.licensePlate} • ${CarakiTheme.formatKm(v.estimatedOdometerKm(now))}',
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20, color: secondaryText),
                  onPressed: () => CarakiModals.showAddOrEditVehicleSheet(
                    context,
                    state,
                    existing: v,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: secondaryText),
                  onPressed: () => state.deleteVehicle(v.id),
                ),
              ],
            ),
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
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Επικόλλησε εδώ το JSON backup...',
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
                if (ctx.mounted) Navigator.of(ctx).pop();
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Μη έγκυρη μορφή JSON.')),
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
        title: const Text('Διαγραφή όλων των δεδομένων;'),
        content: const Text(
          'Θα διαγραφούν όλα τα οχήματα και το ιστορικό ώστε να προσθέσεις το δικό σου όχημα από την αρχή.',
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
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: BouncyTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? onSurface
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Theme.of(context).scaffoldBackgroundColor
                    : onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
