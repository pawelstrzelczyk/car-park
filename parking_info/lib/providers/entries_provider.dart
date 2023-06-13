import 'package:flutter/material.dart';
import 'package:parking_info/services/api.dart';

class EntriesController extends ChangeNotifier {
  final ApiService apiService;
  EntriesController(this.apiService);

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;

  List<Entry> _currentVehicles = [];
  List<Entry> get currentVehicles => _currentVehicles;

  int _currentVehicleNumber = 0;
  int get currentVehicleNumber => _currentVehicleNumber;

  int _totalVehicleNumber = 0;
  int get totalVehicleNumber => _totalVehicleNumber;

  int _uniqueLicensePlates = 0;
  int get uniqueLicensePlates => _uniqueLicensePlates;

  double _feesSum = 0;
  double get feesSum => _feesSum;

  Future<void> fetchEntries() async {
    _entries = await apiService.getEntries();
    notifyListeners();
  }

  Future<void> fetchCurrentVehicles() async {
    _currentVehicles = await apiService.getCurrentVehicles();
    notifyListeners();
  }

  Future<void> fetchCurrentVehicleNumber() async {
    _currentVehicleNumber = await apiService.getCurrentVehicleNumber();
    notifyListeners();
  }

  Future<void> fetchTotalVehicleNumber() async {
    _totalVehicleNumber = await apiService.getTotalVehicleNumber();
    notifyListeners();
  }

  Future<void> fetchUniqueLicensePlates() async {
    _uniqueLicensePlates = await apiService.getUniqueVehicleNumber();
    notifyListeners();
  }

  Future<void> fetchFeesSum() async {
    _feesSum = await apiService.getFeesSum();
    notifyListeners();
  }

  Future<void> fetchAll() async {
    await fetchCurrentVehicleNumber();
    await fetchTotalVehicleNumber();
    await fetchUniqueLicensePlates();
    await fetchFeesSum();
  }
}

class Entry {
  final DateTime entryTimestamp;
  final DateTime exitTimestamp;
  final String licensePlate;
  final double fee;
  final bool paid;

  Entry(this.entryTimestamp, this.exitTimestamp, this.licensePlate, this.fee,
      this.paid);

  Entry.fromJson(Map<String, dynamic> json)
      : entryTimestamp = DateTime.parse(json['entry_timestamp']),
        exitTimestamp = json['exit_timestamp'] == 0
            ? DateTime.fromMicrosecondsSinceEpoch(0)
            : DateTime.parse(json['exit_timestamp']),
        licensePlate = json['license_plate_number'],
        fee = json['fee'],
        paid = json['paid'] == 1 ? true : false;

  static List<Entry> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Entry.fromJson(json)).toList();
  }
}
