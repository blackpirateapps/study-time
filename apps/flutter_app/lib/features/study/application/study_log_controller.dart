import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/study_log.dart';
import '../../../data/repositories/study_repository.dart';
import '../../shared/providers.dart';
import '../../sync/application/sync_provider.dart';
import '../../sync/domain/sync_status.dart';

@Riverpod(keepAlive: true)
class StudyLogController extends AsyncNotifier<List<StudyLog>> {
  late final StudyRepository _studyRepository;
  StreamSubscription<List<StudyLog>>? _logsSubscription;

  @override
  Future<List<StudyLog>> build() async {
    _studyRepository = ref.read(studyRepositoryProvider);

    final initialLogs = await _studyRepository.getAllLogs();

    _logsSubscription?.cancel();
    _logsSubscription = _studyRepository.watchAllLogs().listen((logs) {
      state = AsyncData(logs);
    });

    ref.onDispose(() {
      _logsSubscription?.cancel();
    });

    return initialLogs;
  }

  Future<void> addQuickSession({
    required String subject,
    required String tag,
    required int durationSeconds,
  }) async {
    final log = StudyLog(
      id: const Uuid().v4(),
      subject: subject,
      tag: tag,
      durationSeconds: durationSeconds,
      timestamp: DateTime.now().toUtc(),
      isSynced: false,
    );

    await _studyRepository.saveSession(log);
    await ref
        .read(syncProvider.notifier)
        .syncNow(trigger: SyncTrigger.sessionEnded);
  }

  Future<void> syncPending() async {
    await ref.read(syncProvider.notifier).syncNow(trigger: SyncTrigger.manualRefresh);
  }
}

final studyLogControllerProvider =
    AsyncNotifierProvider<StudyLogController, List<StudyLog>>(
  StudyLogController.new,
);
