import 'package:isar/isar.dart';

import '../local/study_log_model.dart';
import '../models/study_log.dart';

class StudyRepository {
  StudyRepository(this._isar);

  final Isar _isar;

  Future<void> saveSession(StudyLog log) async {
    final model = StudyLogModel()
      ..remoteId = log.id
      ..isSynced = log.isSynced
      ..subject = log.subject
      ..tag = log.tag
      ..durationSeconds = log.durationSeconds
      ..startTime = log.timestamp.toUtc();

    await _isar.writeTxn(() async {
      await _isar.studyLogModels.put(model);
    });
  }

  Future<List<StudyLog>> getAllLogs() async {
    final models = await _isar.studyLogModels.where().findAll();
    return _toStudyLogs(models);
  }

  Future<List<StudyLog>> getUnsyncedLogs({int limit = 50}) async {
    final models = await _isar.studyLogModels.where().findAll();
    final pending = models.where((model) => !model.isSynced).toList()
      ..sort((left, right) => left.startTime.compareTo(right.startTime));

    return _toStudyLogs(pending.take(limit).toList());
  }

  Future<int> countUnsyncedLogs() async {
    final models = await _isar.studyLogModels.where().findAll();
    return models.where((model) => !model.isSynced).length;
  }

  Future<void> markAsSynced(List<String> remoteIds) async {
    if (remoteIds.isEmpty) {
      return;
    }

    final remoteIdsSet = remoteIds.toSet();

    await _isar.writeTxn(() async {
      final models = await _isar.studyLogModels.where().findAll();
      final updates = <StudyLogModel>[];

      for (final model in models) {
        if (!model.isSynced && remoteIdsSet.contains(model.remoteId)) {
          model.isSynced = true;
          updates.add(model);
        }
      }

      if (updates.isNotEmpty) {
        await _isar.studyLogModels.putAll(updates);
      }
    });
  }

  Stream<List<StudyLog>> watchAllLogs() {
    return _isar.studyLogModels.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllLogs();
    });
  }

  List<StudyLog> _toStudyLogs(List<StudyLogModel> models) {
    final logs = models
        .map(
          (model) => StudyLog(
            id: model.remoteId,
            subject: model.subject,
            tag: model.tag,
            durationSeconds: model.durationSeconds,
            timestamp: model.startTime,
            isSynced: model.isSynced,
          ),
        )
        .toList()
      ..sort((left, right) => right.timestamp.compareTo(left.timestamp));

    return logs;
  }
}
