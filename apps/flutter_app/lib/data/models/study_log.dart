class StudyLog {
  const StudyLog({
    required this.id,
    required this.subject,
    required this.tag,
    required this.durationSeconds,
    required this.timestamp,
    required this.isSynced,
  });

  final String id;
  final String subject;
  final String tag;
  final int durationSeconds;
  final DateTime timestamp;
  final bool isSynced;

  StudyLog copyWith({
    String? id,
    String? subject,
    String? tag,
    int? durationSeconds,
    DateTime? timestamp,
    bool? isSynced,
  }) {
    return StudyLog(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      tag: tag ?? this.tag,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }

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
      'tag': tag,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static StudyLog fromMap(Map<dynamic, dynamic> map) {
    return StudyLog(
      id: map['id'] as String,
      subject: map['subject'] as String,
      tag: map['tag'] as String,
      durationSeconds: (map['duration_seconds'] as num).toInt(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isSynced: map['is_synced'] as bool? ?? false,
    );
  }
}
