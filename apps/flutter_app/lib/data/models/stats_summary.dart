class StatsComparison {
  const StatsComparison({
    required this.userHours,
    required this.followingHours,
  });

  final double userHours;
  final double followingHours;

  static StatsComparison fromJson(Map<String, dynamic> json) {
    return StatsComparison(
      userHours: (json['user_hours'] as num).toDouble(),
      followingHours: (json['following_hours'] as num).toDouble(),
    );
  }
}

class StatsSummary {
  const StatsSummary({
    required this.dailyTotals,
    required this.subjectBreakdown,
    required this.comparison,
  });

  final Map<String, double> dailyTotals;
  final Map<String, double> subjectBreakdown;
  final StatsComparison comparison;

  static StatsSummary fromJson(Map<String, dynamic> json) {
    return StatsSummary(
      dailyTotals: (json['daily_totals'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      subjectBreakdown: (json['subject_breakdown'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      comparison: StatsComparison.fromJson(json['comparison'] as Map<String, dynamic>),
    );
  }
}
