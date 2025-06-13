import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:incubator_app/controller/incubatorController.dart';

class Beranda extends StatefulWidget {
  Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final IncubatorController incubatorController =
      Get.put(IncubatorController());
  List<FlSpot> masukSpots = [];
  List<FlSpot> keluarSpots = [];
  List<String> tanggalLabels = [];

  void prosesData(List<Map<String, dynamic>> data) {
    masukSpots.clear();
    keluarSpots.clear();
    tanggalLabels.clear();

    final recentData = data.length <= 7 ? data : data.sublist(data.length - 7);

    for (int i = 0; i < recentData.length; i++) {
      final row = recentData[i];
      final tgl = row['tanggal'];
      final masuk = row['masuk'];
      final keluar = row['keluar'];

      masukSpots.add(FlSpot(i.toDouble(), masuk.toDouble()));
      keluarSpots.add(FlSpot(i.toDouble(), keluar.toDouble()));
      tanggalLabels.add(tgl);
    }
  }

  double _getMaxY() {
    double maxMasuk = masukSpots.isEmpty
        ? 0
        : masukSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double maxKeluar = keluarSpots.isEmpty
        ? 0
        : keluarSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double max = maxMasuk > maxKeluar ? maxMasuk : maxKeluar;

    double adjusted = (max * 1.2).ceilToDouble();
    return (adjusted / 20).ceil() * 20;
  }

  double _getIntervalY(double maxY) {
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 200) return 40;
    return 50;
  }

  @override
  void initState() {
    super.initState();
    incubatorController.loadChartData().then((_) {
      setState(() {
        prosesData(incubatorController.chartData);
      });
    });
    incubatorController.loadAllIncubators().then((_) {
      incubatorController.cekTelurKeluarHariIni();
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxY = _getMaxY();
    double intervalY = _getIntervalY(maxY);

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 65),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Selamat Datang",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(width: 8),
                    Obx(() {
                      int notifCount =
                          incubatorController.telurKeluarHariIni.length;
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications,
                                size: 32, color: Color(0xFF00A1FF)),
                            onPressed: () {
                              final telurHariIni =
                                  incubatorController.telurKeluarHariIni;

                              if (telurHariIni.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Notifikasi"),
                                    content: const Text(
                                        "Tidak ada telur keluar hari ini."),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Tutup"),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Telur Keluar Hari Ini"),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: telurHariIni.length,
                                        itemBuilder: (context, index) {
                                          final item = telurHariIni[index];
                                          return ListTile(
                                            leading: const Icon(Icons.egg,
                                                color: Colors.orangeAccent),
                                            title:
                                                Text("Kode: ${item['kode']}"),
                                            subtitle: Text(
                                                "Jumlah: ${item['jumlah_telur']} telur"),
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Tutup"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          if (notifCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$notifCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => InfoCard(
                          title: "Suhu",
                          icon: Icons.thermostat_outlined,
                          value:
                              "${incubatorController.suhu.value.toStringAsFixed(1)}℃"),
                    ),
                    const SizedBox(width: 15),
                    Obx(
                      () => InfoCard(
                          title: "Kelembapan",
                          icon: Icons.water_drop_outlined,
                          value:
                              "${incubatorController.kelembapan.value.toStringAsFixed(1)}%"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "History Telur Incubator",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                if (masukSpots.isEmpty && keluarSpots.isEmpty)
                  Center(
                    heightFactor: 5,
                    child: Text("Data Telur Tidak ada",
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF737373))),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: AspectRatio(
                        aspectRatio: 1.7,
                        child: LineChart(
                          LineChartData(
                            gridData:
                                FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: intervalY,
                                  getTitlesWidget: (value, _) =>
                                      Text(value.toInt().toString()),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 1,
                                  getTitlesWidget: (value, _) {
                                    int index = value.toInt();
                                    if (index >= 0 &&
                                        index < tanggalLabels.length) {
                                      String tanggal = tanggalLabels[index];
                                      return Text(
                                        tanggal.length >= 10
                                            ? tanggal.substring(5, 10)
                                            : tanggal,
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            minX: 0,
                            maxX: (tanggalLabels.length - 1).toDouble(),
                            minY: 0,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: masukSpots,
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                              LineChartBarData(
                                spots: keluarSpots,
                                isCurved: true,
                                color: Colors.red,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ==== Grafik Suhu & Kelembapan ====
                const SizedBox(height: 20),
                const Text(
                  "Grafik Suhu & Kelembapan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (incubatorController.suhuSpots.isEmpty ||
                      incubatorController.kelembapanSpots.isEmpty) {
                    return Center(
                      heightFactor: 3,
                      child: Text("Belum ada data suhu & kelembapan.",
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF737373))),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: AspectRatio(
                        aspectRatio: 1.7,
                        child: LineChart(
                          LineChartData(
                            gridData:
                                FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: 1,
                                  getTitlesWidget: (value, _) {
                                    int index = value.toInt();
                                    if (index >= 0 &&
                                        index <
                                            incubatorController
                                                .waktuLabels.length) {
                                      return Text(
                                        incubatorController.waktuLabels[index],
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: 20,
                                  getTitlesWidget: (value, _) =>
                                      Text(value.toInt().toString()),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            minX: 0,
                            maxX: (incubatorController.waktuLabels.length - 1)
                                .toDouble(),
                            minY: 0,
                            maxY: 100,
                            lineBarsData: [
                              LineChartBarData(
                                spots: incubatorController.suhuSpots.length > 10
                                      ? incubatorController.suhuSpots.sublist(incubatorController.suhuSpots.length - 10)
                                      : incubatorController.suhuSpots,
                                isCurved: true,
                                color: Colors.orange,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                              LineChartBarData(
                                spots: incubatorController.kelembapanSpots.length > 10
                                      ? incubatorController.kelembapanSpots.sublist(incubatorController.kelembapanSpots.length - 10)
                                      : incubatorController.kelembapanSpots,
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;

  InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = screenWidth * 0.44;
    final cardHeight = screenHeight * 0.22;

    return Container(
      height: cardHeight,
      width: cardWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF00A1FF),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 54, color: Colors.white),
              Text(
                value,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
