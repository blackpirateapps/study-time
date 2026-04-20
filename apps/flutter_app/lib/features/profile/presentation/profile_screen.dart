import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../data/models/profile_aggregate.dart';
import '../../../shared/widgets/atmosphere_background.dart';
import '../application/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              ref.read(profileControllerProvider.notifier).refreshProfile(),
          child: const Icon(CupertinoIcons.refresh),
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
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: profile.when(
                      loading: () => const Center(
                        child: CupertinoActivityIndicator(radius: 16),
                      ),
                      error: (error, _) => _ErrorState(message: error.toString()),
                      data: (aggregate) => _ProfileContent(
                        aggregate: aggregate,
                        onFollowTap: () => _showFollowDialog(context, ref),
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

  Future<void> _showFollowDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Follow User'),
          content: Column(
            children: [
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: controller,
                placeholder: 'Enter target UID',
                autocorrect: false,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                final target = controller.text.trim();
                Navigator.of(dialogContext).pop();
                if (target.isEmpty) {
                  return;
                }

                try {
                  await ref
                      .read(profileControllerProvider.notifier)
                      .followAndRefresh(target);
                } catch (error) {
                  await showCupertinoDialog<void>(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Follow failed'),
                      content: Text(error.toString()),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Follow'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.aggregate,
    required this.onFollowTap,
  });

  final ProfileAggregate aggregate;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final hasProfileUid = AppEnv.profileUid.isNotEmpty;

    return ListView(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCCFFFFFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Study Aggregates',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  hasProfileUid
                      ? 'UID: ${aggregate.uid}'
                      : 'Set AURA_PROFILE_UID with --dart-define to load profile data.',
                  style: const TextStyle(fontSize: 13, color: Color(0xAA303632)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Total Hours',
                        value: aggregate.totalHours.toStringAsFixed(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'Current Streak',
                        value: '${aggregate.currentStreak}d',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'Sessions',
                        value: '${aggregate.totalSessions}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        CupertinoListSection.insetGrouped(
          header: const Text('Social Actions'),
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              alignment: Alignment.centerLeft,
              onPressed: onFollowTap,
              child: const Row(
                children: [
                  Icon(CupertinoIcons.person_add, size: 18),
                  SizedBox(width: 10),
                  Text('Follow by UID'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF2E8D7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xAA303632)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF7A3131)),
      ),
    );
  }
}
