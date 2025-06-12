import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator_app/components/button.dart';
import 'package:incubator_app/components/textfield.dart';
import 'package:incubator_app/controller/incubatorController.dart';
import 'package:incubator_app/model/incubator.dart';
import 'package:intl/intl.dart';

class EditTelur extends StatefulWidget {
  final Incubator incubator;
  EditTelur({super.key, required this.incubator});

  @override
  State<EditTelur> createState() => _EditTelurState();
}

class _EditTelurState extends State<EditTelur> {
  final _formKey = GlobalKey<FormState>();
  final IncubatorController incubatorController =
      Get.put(IncubatorController());
  late TextEditingController kodeControl;
  late TextEditingController masukDateControl;
  late TextEditingController keluarDateControl;
  late TextEditingController jumlahTelurControl;

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    kodeControl = TextEditingController(text: widget.incubator.kode);
    masukDateControl = TextEditingController(
        text: widget.incubator.tanggal_masuk != null
            ? DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(widget.incubator.tanggal_masuk!))
            : '');
    keluarDateControl = TextEditingController(
        text: widget.incubator.tanggal_keluar != null
            ? DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(widget.incubator.tanggal_keluar!))
            : '');
    jumlahTelurControl =
        TextEditingController(text: widget.incubator.jumlah_telur.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    "Edit Telur",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 24),
                  ),
                ),
                const SizedBox(height: 20),
                TextFieldPage(controller: kodeControl, hintText: "Kode"),
                const SizedBox(height: 12),
                TextFieldPage(
                  controller: masukDateControl,
                  hintText: "Tanggal Masuk",
                  isFilled: true,
                  isDateField: true,
                  prefixIcon: IconButton(
                    onPressed: () => _selectDate(context, masukDateControl),
                    icon: Icon(Icons.calendar_month),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        masukDateControl.clear();
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
                const SizedBox(height: 12),
                TextFieldPage(
                  controller: keluarDateControl,
                  hintText: "Tanggal Keluar",
                  isFilled: true,
                  isDateField: true,
                  prefixIcon: IconButton(
                    onPressed: () => _selectDate(context, keluarDateControl),
                    icon: Icon(Icons.calendar_month),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        keluarDateControl.clear();
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
                const SizedBox(height: 12),
                TextFieldPage(
                    controller: jumlahTelurControl, hintText: "Jumlah Telur"),
                const SizedBox(height: 12),
                MyButton(
                  nameBtn: "Update",
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      final updated = Incubator(
                        id: widget.incubator.id,
                        kode: kodeControl.text,
                        tanggal_masuk: DateFormat('yyyy-MM-dd').format(
                            DateFormat('dd-MM-yyyy')
                                .parse(masukDateControl.text)),
                        tanggal_keluar: keluarDateControl.text.isNotEmpty
                            ? DateFormat('yyyy-MM-dd').format(
                                DateFormat('dd-MM-yyyy')
                                    .parse(keluarDateControl.text))
                            : null,
                        jumlah_telur: int.parse(jumlahTelurControl.text),
                      );

                      await incubatorController.updateIncubator(updated);
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
