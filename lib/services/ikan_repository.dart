import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ikan_model.dart';

class IkanRepository {
  IkanRepository._();

  static List<IkanModel>? _cache;

  static Future<List<IkanModel>> loadAll() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('assets/models/ikan.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    _cache = list
        .map((e) => IkanModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  static Future<IkanModel?> findById(int classIndex) async {
    final all = await loadAll();
    try {
      return all.firstWhere((e) => e.id == classIndex);
    } catch (_) {
      return null;
    }
  }

  /// Cari spesies berdasarkan nama kelas (case-insensitive).
  ///
  /// Diperlukan karena `YOLO.predict` (single image) pada
  /// ultralytics_yolo 0.6.2 tidak menyertakan key `classIndex` pada hasil
  /// deteksinya, sehingga `YOLOResult.fromMap` selalu mengembalikan
  /// `classIndex = 0`. Nama kelas (`className`) tetap akurat, jadi
  /// digunakan untuk mencocokkan entri di ikan.json.
  static Future<IkanModel?> findByName(String className) async {
    final all = await loadAll();
    final normalized = className.trim().toLowerCase();
    try {
      return all.firstWhere((e) => e.nama.trim().toLowerCase() == normalized);
    } catch (_) {
      return null;
    }
  }
}
