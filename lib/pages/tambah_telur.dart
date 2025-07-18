import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator_app/components/button.dart';
import 'package:incubator_app/components/textfield.dart';
import 'package:incubator_app/controller/incubatorController.dart';
import 'package:incubator_app/model/incubator.dart';
import 'package:intl/intl.dart';

class TambahTelur extends StatefulWidget {
  TambahTelur({super.key});
  final _formKey = GlobalKey<FormState>();
  final kodeControl = TextEditingController();
  final masukDateControl = TextEditingController();
  final keluarDateControl = TextEditingController();
  final jumlahTelurControl = TextEditingController();
  final jumlahMenetasControl = TextEditingController();

  @override
  State<TambahTelur> createState() => _TambahTelurState();
}

class _TambahTelurState extends State<TambahTelur> {
  final IncubatorController incubatorController =
      Get.put(IncubatorController());
  bool showJumlahMenetas = false;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    Future<void> _selectDate(
        BuildContext context, TextEditingController controller) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2200),
      );
      if (picked != null) {
        setState(() {
          controller.text = DateFormat('dd-MM-yyyy').format(picked);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: widget._formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Tambah Telur",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 24),
                ),
                const SizedBox(height: 12),
                TextFieldPage(
                  controller: widget.kodeControl,
                  hintText: "Kode",
                ),
                const SizedBox(height: 12),
                TextFieldPage(
                  controller: widget.masukDateControl,
                  hintText: "Tanggal Masuk",
                  isFilled: true,
                  isDateField: true,
                  prefixIcon: IconButton(
                    onPressed: () =>
                        _selectDate(context, widget.masukDateControl),
                    icon: Icon(Icons.calendar_month),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.masukDateControl.clear();
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
                const SizedBox(height: 12),
                TextFieldPage(
                  controller: widget.keluarDateControl,
                  hintText: "Tanggal Keluar",
                  isFilled: true,
                  isDateField: true,
                  prefixIcon: IconButton(
                    onPressed: () async {
                      _selectDate(context, widget.keluarDateControl);
                      setState(() {
                        showJumlahMenetas = true;
                      });
                    },
                    icon: Icon(Icons.calendar_month),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.keluarDateControl.clear();
                        showJumlahMenetas = false;
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
                const SizedBox(height: 12),
                TextFieldPage(
                  controller: widget.jumlahTelurControl,
                  hintText: "Jumlah Telur",
                ),
                if (showJumlahMenetas) ...[
                  const SizedBox(height: 12),
                  TextFieldPage(
                    controller: widget.jumlahMenetasControl,
                    hintText: "Jumlah Menetas",
                    textInputType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 12),
                MyButton(
                    onTap: () async {
                      if (widget._formKey.currentState!.validate()) {
                        String? dbFormattedDateMasuk =
                            widget.masukDateControl.text.isNotEmpty
                                ? DateFormat('yyyy-MM-dd').format(
                                    DateFormat('dd-MM-yyyy')
                                        .parse(widget.masukDateControl.text))
                                : null;
                        String? dbFormattedDateKeluar =
                            widget.keluarDateControl.text.isNotEmpty
                                ? DateFormat('yyyy-MM-dd').format(
                                    DateFormat('dd-MM-yyyy')
                                        .parse(widget.keluarDateControl.text))
                                : null;

                        final incubator = Incubator(
                          kode: widget.kodeControl.text,
                          tanggal_masuk: dbFormattedDateMasuk,
                          tanggal_keluar: dbFormattedDateKeluar,
                          jumlah_telur:
                              int.parse(widget.jumlahTelurControl.text),
                          jumlah_menetas: showJumlahMenetas &&
                                  widget.jumlahMenetasControl.text.isNotEmpty
                              ? int.parse(widget.jumlahMenetasControl.text)
                              : null,
                        );
                        await incubatorController.addIncubator(incubator);
                        Navigator.pop(context);
                      }
                    },
                    nameBtn: "Tambah")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
