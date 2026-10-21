import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/caraki_models.dart';
import 'demo_seed_data.dart';

/// Abstract interface for Hybrid Offline-First / Cloud-Ready Repository
abstract class CarakiDataRepository {
  Future<List<Vehicle>> loadVehicles();
  Future<void> saveVehicles(List<Vehicle> vehicles);

  Future<List<ServiceEvent>> loadServiceEvents();
  Future<void> saveServiceEvents(List<ServiceEvent> events);

  Future<List<LegalReminder>> loadLegalReminders();
  Future<void> saveLegalReminders(List<LegalReminder> reminders);

  Future<List<FuelEntry>> loadFuelEntries();
  Future<void> saveFuelEntries(List<FuelEntry> entries);

  Future<ThemeMode> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);

  Future<String> exportFullBackupJson();
  Future<void> importFullBackupJson(String jsonString);
  Future<void> resetToDemoData();
  Future<void> clearAllData();
}

/// Offline-first implementation backed by SharedPreferences (ready to sync with Cloud later)
class LocalCarakiRepository implements CarakiDataRepository {
  static const _kInitializedKey = 'caraki_initialized_v1';
  static const _kVehiclesKey = 'caraki_vehicles_v1';
  static const _kServicesKey = 'caraki_services_v1';
  static const _kRemindersKey = 'caraki_reminders_v1';
  static const _kFuelKey = 'caraki_fuel_v1';
  static const _kThemeKey = 'caraki_theme_v1';

  final SharedPreferences _prefs;

  LocalCarakiRepository(this._prefs);

  Future<void> ensureInitialized() async {
    final initialized = _prefs.getBool(_kInitializedKey) ?? false;
    if (!initialized) {
      await resetToDemoData();
      await _prefs.setBool(_kInitializedKey, true);
    }
  }

  @override
  Future<List<Vehicle>> loadVehicles() async {
    await ensureInitialized();
    final raw = _prefs.getString(_kVehiclesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final encoded = jsonEncode(vehicles.map((e) => e.toJson()).toList());
    await _prefs.setString(_kVehiclesKey, encoded);
  }

  @override
  Future<List<ServiceEvent>> loadServiceEvents() async {
    await ensureInitialized();
    final raw = _prefs.getString(_kServicesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final events = list.map((e) => ServiceEvent.fromJson(e as Map<String, dynamic>)).toList();
    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  @override
  Future<void> saveServiceEvents(List<ServiceEvent> events) async {
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString(_kServicesKey, encoded);
  }

  @override
  Future<List<LegalReminder>> loadLegalReminders() async {
    await ensureInitialized();
    final raw = _prefs.getString(_kRemindersKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final reminders = list.map((e) => LegalReminder.fromJson(e as Map<String, dynamic>)).toList();
    reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return reminders;
  }

  @override
  Future<void> saveLegalReminders(List<LegalReminder> reminders) async {
    final encoded = jsonEncode(reminders.map((e) => e.toJson()).toList());
    await _prefs.setString(_kRemindersKey, encoded);
  }

  @override
  Future<List<FuelEntry>> loadFuelEntries() async {
    await ensureInitialized();
    final raw = _prefs.getString(_kFuelKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list.map((e) => FuelEntry.fromJson(e as Map<String, dynamic>)).toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Future<void> saveFuelEntries(List<FuelEntry> entries) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_kFuelKey, encoded);
  }

  @override
  Future<ThemeMode> loadThemeMode() async {
    final val = _prefs.getString(_kThemeKey) ?? 'dark';
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeKey, mode.name);
  }

  @override
  Future<String> exportFullBackupJson() async {
    final vehicles = await loadVehicles();
    final services = await loadServiceEvents();
    final reminders = await loadLegalReminders();
    final fuel = await loadFuelEntries();

    final payload = {
      'app': 'Caraki',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
      'serviceEvents': services.map((s) => s.toJson()).toList(),
      'legalReminders': reminders.map((r) => r.toJson()).toList(),
      'fuelEntries': fuel.map((f) => f.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  @override
  Future<void> importFullBackupJson(String jsonString) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final vList = (decoded['vehicles'] as List<dynamic>? ?? [])
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
    final sList = (decoded['serviceEvents'] as List<dynamic>? ?? [])
        .map((e) => ServiceEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    final rList = (decoded['legalReminders'] as List<dynamic>? ?? [])
        .map((e) => LegalReminder.fromJson(e as Map<String, dynamic>))
        .toList();
    final fList = (decoded['fuelEntries'] as List<dynamic>? ?? [])
        .map((e) => FuelEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    await saveVehicles(vList);
    await saveServiceEvents(sList);
    await saveLegalReminders(rList);
    await saveFuelEntries(fList);
    await _prefs.setBool(_kInitializedKey, true);
  }

  @override
  Future<void> resetToDemoData() async {
    final now = DateTime.now();
    await saveVehicles(DemoSeedData.buildDemoVehicles(now));
    await saveServiceEvents(DemoSeedData.buildDemoServices(now));
    await saveLegalReminders(DemoSeedData.buildDemoReminders(now));
    await saveFuelEntries(DemoSeedData.buildDemoFuelEntries(now));
    await _prefs.setBool(_kInitializedKey, true);
  }

  @override
  Future<void> clearAllData() async {
    await saveVehicles([]);
    await saveServiceEvents([]);
    await saveLegalReminders([]);
    await saveFuelEntries([]);
    await _prefs.setBool(_kInitializedKey, true);
  }
}

class CarakiState extends ChangeNotifier {
  final CarakiDataRepository _repo;

  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  List<ServiceEvent> _serviceEvents = [];
  List<LegalReminder> _legalReminders = [];
  List<FuelEntry> _fuelEntries = [];
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoading = true;

  CarakiState(this._repo);

  bool get isLoading => _isLoading;
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  ThemeMode get themeMode => _themeMode;

  Vehicle? get selectedVehicle {
    if (_vehicles.isEmpty) return null;
    return _vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => _vehicles.first,
    );
  }

  List<ServiceEvent> get currentVehicleServices {
    final v = selectedVehicle;
    if (v == null) return [];
    final list = _serviceEvents.where((e) => e.vehicleId == v.id).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<LegalReminder> get currentVehicleReminders {
    final v = selectedVehicle;
    if (v == null) return [];
    final list = _legalReminders.where((r) => r.vehicleId == v.id).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  List<FuelEntry> get currentVehicleFuelEntries {
    final v = selectedVehicle;
    if (v == null) return [];
    final list = _fuelEntries.where((f) => f.vehicleId == v.id).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _themeMode = await _repo.loadThemeMode();
    _vehicles = await _repo.loadVehicles();
    _serviceEvents = await _repo.loadServiceEvents();
    _legalReminders = await _repo.loadLegalReminders();
    _fuelEntries = await _repo.loadFuelEntries();

    if (_vehicles.isNotEmpty) {
      _selectedVehicleId = _vehicles.first.id;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectVehicle(String vehicleId) {
    _selectedVehicleId = vehicleId;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repo.saveThemeMode(mode);
    notifyListeners();
  }

  /// Quick 1-click odometer update (also recalculates monthly average if desirable)
  Future<void> updateOdometer(String vehicleId, int newOdometerKm, {int? newMonthlyAvgKm}) async {
    final idx = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (idx == -1) return;
    final current = _vehicles[idx];
    _vehicles[idx] = current.copyWith(
      currentOdometerKm: newOdometerKm,
      lastOdometerUpdate: DateTime.now(),
      averageMonthlyKm: newMonthlyAvgKm ?? current.averageMonthlyKm,
    );
    await _repo.saveVehicles(_vehicles);
    notifyListeners();
  }

  Future<void> addOrUpdateVehicle(Vehicle vehicle) async {
    final idx = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (idx >= 0) {
      _vehicles[idx] = vehicle;
    } else {
      _vehicles.add(vehicle);
      _selectedVehicleId = vehicle.id;

      // Automatically create default Greek reminders for a newly added vehicle
      final now = DateTime.now();
      final defaultReminders = [
        LegalReminder(
          id: 'rem-kteo-${vehicle.id}',
          vehicleId: vehicle.id,
          type: LegalObligationType.kteo,
          customTitle: 'Περιοδικός Έλεγχος ΚΤΕΟ',
          issueDate: now,
          dueDate: DateTime(now.year + 2, now.month, now.day),
          cost: 55.0,
          providerOrCenter: 'ΙΚΤΕΟ',
          notes: 'Υπενθύμιση ΚΤΕΟ ανά 2 έτη',
        ),
        LegalReminder(
          id: 'rem-ins-${vehicle.id}',
          vehicleId: vehicle.id,
          type: LegalObligationType.insurance,
          customTitle: 'Ασφάλεια Οχήματος',
          issueDate: now,
          dueDate: DateTime(now.year, now.month + 6, now.day),
          cost: 150.0,
          providerOrCenter: 'Ασφαλιστική Εταιρεία',
          notes: 'Ανανέωση ασφαλιστηρίου συμβολαίου',
        ),
        LegalReminder(
          id: 'rem-kek-${vehicle.id}',
          vehicleId: vehicle.id,
          type: LegalObligationType.kek,
          customTitle: 'Κάρτα Ελέγχου Καυσαερίων (ΚΕΚ)',
          issueDate: now,
          dueDate: DateTime(now.year + 1, now.month, now.day),
          cost: 10.0,
          providerOrCenter: 'Συνεργείο / ΚΤΕΟ',
        ),
        LegalReminder(
          id: 'rem-tax-${vehicle.id}',
          vehicleId: vehicle.id,
          type: LegalObligationType.roadTax,
          customTitle: 'Τέλη Κυκλοφορίας (${now.year})',
          issueDate: DateTime(now.year, 11, 1),
          dueDate: DateTime(now.year, 12, 31),
          cost: 135.0,
          providerOrCenter: 'ΑΑΔΕ myCAR',
        ),
      ];
      _legalReminders.addAll(defaultReminders);
      await _repo.saveLegalReminders(_legalReminders);
    }
    await _repo.saveVehicles(_vehicles);
    notifyListeners();
  }

  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((v) => v.id == vehicleId);
    _serviceEvents.removeWhere((s) => s.vehicleId == vehicleId);
    _legalReminders.removeWhere((r) => r.vehicleId == vehicleId);
    _fuelEntries.removeWhere((f) => f.vehicleId == vehicleId);

    if (_selectedVehicleId == vehicleId) {
      _selectedVehicleId = _vehicles.isNotEmpty ? _vehicles.first.id : null;
    }

    await _repo.saveVehicles(_vehicles);
    await _repo.saveServiceEvents(_serviceEvents);
    await _repo.saveLegalReminders(_legalReminders);
    await _repo.saveFuelEntries(_fuelEntries);
    notifyListeners();
  }

  /// Adds a unified ServiceEvent and automatically resets/updates each serviced PartSpecConfig!
  Future<void> addServiceEvent(ServiceEvent event) async {
    _serviceEvents.insert(0, event);
    await _repo.saveServiceEvents(_serviceEvents);

    // Also update vehicle odometer if higher & update serviced parts' lastServiceKm and lastServiceDate
    final vIdx = _vehicles.indexWhere((v) => v.id == event.vehicleId);
    if (vIdx >= 0) {
      final v = _vehicles[vIdx];
      final updatedConfigs = Map<PartType, PartSpecConfig>.from(v.partConfigs);

      for (final pt in event.servicedParts) {
        final existing = updatedConfigs[pt] ??
            PartSpecConfig(
              partType: pt,
              intervalKm: pt.defaultIntervalKm,
              intervalMonths: pt.defaultIntervalMonths,
              lastServiceKm: event.odometerKm,
              lastServiceDate: event.date,
            );
        // Only update if this service event is newer or higher km than previous record
        if (event.odometerKm >= existing.lastServiceKm ||
            event.date.isAfter(existing.lastServiceDate)) {
          updatedConfigs[pt] = existing.copyWith(
            lastServiceKm: event.odometerKm,
            lastServiceDate: event.date,
            notes: event.workshopName.isNotEmpty
                ? '${event.title} (${event.workshopName})'
                : event.title,
          );
        }
      }

      final newOdo = event.odometerKm > v.currentOdometerKm
          ? event.odometerKm
          : v.currentOdometerKm;

      _vehicles[vIdx] = v.copyWith(
        currentOdometerKm: newOdo,
        lastOdometerUpdate: event.odometerKm >= v.currentOdometerKm
            ? DateTime.now()
            : v.lastOdometerUpdate,
        partConfigs: updatedConfigs,
      );
      await _repo.saveVehicles(_vehicles);
    }

    notifyListeners();
  }

  Future<void> deleteServiceEvent(String eventId) async {
    _serviceEvents.removeWhere((e) => e.id == eventId);
    await _repo.saveServiceEvents(_serviceEvents);
    notifyListeners();
  }

  Future<void> updatePartConfig(String vehicleId, PartSpecConfig newConfig) async {
    final vIdx = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (vIdx == -1) return;
    final v = _vehicles[vIdx];
    final updated = Map<PartType, PartSpecConfig>.from(v.partConfigs);
    updated[newConfig.partType] = newConfig;
    _vehicles[vIdx] = v.copyWith(partConfigs: updated);
    await _repo.saveVehicles(_vehicles);
    notifyListeners();
  }

  Future<void> addOrUpdateReminder(LegalReminder reminder) async {
    final idx = _legalReminders.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      _legalReminders[idx] = reminder;
    } else {
      _legalReminders.add(reminder);
    }
    await _repo.saveLegalReminders(_legalReminders);
    notifyListeners();
  }

  /// Renews a legal obligation (e.g. KTEO +2 years, KEK +1 year, Insurance +6/12 months)
  Future<void> renewReminder(LegalReminder reminder, {int addMonths = 12, double? newCost}) async {
    final now = DateTime.now();
    final baseDate = reminder.dueDate.isAfter(now) ? reminder.dueDate : now;
    final nextDue = DateTime(baseDate.year, baseDate.month + addMonths, baseDate.day);
    final updated = reminder.copyWith(
      issueDate: now,
      dueDate: nextDue,
      cost: newCost ?? reminder.cost,
    );
    await addOrUpdateReminder(updated);
  }

  Future<void> deleteReminder(String reminderId) async {
    _legalReminders.removeWhere((r) => r.id == reminderId);
    await _repo.saveLegalReminders(_legalReminders);
    notifyListeners();
  }

  Future<void> addFuelEntry(FuelEntry entry) async {
    _fuelEntries.insert(0, entry);
    await _repo.saveFuelEntries(_fuelEntries);

    // Automatically update vehicle odometer if the fuel entry has a higher reading!
    final vIdx = _vehicles.indexWhere((v) => v.id == entry.vehicleId);
    if (vIdx >= 0) {
      final v = _vehicles[vIdx];
      if (entry.odometerKm > v.currentOdometerKm) {
        _vehicles[vIdx] = v.copyWith(
          currentOdometerKm: entry.odometerKm,
          lastOdometerUpdate: DateTime.now(),
        );
        await _repo.saveVehicles(_vehicles);
      }
    }
    notifyListeners();
  }

  Future<void> deleteFuelEntry(String entryId) async {
    _fuelEntries.removeWhere((f) => f.id == entryId);
    await _repo.saveFuelEntries(_fuelEntries);
    notifyListeners();
  }

  /// Calculates average fuel consumption (L/100km) for the selected vehicle
  double? get averageConsumptionLPer100Km {
    final entries = List<FuelEntry>.from(currentVehicleFuelEntries);
    if (entries.length < 2) return null;
    entries.sort((a, b) => a.odometerKm.compareTo(b.odometerKm));

    final minKm = entries.first.odometerKm;
    final maxKm = entries.last.odometerKm;
    final distance = maxKm - minKm;
    if (distance <= 0) return null;

    // Sum liters of all entries except the very first baseline fill-up
    double totalLiters = 0;
    for (int i = 1; i < entries.length; i++) {
      totalLiters += entries[i].liters;
    }
    return (totalLiters / distance) * 100.0;
  }

  double get totalFuelCostForSelected {
    return currentVehicleFuelEntries.fold(0.0, (sum, e) => sum + e.totalCost);
  }

  double get totalServiceCostForSelected {
    return currentVehicleServices.fold(0.0, (sum, e) => sum + e.totalCost);
  }

  double get totalLegalCostForSelected {
    return currentVehicleReminders.fold(0.0, (sum, r) => sum + r.cost);
  }

  Future<String> exportBackup() => _repo.exportFullBackupJson();

  Future<void> importBackup(String jsonStr) async {
    await _repo.importFullBackupJson(jsonStr);
    await initialize();
  }

  Future<void> resetDemoData() async {
    await _repo.resetToDemoData();
    await initialize();
  }

  Future<void> clearAllData() async {
    await _repo.clearAllData();
    await initialize();
  }
}
