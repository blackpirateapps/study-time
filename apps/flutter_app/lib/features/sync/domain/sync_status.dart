import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

enum SyncPhase {
  idle,
  syncing,
  paused,
  failed,
}

@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @Default(SyncPhase.idle) SyncPhase phase,
    @Default(0) int pendingCount,
    DateTime? lastSuccessAt,
    String? message,
  }) = _SyncStatus;
}

enum SyncTrigger {
  sessionEnded,
  foreground,
  manualRefresh,
}
