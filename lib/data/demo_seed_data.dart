import '../models/caraki_models.dart';

class DemoSeedData {
  static List<Vehicle> buildDemoVehicles(DateTime now) {
    final car1Id = 'demo-car-yaris';
    final moto1Id = 'demo-moto-mt07';

    // 1. Toyota Yaris 1.5 Hybrid (2021) - Current odometer 58,400 km
    // Last odometer update was 32 days ago so user also sees the smart monthly check-up banner & estimation!
    final lastOdoDateCar = now.subtract(const Duration(days: 32));
    const baseKmCar = 58400;

    final carParts = <PartType, PartSpecConfig>{
      PartType.engineOil: PartSpecConfig(
        partType: PartType.engineOil,
        intervalKm: 10000,
        intervalMonths: 12,
        lastServiceKm: 50200, // ~8,200 + ~1,170 est = ~9,370 km used -> Due soon (Orange/Warning)!
        lastServiceDate: now.subtract(const Duration(days: 260)),
        notes: 'Toyota 0W-20 Hybrid Synthetic + γνήσιο φίλτρο',
      ),
      PartType.airCabinFilter: PartSpecConfig(
        partType: PartType.airCabinFilter,
        intervalKm: 15000,
        intervalMonths: 12,
        lastServiceKm: 50200,
        lastServiceDate: now.subtract(const Duration(days: 260)),
        notes: 'Φίλτρο ενεργού άνθρακα καμπίνας',
      ),
      PartType.tiresChange: PartSpecConfig(
        partType: PartType.tiresChange,
        intervalKm: 40000,
        intervalMonths: 48,
        lastServiceKm: 38000,
        lastServiceDate: now.subtract(const Duration(days: 540)),
        notes: 'Michelin Primacy 4 (DOT 1225)',
      ),
      PartType.tiresRotation: PartSpecConfig(
        partType: PartType.tiresRotation,
        intervalKm: 10000,
        intervalMonths: 12,
        lastServiceKm: 50200,
        lastServiceDate: now.subtract(const Duration(days: 260)),
        notes: 'Εμπρός-πίσω και ζυγοστάθμιση',
      ),
      PartType.brakePads: PartSpecConfig(
        partType: PartType.brakePads,
        intervalKm: 35000,
        intervalMonths: 36,
        lastServiceKm: 32000,
        lastServiceDate: now.subtract(const Duration(days: 700)),
        notes: 'Αλλαγή εμπρός τακάκια Brembo',
      ),
      PartType.brakeFluid: PartSpecConfig(
        partType: PartType.brakeFluid,
        intervalKm: 40000,
        intervalMonths: 24,
        lastServiceKm: 20500, // Overdue -> Red alert!
        lastServiceDate: now.subtract(const Duration(days: 710)),
        notes: 'Υγρά φρένων DOT 4 - Χρειάζεται αλλαγή άμεσα',
      ),
      PartType.sparkPlugs: PartSpecConfig(
        partType: PartType.sparkPlugs,
        intervalKm: 45000,
        intervalMonths: 48,
        lastServiceKm: 42000,
        lastServiceDate: now.subtract(const Duration(days: 400)),
        notes: 'Μπουζί Ιριδίου Denso',
      ),
      PartType.timingBelt: PartSpecConfig(
        partType: PartType.timingBelt,
        intervalKm: 90000,
        intervalMonths: 72,
        lastServiceKm: 0,
        lastServiceDate: DateTime(now.year - 4, 5, 10),
        notes: 'Καδένα χρονισμού (έλεγχος στα 90.000 χλμ)',
      ),
      PartType.battery: PartSpecConfig(
        partType: PartType.battery,
        intervalKm: 50000,
        intervalMonths: 48,
        lastServiceKm: 42000,
        lastServiceDate: now.subtract(const Duration(days: 400)),
        notes: 'Varta Silver Dynamic AGM 12V 45Ah',
      ),
      PartType.coolantAc: PartSpecConfig(
        partType: PartType.coolantAc,
        intervalKm: 50000,
        intervalMonths: 36,
        lastServiceKm: 50200,
        lastServiceDate: now.subtract(const Duration(days: 260)),
        notes: 'Πλήρωση φρέον R1234yf & καθαρισμός αεραγωγών',
      ),
      PartType.suspension: PartSpecConfig(
        partType: PartType.suspension,
        intervalKm: 75000,
        intervalMonths: 60,
        lastServiceKm: 0,
        lastServiceDate: DateTime(now.year - 4, 5, 10),
        notes: 'Εργοστασιακά αμορτισέρ KYB σε άριστη κατάσταση',
      ),
      PartType.transmissionClutch: PartSpecConfig(
        partType: PartType.transmissionClutch,
        intervalKm: 60000,
        intervalMonths: 48,
        lastServiceKm: 42000,
        lastServiceDate: now.subtract(const Duration(days: 400)),
        notes: 'Υγρά κιβωτίου e-CVT Toyota ATF WS',
      ),
    };

    final car1 = Vehicle(
      id: car1Id,
      type: VehicleType.car,
      make: 'Toyota',
      model: 'Yaris 1.5 Hybrid',
      year: 2022,
      licensePlate: 'ΙΖΜ-8492',
      vin: 'VNKKBAC320A194821',
      engineCode: 'M15A-FXE',
      engineCc: 1490,
      horsepower: 116,
      fuelType: FuelType.hybrid,
      colorName: 'Περλέ Λευκό / Μαύρη Οροφή',
      accentColorValue: 0xFF2563EB, // Electric Blue
      currentOdometerKm: baseKmCar,
      lastOdometerUpdate: lastOdoDateCar,
      averageMonthlyKm: 1100,
      oilSpec: '0W-20 API SP (3.6 Λίτρα)',
      tireDimension: '195/55 R16 87V',
      tirePressurePsi: '33 PSI Εμπρός / 32 PSI Πίσω',
      batterySpec: '12V 45Ah 360A Yuasa / Varta',
      wiperSize: '650mm Οδηγού / 400mm Συνοδηγού',
      partConfigs: carParts,
      isDemo: true,
    );

    // 2. Demo Motorcycle: Yamaha MT-07 (2023)
    final motoParts = <PartType, PartSpecConfig>{};
    for (final pt in PartType.values) {
      motoParts[pt] = PartSpecConfig(
        partType: pt,
        intervalKm: pt == PartType.engineOil ? 5000 : pt.defaultIntervalKm,
        intervalMonths: pt.defaultIntervalMonths,
        lastServiceKm: 12500,
        lastServiceDate: now.subtract(const Duration(days: 90)),
        notes: 'Πλήρες service εξουσιοδοτημένου συνεργείου Yamaha',
      );
    }

    final moto1 = Vehicle(
      id: moto1Id,
      type: VehicleType.motorcycle,
      make: 'Yamaha',
      model: 'MT-07 Pure',
      year: 2023,
      licensePlate: 'ΧΒΡ-491',
      vin: 'JYARM331000018294',
      engineCode: 'CP2-689',
      engineCc: 689,
      horsepower: 73,
      fuelType: FuelType.petrol,
      colorName: 'Icon Blue',
      accentColorValue: 0xFF0EA5E9,
      currentOdometerKm: 14200,
      lastOdometerUpdate: now.subtract(const Duration(days: 10)),
      averageMonthlyKm: 550,
      oilSpec: '10W-40 Yamalube Full Synthetic (2.6L)',
      tireDimension: '120/70 ZR17 & 180/55 ZR17',
      tirePressurePsi: '33 PSI Εμπρός / 36 PSI Πίσω',
      batterySpec: 'YTZ10S 12V 8.6Ah',
      wiperSize: 'Δεν εφαρμόζεται (Μοτοσυκλέτα)',
      partConfigs: motoParts,
      isDemo: true,
    );

    return [car1, moto1];
  }

  static List<ServiceEvent> buildDemoServices(DateTime now) {
    const car1Id = 'demo-car-yaris';
    const moto1Id = 'demo-moto-mt07';
    return [
      ServiceEvent(
        id: 'srv-1',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 260)),
        odometerKm: 50200,
        title: 'Τακτικό Service 50.000 χλμ & Συντήρηση A/C',
        servicedParts: [
          PartType.engineOil,
          PartType.airCabinFilter,
          PartType.tiresRotation,
          PartType.coolantAc,
        ],
        totalCost: 185.00,
        workshopName: 'AutoService Παπαδόπουλος (Toyota Specialist)',
        workshopPhone: '210 6849320',
        notes: 'Αλλαγή λαδιών 0W-20, φίλτρο λαδιού, φίλτρο αέρα & καμπίνας ενεργού άνθρακα, περιστροφή ελαστικών και έλεγχος υβριδικής μπαταρίας (OK).',
        receiptCodeOrRef: 'ΤΠΥ-2026-0482',
      ),
      ServiceEvent(
        id: 'srv-2',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 400)),
        odometerKm: 42000,
        title: 'Μεγάλο Service 40.000 χλμ (Μπουζί, Μπαταρία 12V, Βαλβολίνες)',
        servicedParts: [
          PartType.engineOil,
          PartType.sparkPlugs,
          PartType.battery,
          PartType.transmissionClutch,
        ],
        totalCost: 340.00,
        workshopName: 'AutoService Παπαδόπουλος (Toyota Specialist)',
        workshopPhone: '210 6849320',
        notes: 'Τοποθέτηση νέας μπαταρίας Varta 12V με 2 έτη εγγύηση, μπουζί ιριδίου Denso και υγρά κιβωτίου e-CVT.',
        receiptCodeOrRef: 'ΤΠΥ-2025-1190',
      ),
      ServiceEvent(
        id: 'srv-3',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 540)),
        odometerKm: 38000,
        title: 'Αλλαγή 4 Ελαστικών Michelin Primacy 4 & Ευθυγράμμιση',
        servicedParts: [
          PartType.tiresChange,
          PartType.tiresRotation,
        ],
        totalCost: 420.00,
        workshopName: 'Ελαστικά Καλογερόπουλος',
        workshopPhone: '210 5728100',
        notes: '4άδα Michelin Primacy 4 195/55 R16 87V, νέες βαλβίδες και ψηφιακή ευθυγράμμιση.',
        receiptCodeOrRef: 'ΑΠΥ-8831',
      ),
      ServiceEvent(
        id: 'srv-4',
        vehicleId: moto1Id,
        date: now.subtract(const Duration(days: 90)),
        odometerKm: 12500,
        title: 'Service 12.000 χλμ (Yamalube 10W-40 & Αλυσίδα)',
        servicedParts: [
          PartType.engineOil,
          PartType.airCabinFilter,
          PartType.brakeFluid,
        ],
        totalCost: 130.00,
        workshopName: 'MotoRacing Center Αθήνα',
        workshopPhone: '210 9234111',
        notes: 'Λάδια Yamalube, φίλτρο λαδιού, τέντωμα/λίπανση αλυσίδας και αλλαγή υγρών φρένων.',
        receiptCodeOrRef: 'ΑΠΥ-402',
      ),
    ];
  }

  static List<LegalReminder> buildDemoReminders(DateTime now) {
    const car1Id = 'demo-car-yaris';
    const moto1Id = 'demo-moto-mt07';
    return [
      LegalReminder(
        id: 'rem-kteo-1',
        vehicleId: car1Id,
        type: LegalObligationType.kteo,
        customTitle: 'Περιοδικός Έλεγχος ΚΤΕΟ',
        issueDate: now.subtract(const Duration(days: 718)),
        dueDate: now.add(const Duration(days: 12)), // Urgent: 12 days left!
        cost: 55.00,
        providerOrCenter: 'Autovision ΙΚΤΕΟ Αμαρουσίου',
        policyOrRefNumber: 'ΔΤΕ-9948120',
        emergencyPhone: '210 6100500',
        notes: 'Να έχω μαζί Άδεια Κυκλοφορίας και Ταυτότητα. Κλείσιμο ραντεβού τηλεφωνικά.',
      ),
      LegalReminder(
        id: 'rem-ins-1',
        vehicleId: car1Id,
        type: LegalObligationType.insurance,
        customTitle: 'Εξάμηνη Ασφάλεια Οχήματος & Οδική Βοήθεια',
        issueDate: now.subtract(const Duration(days: 150)),
        dueDate: now.add(const Duration(days: 32)),
        cost: 168.50,
        providerOrCenter: 'Anytime Interamerican (Πλήρης + Θραύση Κρυστάλλων)',
        policyOrRefNumber: 'ΣΥΜΒ-84729104',
        emergencyPhone: '1158',
        notes: 'Περιλαμβάνει 24ωρη Οδική Βοήθεια (1158) και Νομική Προστασία.',
      ),
      LegalReminder(
        id: 'rem-kek-1',
        vehicleId: car1Id,
        type: LegalObligationType.kek,
        customTitle: 'Κάρτα Ελέγχου Καυσαερίων (ΚΕΚ)',
        issueDate: now.subtract(const Duration(days: 353)),
        dueDate: now.add(const Duration(days: 12)),
        cost: 10.00,
        providerOrCenter: 'Autovision ΙΚΤΕΟ (βγαίνει μαζί με το ΚΤΕΟ)',
        policyOrRefNumber: 'ΚΕΚ-30291',
        notes: 'Ανανεώνεται κάθε χρόνο (θα βγει μαζί με το ΚΤΕΟ).',
      ),
      LegalReminder(
        id: 'rem-tax-1',
        vehicleId: car1Id,
        type: LegalObligationType.roadTax,
        customTitle: 'Τέλη Κυκλοφορίας (myCAR ΑΑΔΕ)',
        issueDate: DateTime(now.year, 11, 1),
        dueDate: DateTime(now.year, 12, 31),
        cost: 0.00,
        providerOrCenter: 'ΑΑΔΕ myCAR (Ελεύθερο λόγω χαμηλών ρύπων CO2 < 122g/km)',
        policyOrRefNumber: 'RF-ΑΠΑΛΛΑΓΗ-HYBRID',
        notes: 'Έλεγχος στο myCAR για εκτύπωση βεβαίωσης μη οφειλής τελών.',
      ),
      LegalReminder(
        id: 'rem-ins-moto',
        vehicleId: moto1Id,
        type: LegalObligationType.insurance,
        customTitle: 'Ετήσια Ασφάλεια Μηχανής',
        issueDate: now.subtract(const Duration(days: 200)),
        dueDate: now.add(const Duration(days: 165)),
        cost: 125.00,
        providerOrCenter: 'Hellas Direct (Βασική + Οδική Βοήθεια)',
        policyOrRefNumber: 'HD-MOTO-9921',
        emergencyPhone: '212 212 9999',
        notes: 'Καλύπτει ρυμούλκηση σε συνεργείο επιλογής.',
      ),
    ];
  }

  static List<FuelEntry> buildDemoFuelEntries(DateTime now) {
    const car1Id = 'demo-car-yaris';
    const moto1Id = 'demo-moto-mt07';
    return [
      FuelEntry(
        id: 'fuel-1',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 95)),
        odometerKm: 56200,
        liters: 31.0,
        pricePerLiter: 1.849,
        totalCost: 57.32,
        isFullTank: true,
        stationName: 'Shell (Λ. Κηφισίας)',
        notes: 'V-Power 95',
      ),
      FuelEntry(
        id: 'fuel-2',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 72)),
        odometerKm: 56920, // +720 km with 30.2 L -> 4.19 L/100km!
        liters: 30.2,
        pricePerLiter: 1.835,
        totalCost: 55.42,
        isFullTank: true,
        stationName: 'EKO (Χαλάνδρι)',
        notes: 'Κίνηση πόλης + Αττική Οδός',
      ),
      FuelEntry(
        id: 'fuel-3',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 50)),
        odometerKm: 57650, // +730 km with 31.4 L -> 4.30 L/100km!
        liters: 31.4,
        pricePerLiter: 1.860,
        totalCost: 58.40,
        isFullTank: true,
        stationName: 'BP (Μαρούσι)',
        notes: 'Ταξίδι Ναύπλιο με κλιματισμό',
      ),
      FuelEntry(
        id: 'fuel-4',
        vehicleId: car1Id,
        date: now.subtract(const Duration(days: 32)),
        odometerKm: 58400, // +750 km with 31.5 L -> 4.20 L/100km!
        liters: 31.5,
        pricePerLiter: 1.820,
        totalCost: 57.33,
        isFullTank: true,
        stationName: 'Shell (Λ. Κηφισίας)',
        notes: 'Αμόλυβδη 95 FuelSave',
      ),
      FuelEntry(
        id: 'fuel-moto-1',
        vehicleId: moto1Id,
        date: now.subtract(const Duration(days: 28)),
        odometerKm: 13950,
        liters: 11.2,
        pricePerLiter: 1.850,
        totalCost: 20.72,
        isFullTank: true,
        stationName: 'Avin',
      ),
      FuelEntry(
        id: 'fuel-moto-2',
        vehicleId: moto1Id,
        date: now.subtract(const Duration(days: 10)),
        odometerKm: 14200, // +250 km with 11.5 L -> 4.60 L/100km!
        liters: 11.5,
        pricePerLiter: 1.840,
        totalCost: 21.16,
        isFullTank: true,
        stationName: 'Shell',
      ),
    ];
  }
}
