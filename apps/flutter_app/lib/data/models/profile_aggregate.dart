class ProfileAggregate {
  const ProfileAggregate({
    required this.uid,
    required this.totalHours,
    required this.currentStreak,
    required this.totalSessions,
  });

  final String uid;
  final double totalHours;
  final int currentStreak;
  final int totalSessions;

  static const empty = ProfileAggregate(
    uid: '',
    totalHours: 0,
    currentStreak: 0,
    totalSessions: 0,
  );

  static ProfileAggregate fromJson(Map<String, dynamic> json) {
    return ProfileAggregate(
      uid: json['uid'] as String,
      totalHours: (json['total_hours'] as num).toDouble(),
      currentStreak: (json['current_streak'] as num).toInt(),
      totalSessions: (json['total_sessions'] as num).toInt(),
    );
  }
}
