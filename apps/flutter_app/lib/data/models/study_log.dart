import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_log.freezed.dart';

@freezed
class StudyLog with _$StudyLog {
  const StudyLog._();

  const factory StudyLog({
    required String id,
    required String subject,
    String? tag,
    required int durationSeconds,
    required DateTime timestamp,
    @Default(false) bool isSynced,
  }) = _StudyLog;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'tag': tag,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  Map<String, dynamic> toSyncJson() {
    return {
      'id': id,
      'subject': subject,
      if (tag != null && tag!.trim().isNotEmpty) 'tag': tag,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StudyLog.fromMap(Map<dynamic, dynamic> map) {
    return StudyLog(
      id: map['id'] as String,
      subject: map['subject'] as String,
      tag: map['tag'] as String?,
      durationSeconds: (map['duration_seconds'] as num).toInt(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isSynced: map['is_synced'] as bool? ?? false,
    );
  }
}
