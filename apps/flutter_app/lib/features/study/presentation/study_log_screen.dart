import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/study_log.dart';
import '../../../shared/widgets/atmosphere_background.dart';
import '../../../shared/widgets/magic_plus_button.dart';
import '../application/study_log_controller.dart';

class StudyLogScreen extends ConsumerWidget {
  const StudyLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(studyLogControllerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Study Log'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              ref.read(studyLogControllerProvider.notifier).syncPending(),
          child: const Icon(CupertinoIcons.arrow_up_arrow_down_circle),
        ),
      ),
      child: AtmosphereBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: sessions.when(
                      loading: () => const Center(
                        child: CupertinoActivityIndicator(radius: 16),
                      ),
                      error: (error, stackTrace) => _ErrorPane(
                        message: error.toString(),
                      ),
                      data: (logs) => _SessionContent(
                        logs: logs,
                        onMagicPlusTap: () => _showQuickLogSheet(context, ref),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickLogSheet(BuildContext context, WidgetRef ref) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Log Session'),
          message: const Text('Choose a quick focus preset'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => _addPreset(
                context: sheetContext,
                ref: ref,
                subject: 'Mathematics',
                tag: 'Deep Focus',
                durationSeconds: 25 * 60,
              ),
              child: const Text('Deep Focus · 25m · Mathematics'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => _addPreset(
                context: sheetContext,
                ref: ref,
                subject: 'Language Learning',
                tag: 'Review',
                durationSeconds: 50 * 60,
              ),
              child: const Text('Review · 50m · Language'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => _addPreset(
                context: sheetContext,
                ref: ref,
                subject: 'Science',
                tag: 'Lab Notes',
                durationSeconds: 90 * 60,
              ),
              child: const Text('Lab Notes · 90m · Science'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _addPreset({
    required BuildContext context,
    required WidgetRef ref,
    required String subject,
    required String tag,
    required int durationSeconds,
  }) async {
    Navigator.of(context).pop();
    await ref.read(studyLogControllerProvider.notifier).addQuickSession(
          subject: subject,
          tag: tag,
          durationSeconds: durationSeconds,
        );
  }
}

class _SessionContent extends StatelessWidget {
  const _SessionContent({
    required this.logs,
    required this.onMagicPlusTap,
  });

  final List<StudyLog> logs;
  final VoidCallback onMagicPlusTap;

  @override
  Widget build(BuildContext context) {
    final syncedCount = logs.where((log) => log.isSynced).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 18),
                child: child,
              ),
            );
          },
          child: _ProgressBand(
            totalSessions: logs.length,
            syncedSessions: syncedCount,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: logs.isEmpty
              ? const _EmptyPane()
              : ListView(
                  children: [
                    CupertinoListSection.insetGrouped(
                      header: const Text('Recent Sessions'),
                      children: [
                        for (final log in logs)
                          _LogRow(
                            key: ValueKey(log.id),
                            log: log,
                          ),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 6),
        MagicPlusButton(
          label: 'Things-style Magic Plus',
          onPressed: onMagicPlusTap,
        ),
      ],
    );
  }
}

class _ProgressBand extends StatelessWidget {
  const _ProgressBand({
    required this.totalSessions,
    required this.syncedSessions,
  });

  final int totalSessions;
  final int syncedSessions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _MetricLabel(
                label: 'Sessions',
                value: '$totalSessions',
              ),
            ),
            Expanded(
              child: _MetricLabel(
                label: 'Synced',
                value: '$syncedSessions',
              ),
            ),
            Expanded(
              child: _MetricLabel(
                label: 'Pending',
                value: '${totalSessions - syncedSessions}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xAA303632),
          ),
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({
    super.key,
    required this.log,
  });

  final StudyLog log;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d · HH:mm');
    final minutes = (log.durationSeconds / 60).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  log.isSynced ? const Color(0xFF2B7A5A) : const Color(0xFFBA7B45),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.tag} · ${formatter.format(log.timestamp.toLocal())}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xAA303632),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$minutes min',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3D4A45),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPane extends StatelessWidget {
  const _EmptyPane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCCFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.sparkles, size: 28, color: Color(0xFF2B7A5A)),
              SizedBox(height: 10),
              Text(
                'No sessions yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Log your first focus block with the magic plus button.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xAA303632)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF7A3131),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
