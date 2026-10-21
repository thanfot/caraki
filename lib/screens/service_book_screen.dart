import 'package:flutter/material.dart';
import '../data/caraki_repository.dart';
import '../models/caraki_models.dart';
import '../theme/caraki_theme.dart';
import '../widgets/caraki_animated_widgets.dart';
import '../widgets/caraki_modals.dart';

class ServiceBookScreen extends StatefulWidget {
  final CarakiState state;

  const ServiceBookScreen({super.key, required this.state});

  @override
  State<ServiceBookScreen> createState() => _ServiceBookScreenState();
}

class _ServiceBookScreenState extends State<ServiceBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.state.selectedVehicle;
    if (vehicle == null) {
      return const Center(child: Text('Επίλεξε ένα όχημα πρώτα.'));
    }

    final now = DateTime.now();
    final estKm = vehicle.estimatedOdometerKm(now);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: CarakiTheme.primaryPapaya,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              tabs: const [
                Tab(text: 'Υγεία Εξαρτημάτων'),
                Tab(text: 'Ιστορικό Service'),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPartsHealthTab(context, vehicle, estKm, now),
              _buildServiceHistoryTab(context, vehicle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartsHealthTab(
    BuildContext context,
    Vehicle vehicle,
    int estKm,
    DateTime now,
  ) {
    final allConfigs = PartType.values
        .map((pt) =>
            vehicle.partConfigs[pt] ??
            PartSpecConfig(
              partType: pt,
              intervalKm: pt.defaultIntervalKm,
              intervalMonths: pt.defaultIntervalMonths,
              lastServiceKm: vehicle.currentOdometerKm,
              lastServiceDate: now,
            ))
        .toList();

    allConfigs.sort(
      (a, b) => a.healthPercentage(estKm, now).compareTo(b.healthPercentage(estKm, now)),
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
      itemCount: allConfigs.length,
      itemBuilder: (context, index) {
        final cfg = allConfigs[index];
        return StaggeredFadeSlide(
          index: index,
          child: _buildPartHealthCard(context, vehicle, cfg, estKm, now),
        );
      },
    );
  }

  Widget _buildPartHealthCard(
    BuildContext context,
    Vehicle vehicle,
    PartSpecConfig cfg,
    int estKm,
    DateTime now,
  ) {
    final ratio = cfg.healthPercentage(estKm, now);
    final percent = (ratio * 100).round();
    final color = CarakiTheme.healthColor(ratio);
    final remKm = cfg.remainingKm(estKm);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BouncyTap(
        onTap: () => CarakiModals.showEditPartConfigSheet(
          context,
          widget.state,
          vehicle,
          cfg,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(cfg.partType.icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cfg.partType.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            remKm > 0
                                ? 'Απομένουν ~${CarakiTheme.formatKm(remKm)}'
                                : 'Χρειάζεται αλλαγή!',
                            style: TextStyle(
                              fontSize: 12,
                              color: remKm <= 0 ? CarakiTheme.statusRed : Colors.grey,
                              fontWeight: remKm <= 0 ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedLiquidBar(ratio: ratio, color: color, height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHistoryTab(BuildContext context, Vehicle vehicle) {
    final events = widget.state.currentVehicleServices;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_edu_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Δεν υπάρχουν καταγεγραμμένα Service.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => CarakiModals.showAddServiceEventSheet(
                context,
                widget.state,
                vehicle,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Πρώτη Καταχώρηση Service'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return StaggeredFadeSlide(
          index: index,
          child: _buildServiceEventCard(context, events[index]),
        );
      },
    );
  }

  Widget _buildServiceEventCard(BuildContext context, ServiceEvent ev) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ev.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CarakiTheme.formatDate(ev.date)} • ${CarakiTheme.formatKm(ev.odometerKm)}',
                        style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  CarakiTheme.formatCurrency(ev.totalCost),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: CarakiTheme.statusGreen,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                  onPressed: () => widget.state.deleteServiceEvent(ev.id),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ev.servicedParts.map((pt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: CarakiTheme.primaryPapaya.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pt.title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: CarakiTheme.primaryPapaya,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
