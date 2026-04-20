import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/study_log.dart';
import '../../../data/remote/sync_api_client.dart';
import '../../../data/repositories/study_repository.dart';
import '../../shared/providers.dart';
import '../domain/sync_status.dart';

class SyncProvider extends AsyncNotifier<SyncStatus> {
  static const int _batchSize = 50;
  static const int _maxRetries = 3;

  late final StudyRepository _studyRepository;
  late final SyncApiClient _syncApiClient;
  late final Connectivity _connectivity;
  bool _isSyncInFlight = false;

  @override
  Future<SyncStatus> build() async {
    _studyRepository = ref.read(studyRepositoryProvider);
    _syncApiClient = ref.read(syncApiClientProvider);
    _connectivity = ref.read(connectivityProvider);

    final pendingCount = await _studyRepository.countUnsyncedLogs();
    return SyncStatus(pendingCount: pendingCount);
  }

  Future<void> syncNow({required SyncTrigger trigger}) async {
    if (_isSyncInFlight) {
      return;
    }

    final pendingCount = await _studyRepository.countUnsyncedLogs();

    if (pendingCount == 0) {
      final previous = state.valueOrNull;
      state = AsyncData(
        SyncStatus(
          pendingCount: 0,
          phase: SyncPhase.idle,
          lastSuccessAt: previous?.lastSuccessAt,
          message: trigger == SyncTrigger.manualRefresh
              ? 'Everything is already in sync.'
              : null,
        ),
      );
      return;
    }

    if (await _isOffline()) {
      final previous = state.valueOrNull;
      state = AsyncData(
        SyncStatus(
          phase: SyncPhase.paused,
          pendingCount: pendingCount,
          lastSuccessAt: previous?.lastSuccessAt,
          message: 'Offline. Waiting for connectivity to resume sync.',
        ),
      );
      return;
    }

    final previous = state.valueOrNull;
    state = AsyncData(
      SyncStatus(
        phase: SyncPhase.syncing,
        pendingCount: pendingCount,
        lastSuccessAt: previous?.lastSuccessAt,
      ),
    );
    _isSyncInFlight = true;

    try {
      await _syncWithBackoff();
      final remaining = await _studyRepository.countUnsyncedLogs();
      await HapticFeedback.lightImpact();

      state = AsyncData(
        SyncStatus(
          phase: SyncPhase.idle,
          pendingCount: remaining,
          lastSuccessAt: DateTime.now(),
          message: remaining == 0 ? null : 'Partial sync complete. More items pending.',
        ),
      );
    } catch (error) {
      final remaining = await _studyRepository.countUnsyncedLogs();
      state = AsyncData(
        SyncStatus(
          phase: SyncPhase.failed,
          pendingCount: remaining,
          lastSuccessAt: previous?.lastSuccessAt,
          message: error.toString(),
        ),
      );
    } finally {
      _isSyncInFlight = false;
    }
  }

  Future<void> _syncWithBackoff() async {
    final pendingCount = await _studyRepository.countUnsyncedLogs();
    if (pendingCount == 0) {
      return;
    }

    final pendingLogs = await _studyRepository.getUnsyncedLogs(limit: pendingCount);
    if (pendingLogs.isEmpty) {
      return;
    }

    for (var index = 0; index < pendingLogs.length; index += _batchSize) {
      final end = min(index + _batchSize, pendingLogs.length);
      final batch = pendingLogs.sublist(index, end);
      await _syncBatchWithRetry(batch);
    }

    // Why: local flags are flipped only after every batch succeeds so the
    // client-side sync state stays all-or-nothing for this sync run.
    await _studyRepository.markAsSynced(
      pendingLogs.map((log) => log.id).toList(),
    );
  }

  Future<void> _syncBatchWithRetry(List<StudyLog> batch) async {
    int attempt = 0;

    while (true) {
      try {
        await _syncApiClient.syncStudyLogs(batch);
        return;
      } on SyncApiException catch (error) {
        if (!error.isServerError || attempt >= _maxRetries) {
          rethrow;
        }

        // Why: retries only on 5xx keeps transient edge/database failures
        // invisible to users while avoiding duplicate records via server-side
        // idempotency on remote log IDs.
        attempt += 1;
        final delaySeconds = pow(2, attempt).toInt();
        await Future<void>.delayed(Duration(seconds: delaySeconds));
      }
    }
  }

  Future<bool> _isOffline() async {
    final dynamic result = await _connectivity.checkConnectivity();

    if (result is ConnectivityResult) {
      return result == ConnectivityResult.none;
    }

    if (result is List<ConnectivityResult>) {
      return result.isEmpty || result.every((entry) => entry == ConnectivityResult.none);
    }

    return false;
  }
}

final syncProvider = AsyncNotifierProvider<SyncProvider, SyncStatus>(
  SyncProvider.new,
);
