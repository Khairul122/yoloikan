import 'package:flutter/material.dart';

class IkanModel {
  final int id;
  final String nama;
  final String deskripsi;
  final Color warna;

  const IkanModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.warna,
  });

  factory IkanModel.fromJson(Map<String, dynamic> json) {
    final hex = (json['warna'] as String).replaceFirst('#', '');
    return IkanModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      warna: Color(int.parse('FF$hex', radix: 16)),
    );
  }
}
