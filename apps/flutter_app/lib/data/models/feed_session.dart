class FeedSession {
  const FeedSession({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.subject,
    required this.tag,
    required this.durationSeconds,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String displayName;
  final String subject;
  final String tag;
  final int durationSeconds;
  final DateTime timestamp;

  static FeedSession fromJson(Map<String, dynamic> json) {
    return FeedSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      subject: json['subject'] as String,
      tag: json['tag'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
