import 'package:hive_flutter/hive_flutter.dart';

import '../models/study_log.dart';

class LocalStudyLogStore {
  static const _boxName = 'study_logs_box';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }

    return Hive.openBox<dynamic>(_boxName);
  }

  Future<List<StudyLog>> getAllLogs() async {
    final box = await _openBox();
    final logs = box.values
        .whereType<Map>()
        .map((item) => StudyLog.fromMap(item))
        .toList();

    logs.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return logs;
  }

  Future<List<StudyLog>> getPendingLogs() async {
    final logs = await getAllLogs();
    return logs.where((log) => !log.isSynced).toList();
  }

  Future<void> putLog(StudyLog log) async {
    final box = await _openBox();
    await box.put(log.id, log.toMap());
  }

  Future<void> markSynced(Iterable<String> ids) async {
    final box = await _openBox();

    for (final id in ids) {
      final raw = box.get(id);
      if (raw is Map) {
        final updated = StudyLog.fromMap(raw).copyWith(isSynced: true);
        await box.put(id, updated.toMap());
      }
    }
  }
}
