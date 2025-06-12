import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator_app/controller/database_helper.dart';
import 'package:incubator_app/model/incubator.dart';
import 'package:incubator_app/pages/edit_telur.dart';
import 'package:incubator_app/pages/tambah_telur.dart';

class DataTelur extends StatefulWidget {
  @override
  _DataTelurState createState() => _DataTelurState();
}

class _DataTelurState extends State<DataTelur> {
  late Future<List<Incubator>> _dataTelurFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataTelurFuture = DatabaseHelper.instance.getAllIncubators();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Telur",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Header row
              Container(
                color: const Color(0xFF00A1FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: const [
                    Expanded(
                      child: Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Kode",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Tanggal Masuk",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Tanggal Keluar",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Data list
              Expanded(
                child: FutureBuilder<List<Incubator>>(
                  future: _dataTelurFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Tidak ada data.'));
                    }

                    final data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Konfirmasi"),
                                content: const Text(
                                    "Yakin ingin menghapus data ini?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text("Batal")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text("Hapus")),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) async {
                            await DatabaseHelper.instance
                                .deleteIncubator(item.id!);
                            setState(() {
                              _loadData(); // Refresh data
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Data berhasil dihapus")),
                            );
                          },
                          child: InkWell(
                            onTap: () async {
                              await Get.to(() => EditTelur(incubator: item));
                              setState(() => _loadData());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    '${index + 1}',
                                    style: TextStyle(fontSize: 16),
                                  ))),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    item.kode ?? "-",
                                    style: TextStyle(fontSize: 16),
                                  ))),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    item.tanggal_masuk ?? "-",
                                    style: TextStyle(fontSize: 16),
                                  ))),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    item.tanggal_keluar ?? "-",
                                    style: TextStyle(fontSize: 16),
                                  ))),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await Get.to(() => TambahTelur());
                    setState(() {
                      _loadData(); // Refresh data setelah kembali
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A1FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                  ),
                  child: const Text(
                    "Tambah Telur",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
