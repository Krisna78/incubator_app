import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import 'package:incubator_app/model/incubator.dart';
import 'package:incubator_app/controller/database_helper.dart';

class IncubatorController extends GetxController {
  // Data incubator
  var incubators = <Incubator>[].obs;
  var chartData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> telurKeluarHariIni =
      <Map<String, dynamic>>[].obs;

  // Sensor
  var suhu = 0.0.obs;
  var kelembapan = 0.0.obs;
  RxBool motorStatus = false.obs;
  RxBool pumpStatus = false.obs;

  // Untuk chart suhu dan kelembapan per 2 menit
  RxList<FlSpot> suhuSpots = <FlSpot>[].obs;
  RxList<FlSpot> kelembapanSpots = <FlSpot>[].obs;
  RxList<String> waktuLabels = <String>[].obs;

  // Timer
  late final Timer chartTimer;

  // Firebase Database URL & secret
  final String databaseUrl =
      'https://inkubator-68586-default-rtdb.firebaseio.com/';
  final String secret = 'dsekLDKKqzb3oTH23VwNM9paygBDeCD0jwfcP3Ub';

  @override
  void onInit() {
    super.onInit();
    loadAllIncubators();
    loadChartData();
    loadSensorData();
    cekTelurKeluarHariIni();

    ever(suhu, (_) => print('Suhu: $suhu'));
    ever(kelembapan, (_) => print('Kelembapan: $kelembapan'));

    _startSensorDataTimer();
    _startChartDataTimer();
  }

  @override
  void onClose() {
    chartTimer.cancel();
    super.onClose();
  }

  void _startSensorDataTimer() {
    Future.doWhile(() async {
      await loadSensorData();
      await Future.delayed(Duration(seconds: 3));
      return true;
    });
  }

  void _startChartDataTimer() {
    chartTimer = Timer.periodic(Duration(minutes: 2), (timer) async {
      await loadSensorData();
      addSensorToChart();
    });
  }

  void addSensorToChart() {
    final now = DateTime.now();
    final waktu =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Tambah data mentah terlebih dahulu
    final newSuhu = suhu.value;
    final newKelembapan = kelembapan.value;

    // Tambah data baru
    suhuSpots.add(FlSpot(0, newSuhu)); // x diatur ulang nanti
    kelembapanSpots.add(FlSpot(0, newKelembapan));
    waktuLabels.add(waktu);

    // Hapus jika lebih dari 10
    if (suhuSpots.length > 10) {
      suhuSpots.removeAt(0);
      kelembapanSpots.removeAt(0);
      waktuLabels.removeAt(0);
    }

    // Perbarui kembali X agar mulai dari 0
    for (int i = 0; i < suhuSpots.length; i++) {
      suhuSpots[i] = FlSpot(i.toDouble(), suhuSpots[i].y);
      kelembapanSpots[i] = FlSpot(i.toDouble(), kelembapanSpots[i].y);
    }
  }

  void cekTelurKeluarHariIni() {
    final DateTime now = DateTime.now();

    telurKeluarHariIni.value = incubators
        .where((data) {
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
        })
        .map((e) => {
              "kode": e.kode,
              "tanggal_keluar": e.tanggal_keluar,
              "jumlah_telur": e.jumlah_telur
            })
        .toList();
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

  Future<void> addIncubator(Incubator incubator) async {
    await DatabaseHelper.instance.insertIncubator(incubator);
    await loadAllIncubators();
  }

  Future<void> updateIncubator(Incubator incubator) async {
    await DatabaseHelper.instance.updateIncubator(incubator);
    await loadAllIncubators();
  }

  Future<void> deleteIncubator(int id) async {
    await DatabaseHelper.instance.deleteIncubator(id);
    await loadAllIncubators();
  }

  Future<void> loadAllIncubators() async {
    final data = await DatabaseHelper.instance.getAllIncubators();
    incubators.assignAll(data);
  }

  Future<Incubator?> getIncubatorById(int id) async {
    return await DatabaseHelper.instance.fetchIncubatorById(id);
  }

  Future<void> loadChartData() async {
    final data = await DatabaseHelper.instance.getGroupedTelurData();
    chartData.assignAll(data);
  }

  Future<void> fetchMotorStatus() async {
    try {
      final url = Uri.parse('${databaseUrl}sensor/motorStatus.json?auth=$secret');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final status = json.decode(response.body);
        motorStatus.value = (status == 'ON');
      } else {
        print('Gagal mengambil motorStatus');
      }
    } catch (e) {
      print('Error mengambil motorStatus: $e');
    }
  }

  Future<void> updateMotorStatus(bool value) async {
    final status = value ? 'ON' : 'OFF';
    final url = Uri.parse('${databaseUrl}sensor/motorStatus.json?auth=$secret');

    try {
      final response = await http.put(
        url,
        body: json.encode(status),
      );

      if (response.statusCode == 200) {
        motorStatus.value = value;
      } else {
        print('Gagal mengubah motorStatus');
      }
    } catch (e) {
      print('Error mengubah motorStatus: $e');
    }
  }

  Future<void> fetchPompaStatus() async {
    try {
      final url = Uri.parse('${databaseUrl}sensor/pumpStatus.json?auth=$secret');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final status = json.decode(response.body);
        pumpStatus.value = (status == 'ON');
      } else {
        print('Gagal mengambil pumpStatus');
      }
    } catch (e) {
      print('Error mengambil pumpStatus: $e');
    }
  }

  Future<void> updatePompaStatus(bool value) async {
    final status = value ? 'ON' : 'OFF';
    final url = Uri.parse('${databaseUrl}sensor/pumpStatus.json?auth=$secret');

    try {
      final response = await http.put(
        url,
        body: json.encode(status),
      );

      if (response.statusCode == 200) {
        pumpStatus.value = value;
      } else {
        print('Gagal mengubah pumpStatus');
      }
    } catch (e) {
      print('Error mengubah pumpStatus: $e');
    }
  }
}
