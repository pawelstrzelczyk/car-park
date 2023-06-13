import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:parking_info/providers/entries_provider.dart';
import 'package:parking_info/providers/gas_provider.dart';

class ApiService {
  late Dio dioClient;
  static final ApiService apiService = ApiService._();
  ApiService._() {
    dioClient = Dio(baseOptions);
    (dioClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  static ApiService getInstance() {
    return apiService;
  }

  BaseOptions baseOptions = BaseOptions(
    baseUrl: "https://192.168.1.171:5000",
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 5000),
    sendTimeout: const Duration(milliseconds: 5000),
  );

  Future<List<Gas>> getGas() async {
    Response response = await dioClient.get("/gas-alerts");
    return Gas.fromJsonList(response.data);
  }

  Future<Gas> getLastGasExceed() async {
    Response response = await dioClient.get("/gas-alerts/last");
    return Gas.fromJson(response.data);
  }

  Future<List<Entry>> getEntries() async {
    Response response = await dioClient.get("/entries");
    return Entry.fromJsonList(response.data);
  }

  Future<List<Entry>> getCurrentVehicles() async {
    Response response = await dioClient.get("/entries/current");
    return Entry.fromJsonList(response.data);
  }

  Future<int> getCurrentVehicleNumber() async {
    Response response = await dioClient.get("/entries/current/count");
    return response.data['occupied'];
  }

  Future<int> getTotalVehicleNumber() async {
    Response response = await dioClient.get("/entries/total");
    return response.data['total_entries'];
  }

  Future<int> getUniqueVehicleNumber() async {
    Response response = await dioClient.get("/entries/unique");
    return response.data['unique_entries'];
  }

  Future<double> getFeesSum() async {
    Response response = await dioClient.get("/entries/fees/sum");
    return response.data['fees_sum'];
  }
}
