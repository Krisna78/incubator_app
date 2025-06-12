import 'dart:convert';

import 'package:get/get.dart';
import 'package:incubator_app/model/incubator.dart';
import 'package:incubator_app/controller/database_helper.dart';
import 'package:http/http.dart' as http;

class IncubatorController extends GetxController {
  var incubators = <Incubator>[].obs;
  var chartData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> telurKeluarHariIni = <Map<String, dynamic>>[].obs;

  var suhu = 0.0.obs;
  var kelembapan = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllIncubators();
    loadChartData();
    loadSensorData();
    ever(suhu, (_) => print('$suhu'));
    ever(kelembapan, (_) => print('$kelembapan'));
    _startSensorDataTimer();
  }

  void cekTelurKeluarHariIni() {
    final DateTime now = DateTime.now();

    telurKeluarHariIni.value = incubators.where((data) {
      try {
        final keluarStr = data.tanggal_keluar;
        if (keluarStr == null || keluarStr.isEmpty) return false;

        final keluarDate = DateTime.parse(keluarStr);
        return keluarDate.year == now.year &&
            keluarDate.month == now.month &&
            keluarDate.day == now.day &&
            (data.jumlah_telur! > 0);
      } catch (_) {
        return false;
      }
    }).map((e) => {
      "kode": e.kode,
      "tanggal_keluar": e.tanggal_keluar,
      "jumlah_telur": e.jumlah_telur
    }).toList();
  }

  void _startSensorDataTimer() {
  Future.doWhile(() async {
    await loadSensorData();
    await Future.delayed(Duration(seconds: 3));
    return true;
  });
}

  final String databaseUrl = 'https://inkubator-68586-default-rtdb.firebaseio.com/';
  final String secret = 'dsekLDKKqzb3oTH23VwNM9paygBDeCD0jwfcP3Ub';

  // Tambah data
  Future<void> addIncubator(Incubator incubator) async {
    await DatabaseHelper.instance.insertIncubator(incubator);
    await loadAllIncubators();
  }

  // Update data
  Future<void> updateIncubator(Incubator incubator) async {
    await DatabaseHelper.instance.updateIncubator(incubator);
    await loadAllIncubators();
  }

  // Hapus data
  Future<void> deleteIncubator(int id) async {
    await DatabaseHelper.instance.deleteIncubator(id);
    await loadAllIncubators();
  }

  // Ambil semua data
  Future<void> loadAllIncubators() async {
    final data = await DatabaseHelper.instance.getAllIncubators();
    incubators.assignAll(data);
  }

  // Ambil berdasarkan ID
  Future<Incubator?> getIncubatorById(int id) async {
    return await DatabaseHelper.instance.fetchIncubatorById(id);
  }

  Future<void> loadChartData() async {
    final data = await DatabaseHelper.instance.getGroupedTelurData();
    chartData.assignAll(data);
  }

  Future<void> loadSensorData() async {
    final url = Uri.parse('${databaseUrl}sensor.json?auth=$secret');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      suhu.value = data['suhu']?.toDouble() ?? 0.0;
      kelembapan.value = data['kelembapan']?.toDouble() ?? 0.0;
    }
  }
}
