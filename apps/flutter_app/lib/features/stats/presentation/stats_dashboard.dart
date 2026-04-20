import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/stats_summary.dart';
import '../../social/application/social_providers.dart';

class StatsDashboard extends ConsumerWidget {
  const StatsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsSummaryProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Stats Dashboard'),
      ),
      child: SafeArea(
        child: statsAsync.when(
          data: (stats) => _StatsContent(stats: stats),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});

  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Weekly Goal Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _RingPainter(
                      progress: (stats.comparison.userHours / 40.0).clamp(0.0, 1.0),
                      activeColor: const Color(0xFF5856D6),
                      backgroundColor: const Color(0xFFE0E0FF),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\${stats.comparison.userHours.toStringAsFixed(1)}h',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5856D6),
                          ),
                        ),
                        const Text(
                          '/ 40h',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Activity Heatmap (Last 7 Days)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: CustomPaint(
              painter: _HeatmapPainter(dailyTotals: stats.dailyTotals),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Subject Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.zero,
            children: stats.subjectBreakdown.entries.map((entry) {
              return _SubjectDistributionBar(
                subject: entry.key,
                percentage: entry.value,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color activeColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * 3.14159265359 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({required this.dailyTotals});

  final Map<String, double> dailyTotals;

  @override
  void paint(Canvas canvas, Size size) {
    const double boxSize = 24.0;
    const double spacing = 4.0;
    const int maxCols = 7;
    
    // Sort dates
    final dates = dailyTotals.keys.toList()..sort();
    final recentDates = dates.length > 7 ? dates.sublist(dates.length - 7) : dates;

    final maxVal = recentDates.fold<double>(
        0, (m, k) => dailyTotals[k]! > m ? dailyTotals[k]! : m);

    for (int i = 0; i < maxCols; i++) {
      final x = size.width - ((maxCols - i) * (boxSize + spacing));
      final rect = Rect.fromLTWH(x, 0, boxSize, boxSize);

      Color color = CupertinoColors.systemGrey6; // Empty default
      if (i < recentDates.length) {
        final val = dailyTotals[recentDates[i]] ?? 0;
        if (val > 0) {
          final double intensity = (maxVal > 0 ? val / maxVal : 0.0).clamp(0.2, 1.0).toDouble();
          color = const Color(0xFF5856D6).withAlpha((intensity * 255).toInt());
        }
      }

      final paint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return true;
  }
}

class _SubjectDistributionBar extends StatelessWidget {
  const _SubjectDistributionBar({
    required this.subject,
    required this.percentage,
  });

  final String subject;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          FractionallySizedBox(
            widthFactor: percentage / 100.0,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0FF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subject, style: const TextStyle(fontSize: 16)),
                Text(
                  '\${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
