import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/local/local_study_log_store.dart';
import '../../data/remote/aura_api.dart';
import 'auth_token_provider.dart';

const auraSyncTask = 'aura-sync-pending-study-logs';

@pragma('vm:entry-point')
void auraBackgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != auraSyncTask) {
      return true;
    }

    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    final localStore = LocalStudyLogStore();
    final api = AuraApi(AuthTokenProvider());
    final pending = await localStore.getPendingLogs();

    if (pending.isEmpty) {
      return true;
    }

    try {
      await api.syncLogs(pending);
      await localStore.markSynced(pending.map((log) => log.id));
      return true;
    } catch (_) {
      return false;
    }
  });
}

class BackgroundSyncService {
  Future<void> scheduleRetry() {
    return Workmanager().registerOneOffTask(
      '${auraSyncTask}-${DateTime.now().millisecondsSinceEpoch}',
      auraSyncTask,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: const Duration(minutes: 2),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 10),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}
