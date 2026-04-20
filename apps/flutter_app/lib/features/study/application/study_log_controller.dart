import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/background_sync.dart';
import '../../../core/services/haptics.dart';
import '../../../data/local/local_study_log_store.dart';
import '../../../data/models/study_log.dart';
import '../../../data/remote/aura_api.dart';
import '../../shared/providers.dart';

@Riverpod(keepAlive: true)
class StudyLogController extends AsyncNotifier<List<StudyLog>> {
  late final LocalStudyLogStore _localStore;
  late final AuraApi _api;
  late final BackgroundSyncService _backgroundSync;

  @override
  Future<List<StudyLog>> build() async {
    _localStore = ref.read(localStudyLogStoreProvider);
    _api = ref.read(auraApiProvider);
    _backgroundSync = ref.read(backgroundSyncServiceProvider);
    return _localStore.getAllLogs();
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

    await _localStore.putLog(log);
    final current = state.valueOrNull ?? const <StudyLog>[];
    state = AsyncData([log, ...current]);

    await syncPending();
  }

  Future<void> syncPending() async {
    final pending = await _localStore.getPendingLogs();
    if (pending.isEmpty) {
      return;
    }

    try {
      await _api.syncLogs(pending);
      await _localStore.markSynced(pending.map((log) => log.id));
      await AuraHaptics.syncSuccess();
    } catch (_) {
      await AuraHaptics.syncError();
      await _backgroundSync.scheduleRetry();
    }

    state = AsyncData(await _localStore.getAllLogs());
  }
}

final studyLogControllerProvider =
    AsyncNotifierProvider<StudyLogController, List<StudyLog>>(
  StudyLogController.new,
);
