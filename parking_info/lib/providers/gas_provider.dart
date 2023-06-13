import 'package:flutter/material.dart';
import 'package:parking_info/services/api.dart';

class GasController extends ChangeNotifier {
  final ApiService apiService;
  GasController(this.apiService);

  Gas _lastGas = Gas(DateTime.now().subtract(const Duration(days: 1)));
  DateTime get lastGasTimestamp => _lastGas.timestamp;

  List<Gas> _gas = [];
  List<Gas> get gas => _gas;

  Future<void> fetchGas() async {
    _gas = await apiService.getGas();
    notifyListeners();
  }

  Future<void> fetchLastGas() async {
    _lastGas = await apiService.getLastGasExceed();
    notifyListeners();
  }
}

class Gas {
  final DateTime timestamp;

  Gas(this.timestamp);

  Gas.fromJson(Map<String, dynamic> json)
      : timestamp = DateTime.parse(json['timestamp']);

  static List<Gas> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Gas.fromJson(json)).toList();
  }
}
