import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/history_item.dart';

class HistoryRepository {
  HistoryRepository._();

  static const _fileName = 'history.json';

  /// Bertambah setiap kali data riwayat berubah (add/delete/clear), agar
  /// halaman Riwayat (yang dipertahankan via `AutomaticKeepAliveClientMixin`
  /// dan tidak otomatis reload saat berpindah tab) bisa memuat ulang data.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Antrean operasi baca-ubah-tulis agar tidak terjadi race condition
  /// (lost update) ketika `add`/`deleteById`/`clear` dipanggil hampir
  /// bersamaan — semua operasi dijalankan berurutan lewat chain ini.
  static Future<void> _queue = Future.value();

  static Future<File> _historyFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File('${docsDir.path}/$_fileName');
  }

  static Future<List<HistoryItem>> _readAll() async {
    final file = await _historyFile();
    if (!await file.exists()) return [];
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // File korup/format lama — anggap kosong agar app tidak crash.
      return [];
    }
  }

  static Future<void> _writeAll(List<HistoryItem> items) async {
    final file = await _historyFile();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await file.writeAsString(raw);
    revision.value++;
  }

  /// Jalankan [action] secara berurutan terhadap operasi lain pada repo ini.
  static Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  static Future<List<HistoryItem>> getAll() async {
    final items = await _readAll();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  static Future<void> add({
    required int classIndex,
    required String className,
    required double confidence,
    Uint8List? photo,
  }) {
    return _enqueue(() async {
      final items = await _readAll();

      final timestamp = DateTime.now();
      String? photoPath;

      if (photo != null) {
        final docsDir = await getApplicationDocumentsDirectory();
        final historyDir = Directory('${docsDir.path}/history');
        if (!await historyDir.exists()) {
          await historyDir.create(recursive: true);
        }
        final file = File(
          '${historyDir.path}/${timestamp.millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(photo);
        photoPath = file.path;
      }

      items.add(
        HistoryItem(
          id: timestamp.toIso8601String(),
          classIndex: classIndex,
          className: className,
          confidence: confidence,
          photoPath: photoPath,
          timestamp: timestamp,
        ),
      );

      await _writeAll(items);
    });
  }

  static Future<void> deleteById(String id) {
    return _enqueue(() async {
      final items = await _readAll();

      final index = items.indexWhere((e) => e.id == id);
      if (index == -1) return;

      final photoPath = items[index].photoPath;
      if (photoPath != null) {
        final file = File(photoPath);
        if (await file.exists()) await file.delete();
      }

      items.removeAt(index);
      await _writeAll(items);
    });
  }

  static Future<void> clear() {
    return _enqueue(() async {
      final items = await _readAll();
      for (final item in items) {
        if (item.photoPath != null) {
          final file = File(item.photoPath!);
          if (await file.exists()) await file.delete();
        }
      }
      await _writeAll([]);
    });
  }
}
