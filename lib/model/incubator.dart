// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
class Incubator {
  final int? id;
  final String? kode;
  final String? tanggal_masuk;
  final String? tanggal_keluar;
  final int? jumlah_telur;
  Incubator({
    this.id,
    this.kode,
    this.tanggal_masuk,
    this.tanggal_keluar,
    this.jumlah_telur,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kode': kode,
      'tanggal_masuk': tanggal_masuk,
      'tanggal_keluar': tanggal_keluar,
      'jumlah_telur': jumlah_telur,
    };
  }

  factory Incubator.fromMap(Map<String, dynamic> map) {
    return Incubator(
      id: map['id'] != null ? map['id'] as int : null,
      kode: map['kode'] != null ? map['kode'] as String : null,
      tanggal_masuk: map['tanggal_masuk'] != null ? map['tanggal_masuk'] as String : null,
      tanggal_keluar: map['tanggal_keluar'] != null ? map['tanggal_keluar'] as String : null,
      jumlah_telur: map['jumlah_telur'] != null ? map['jumlah_telur'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory Incubator.fromJson(String source) => Incubator.fromMap(json.decode(source) as Map<String, dynamic>);
}
