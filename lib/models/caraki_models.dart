import 'package:flutter/material.dart';

enum VehicleType {
  car('Αυτοκίνητο', Icons.directions_car_rounded),
  motorcycle('Μηχανή / Scooter', Icons.two_wheeler_rounded),
  van('Φορτηγάκι / Van', Icons.airport_shuttle_rounded);

  final String label;
  final IconData icon;
  const VehicleType(this.label, this.icon);

  static VehicleType fromName(String name) {
    return VehicleType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => VehicleType.car,
    );
  }
}

enum FuelType {
  petrol('Βενζίνη'),
  diesel('Πετρέλαιο (Diesel)'),
  hybrid('Υβριδικό (Hybrid)'),
  lpg('Υγραέριο (LPG)'),
  cng('Φυσικό Αέριο (CNG)'),
  electric('Ηλεκτρικό (EV)');

  final String label;
  const FuelType(this.label);

  static FuelType fromName(String name) {
    return FuelType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FuelType.petrol,
    );
  }
}

/// The 12 key vehicle maintenance components tracked with dual thresholds (km & months)
enum PartType {
  engineOil(
    'Λάδια Κινητήρα & Φίλτρο',
    'Αλλαγή λιπαντικού και φίλτρου λαδιού',
    Icons.oil_barrel_rounded,
    10000,
    12,
  ),
  airCabinFilter(
    'Φίλτρο Αέρα & Καμπίνας',
    'Καθαρός αέρας κινητήρα και κλιματισμού A/C',
    Icons.air_rounded,
    15000,
    12,
  ),
  tiresChange(
    'Ελαστικά (Αλλαγή)',
    'Αντικατάσταση ελαστικών λόγω φθοράς ή ηλικίας',
    Icons.tire_repair_rounded,
    40000,
    48,
  ),
  tiresRotation(
    'Ελαστικά (Μπρος-Πίσω & Ζυγοστάθμιση)',
    'Περιστροφή ελαστικών και έλεγχος ευθυγράμμισης',
    Icons.sync_rounded,
    10000,
    12,
  ),
  brakePads(
    'Τακάκια & Δισκόπλακες Φρένων',
    'Έλεγχος και αντικατάσταση υλικών τριβής φρένων',
    Icons.album_rounded,
    30000,
    24,
  ),
  brakeFluid(
    'Υγρά Φρένων',
    'Αντικατάσταση υγρών κυκλώματος πέδησης (DOT4)',
    Icons.water_drop_rounded,
    40000,
    24,
  ),
  sparkPlugs(
    'Μπουζί / Προθερμαντήρες',
    'Ανάφλεξη κινητήρα και βέλτιστη καύση',
    Icons.bolt_rounded,
    40000,
    36,
  ),
  timingBelt(
    'Ιμάντας Χρονισμού / Καδένα & Αντλία',
    'Κρίσιμο σετ χρονισμού κινητήρα και αντλία νερού',
    Icons.settings_suggest_rounded,
    80000,
    60,
  ),
  battery(
    'Μπαταρία 12V',
    'Έλεγχος τάσης εκκίνησης και αντικατάσταση',
    Icons.battery_charging_full_rounded,
    50000,
    48,
  ),
  coolantAc(
    'Υγρά Ψυγείου & Φρέον A/C',
    'Παραφλού ψύξης κινητήρα και συντήρηση κλιματισμού',
    Icons.ac_unit_rounded,
    45000,
    36,
  ),
  suspension(
    'Αμορτισέρ & Ανάρτηση',
    'Απόσβεση κραδασμών, ψαλίδια και συνεμπλόκ',
    Icons.height_rounded,
    70000,
    60,
  ),
  transmissionClutch(
    'Βαλβολίνες Σασμάν & Συμπλέκτης',
    'Λίπανση κιβωτίου ταχυτήτων και δίσκος-πλατό',
    Icons.miscellaneous_services_rounded,
    60000,
    48,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final int defaultIntervalKm;
  final int defaultIntervalMonths;

  const PartType(
    this.title,
    this.subtitle,
    this.icon,
    this.defaultIntervalKm,
    this.defaultIntervalMonths,
  );

  static PartType fromName(String name) {
    return PartType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => PartType.engineOil,
    );
  }
}

enum LegalObligationType {
  kteo('ΚΤΕΟ', 'Τεχνικός Έλεγχος Οχήματος', Icons.verified_rounded),
  insurance('Ασφάλεια Οχήματος', 'Ασφαλιστήριο συμβόλαιο & Οδική Βοήθεια', Icons.shield_rounded),
  kek('Κάρτα Καυσαερίων (ΚΕΚ)', 'Έλεγχος εκπομπών ρύπων', Icons.cloud_done_rounded),
  roadTax('Τέλη Κυκλοφορίας', 'Ετήσια τέλη κυκλοφορίας (myCAR)', Icons.receipt_long_rounded),
  custom('Προσαρμοσμένη Υπενθύμιση', 'Προσωπική σημείωση / έλεγχος', Icons.notifications_active_rounded);

  final String title;
  final String subtitle;
  final IconData icon;
  const LegalObligationType(this.title, this.subtitle, this.icon);

  static LegalObligationType fromName(String name) {
    return LegalObligationType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => LegalObligationType.custom,
    );
  }
}

class PartSpecConfig {
  final PartType partType;
  final int intervalKm;
  final int intervalMonths;
  final int lastServiceKm;
  final DateTime lastServiceDate;
  final String notes;

  const PartSpecConfig({
    required this.partType,
    required this.intervalKm,
    required this.intervalMonths,
    required this.lastServiceKm,
    required this.lastServiceDate,
    this.notes = '',
  });

  PartSpecConfig copyWith({
    int? intervalKm,
    int? intervalMonths,
    int? lastServiceKm,
    DateTime? lastServiceDate,
    String? notes,
  }) {
    return PartSpecConfig(
      partType: partType,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      lastServiceKm: lastServiceKm ?? this.lastServiceKm,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      notes: notes ?? this.notes,
    );
  }

  /// Calculates remaining km based on current/estimated odometer
  int remainingKm(int currentKm) {
    final used = (currentKm - lastServiceKm).clamp(0, 999999);
    return intervalKm - used;
  }

  /// Calculates remaining days based on last service date + intervalMonths
  int remainingDays(DateTime now) {
    final dueDate = DateTime(
      lastServiceDate.year,
      lastServiceDate.month + intervalMonths,
      lastServiceDate.day,
    );
    return dueDate.difference(now).inDays;
  }

  DateTime get nextDueDate => DateTime(
        lastServiceDate.year,
        lastServiceDate.month + intervalMonths,
        lastServiceDate.day,
      );

  int get nextDueKm => lastServiceKm + intervalKm;

  /// Health ratio from 0.0 (needs immediate service/overdue) to 1.0 (brand new)
  /// Takes the minimum of distance life and time life!
  double healthPercentage(int currentKm, DateTime now) {
    final kmUsed = (currentKm - lastServiceKm).clamp(0, intervalKm * 2);
    final kmHealth = intervalKm > 0 ? (1.0 - (kmUsed / intervalKm)).clamp(0.0, 1.0) : 1.0;

    final totalDays = (intervalMonths * 30.4375).round();
    final daysUsed = now.difference(lastServiceDate).inDays.clamp(0, totalDays * 2);
    final timeHealth = totalDays > 0 ? (1.0 - (daysUsed / totalDays)).clamp(0.0, 1.0) : 1.0;

    return kmHealth < timeHealth ? kmHealth : timeHealth;
  }

  Map<String, dynamic> toJson() => {
        'partType': partType.name,
        'intervalKm': intervalKm,
        'intervalMonths': intervalMonths,
        'lastServiceKm': lastServiceKm,
        'lastServiceDate': lastServiceDate.toIso8601String(),
        'notes': notes,
      };

  factory PartSpecConfig.fromJson(Map<String, dynamic> json) {
    final pt = PartType.fromName(json['partType'] as String? ?? '');
    return PartSpecConfig(
      partType: pt,
      intervalKm: (json['intervalKm'] as num?)?.toInt() ?? pt.defaultIntervalKm,
      intervalMonths: (json['intervalMonths'] as num?)?.toInt() ?? pt.defaultIntervalMonths,
      lastServiceKm: (json['lastServiceKm'] as num?)?.toInt() ?? 0,
      lastServiceDate: DateTime.tryParse(json['lastServiceDate'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class ServiceEvent {
  final String id;
  final String vehicleId;
  final DateTime date;
  final int odometerKm;
  final String title;
  final List<PartType> servicedParts;
  final double totalCost;
  final String workshopName;
  final String workshopPhone;
  final String notes;
  final String? receiptCodeOrRef;

  const ServiceEvent({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerKm,
    required this.title,
    required this.servicedParts,
    required this.totalCost,
    this.workshopName = '',
    this.workshopPhone = '',
    this.notes = '',
    this.receiptCodeOrRef,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'odometerKm': odometerKm,
        'title': title,
        'servicedParts': servicedParts.map((p) => p.name).toList(),
        'totalCost': totalCost,
        'workshopName': workshopName,
        'workshopPhone': workshopPhone,
        'notes': notes,
        'receiptCodeOrRef': receiptCodeOrRef,
      };

  factory ServiceEvent.fromJson(Map<String, dynamic> json) {
    final rawParts = (json['servicedParts'] as List<dynamic>? ?? []);
    return ServiceEvent(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      odometerKm: (json['odometerKm'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Συντήρηση / Service',
      servicedParts: rawParts.map((e) => PartType.fromName(e.toString())).toList(),
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      workshopName: json['workshopName'] as String? ?? '',
      workshopPhone: json['workshopPhone'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      receiptCodeOrRef: json['receiptCodeOrRef'] as String?,
    );
  }
}

class LegalReminder {
  final String id;
  final String vehicleId;
  final LegalObligationType type;
  final String customTitle;
  final DateTime issueDate;
  final DateTime dueDate;
  final double cost;
  final String providerOrCenter; // e.g., Autovision KTEO, Anytime Insurance
  final String policyOrRefNumber;
  final String emergencyPhone; // e.g., Roadside assistance phone
  final bool isCompletedForCycle;
  final String notes;

  const LegalReminder({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.customTitle,
    required this.issueDate,
    required this.dueDate,
    this.cost = 0.0,
    this.providerOrCenter = '',
    this.policyOrRefNumber = '',
    this.emergencyPhone = '',
    this.isCompletedForCycle = false,
    this.notes = '',
  });

  int daysRemaining(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  LegalReminder copyWith({
    String? customTitle,
    DateTime? issueDate,
    DateTime? dueDate,
    double? cost,
    String? providerOrCenter,
    String? policyOrRefNumber,
    String? emergencyPhone,
    bool? isCompletedForCycle,
    String? notes,
  }) {
    return LegalReminder(
      id: id,
      vehicleId: vehicleId,
      type: type,
      customTitle: customTitle ?? this.customTitle,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      cost: cost ?? this.cost,
      providerOrCenter: providerOrCenter ?? this.providerOrCenter,
      policyOrRefNumber: policyOrRefNumber ?? this.policyOrRefNumber,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      isCompletedForCycle: isCompletedForCycle ?? this.isCompletedForCycle,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'type': type.name,
        'customTitle': customTitle,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'cost': cost,
        'providerOrCenter': providerOrCenter,
        'policyOrRefNumber': policyOrRefNumber,
        'emergencyPhone': emergencyPhone,
        'isCompletedForCycle': isCompletedForCycle,
        'notes': notes,
      };

  factory LegalReminder.fromJson(Map<String, dynamic> json) {
    return LegalReminder(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      type: LegalObligationType.fromName(json['type'] as String? ?? ''),
      customTitle: json['customTitle'] as String? ?? '',
      issueDate: DateTime.tryParse(json['issueDate'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      providerOrCenter: json['providerOrCenter'] as String? ?? '',
      policyOrRefNumber: json['policyOrRefNumber'] as String? ?? '',
      emergencyPhone: json['emergencyPhone'] as String? ?? '',
      isCompletedForCycle: json['isCompletedForCycle'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class FuelEntry {
  final String id;
  final String vehicleId;
  final DateTime date;
  final int odometerKm;
  final double liters;
  final double pricePerLiter;
  final double totalCost;
  final bool isFullTank;
  final String stationName;
  final String notes;

  const FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerKm,
    required this.liters,
    required this.pricePerLiter,
    required this.totalCost,
    this.isFullTank = true,
    this.stationName = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'odometerKm': odometerKm,
        'liters': liters,
        'pricePerLiter': pricePerLiter,
        'totalCost': totalCost,
        'isFullTank': isFullTank,
        'stationName': stationName,
        'notes': notes,
      };

  factory FuelEntry.fromJson(Map<String, dynamic> json) {
    return FuelEntry(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      odometerKm: (json['odometerKm'] as num?)?.toInt() ?? 0,
      liters: (json['liters'] as num?)?.toDouble() ?? 0.0,
      pricePerLiter: (json['pricePerLiter'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      isFullTank: json['isFullTank'] as bool? ?? true,
      stationName: json['stationName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}

class Vehicle {
  final String id;
  final VehicleType type;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String vin;
  final String engineCode;
  final int engineCc;
  final int horsepower;
  final FuelType fuelType;
  final String colorName;
  final int accentColorValue;

  // Odometer & smart estimation
  final int currentOdometerKm;
  final DateTime lastOdometerUpdate;
  final int averageMonthlyKm;

  // Quick reference specs for owner
  final String oilSpec; // e.g., "0W-20 API SP (3.6L)"
  final String tireDimension; // e.g., "205/55 R16 91V"
  final String tirePressurePsi; // e.g., "33 PSI Εμπρός / 32 PSI Πίσω"
  final String batterySpec; // e.g., "12V 45Ah 360A EFB"
  final String wiperSize; // e.g., "650mm Οδηγού / 400mm Συνοδηγού"

  final Map<PartType, PartSpecConfig> partConfigs;
  final bool isDemo;

  const Vehicle({
    required this.id,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vin = '',
    this.engineCode = '',
    this.engineCc = 1500,
    this.horsepower = 115,
    this.fuelType = FuelType.petrol,
    this.colorName = 'Ασημί Μεταλλικό',
    this.accentColorValue = 0xFF2563EB,
    required this.currentOdometerKm,
    required this.lastOdometerUpdate,
    this.averageMonthlyKm = 1000,
    this.oilSpec = '5W-30 Full Synthetic',
    this.tireDimension = '205/55 R16',
    this.tirePressurePsi = '33 PSI Εμπρός / 31 PSI Πίσω',
    this.batterySpec = '12V 60Ah EFB',
    this.wiperSize = '600mm / 400mm',
    required this.partConfigs,
    this.isDemo = false,
  });

  String get fullName => '$make $model ($year)';

  /// Smart estimation of today's odometer based on days elapsed since last manual update
  /// and the user's monthly average km!
  int estimatedOdometerKm(DateTime now) {
    final daysElapsed = now.difference(lastOdometerUpdate).inDays.clamp(0, 365);
    if (daysElapsed <= 1) return currentOdometerKm;
    final dailyKm = averageMonthlyKm / 30.0;
    return currentOdometerKm + (daysElapsed * dailyKm).round();
  }

  /// True if more than 28 days have passed since the last odometer check-up
  bool needsMonthlyOdometerCheckup(DateTime now) {
    return now.difference(lastOdometerUpdate).inDays >= 28;
  }

  /// Overall vehicle health score (0 to 100)
  int overallHealthScore(DateTime now) {
    if (partConfigs.isEmpty) return 100;
    final estKm = estimatedOdometerKm(now);
    double sum = 0;
    for (final config in partConfigs.values) {
      sum += config.healthPercentage(estKm, now);
    }
    return ((sum / partConfigs.length) * 100).round().clamp(0, 100);
  }

  Vehicle copyWith({
    VehicleType? type,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? vin,
    String? engineCode,
    int? engineCc,
    int? horsepower,
    FuelType? fuelType,
    String? colorName,
    int? accentColorValue,
    int? currentOdometerKm,
    DateTime? lastOdometerUpdate,
    int? averageMonthlyKm,
    String? oilSpec,
    String? tireDimension,
    String? tirePressurePsi,
    String? batterySpec,
    String? wiperSize,
    Map<PartType, PartSpecConfig>? partConfigs,
    bool? isDemo,
  }) {
    return Vehicle(
      id: id,
      type: type ?? this.type,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      engineCode: engineCode ?? this.engineCode,
      engineCc: engineCc ?? this.engineCc,
      horsepower: horsepower ?? this.horsepower,
      fuelType: fuelType ?? this.fuelType,
      colorName: colorName ?? this.colorName,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      currentOdometerKm: currentOdometerKm ?? this.currentOdometerKm,
      lastOdometerUpdate: lastOdometerUpdate ?? this.lastOdometerUpdate,
      averageMonthlyKm: averageMonthlyKm ?? this.averageMonthlyKm,
      oilSpec: oilSpec ?? this.oilSpec,
      tireDimension: tireDimension ?? this.tireDimension,
      tirePressurePsi: tirePressurePsi ?? this.tirePressurePsi,
      batterySpec: batterySpec ?? this.batterySpec,
      wiperSize: wiperSize ?? this.wiperSize,
      partConfigs: partConfigs ?? this.partConfigs,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'make': make,
        'model': model,
        'year': year,
        'licensePlate': licensePlate,
        'vin': vin,
        'engineCode': engineCode,
        'engineCc': engineCc,
        'horsepower': horsepower,
        'fuelType': fuelType.name,
        'colorName': colorName,
        'accentColorValue': accentColorValue,
        'currentOdometerKm': currentOdometerKm,
        'lastOdometerUpdate': lastOdometerUpdate.toIso8601String(),
        'averageMonthlyKm': averageMonthlyKm,
        'oilSpec': oilSpec,
        'tireDimension': tireDimension,
        'tirePressurePsi': tirePressurePsi,
        'batterySpec': batterySpec,
        'wiperSize': wiperSize,
        'partConfigs': partConfigs.values.map((e) => e.toJson()).toList(),
        'isDemo': isDemo,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final rawConfigs = json['partConfigs'] as List<dynamic>? ?? [];
    final map = <PartType, PartSpecConfig>{};
    for (final item in rawConfigs) {
      final cfg = PartSpecConfig.fromJson(item as Map<String, dynamic>);
      map[cfg.partType] = cfg;
    }
    final odo = (json['currentOdometerKm'] as num?)?.toInt() ?? 0;
    final lastUpd = DateTime.tryParse(json['lastOdometerUpdate'] as String? ?? '') ?? DateTime.now();
    for (final pt in PartType.values) {
      map.putIfAbsent(
        pt,
        () => PartSpecConfig(
          partType: pt,
          intervalKm: pt.defaultIntervalKm,
          intervalMonths: pt.defaultIntervalMonths,
          lastServiceKm: odo,
          lastServiceDate: lastUpd,
        ),
      );
    }

    return Vehicle(
      id: json['id'] as String,
      type: VehicleType.fromName(json['type'] as String? ?? ''),
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2020,
      licensePlate: json['licensePlate'] as String? ?? '',
      vin: json['vin'] as String? ?? '',
      engineCode: json['engineCode'] as String? ?? '',
      engineCc: (json['engineCc'] as num?)?.toInt() ?? 1400,
      horsepower: (json['horsepower'] as num?)?.toInt() ?? 100,
      fuelType: FuelType.fromName(json['fuelType'] as String? ?? ''),
      colorName: json['colorName'] as String? ?? '',
      accentColorValue: (json['accentColorValue'] as num?)?.toInt() ?? 0xFF2563EB,
      currentOdometerKm: odo,
      lastOdometerUpdate: lastUpd,
      averageMonthlyKm: (json['averageMonthlyKm'] as num?)?.toInt() ?? 1000,
      oilSpec: json['oilSpec'] as String? ?? '5W-30',
      tireDimension: json['tireDimension'] as String? ?? '205/55 R16',
      tirePressurePsi: json['tirePressurePsi'] as String? ?? '33 PSI / 31 PSI',
      batterySpec: json['batterySpec'] as String? ?? '12V 60Ah',
      wiperSize: json['wiperSize'] as String? ?? '600mm / 400mm',
      partConfigs: map,
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }
}
