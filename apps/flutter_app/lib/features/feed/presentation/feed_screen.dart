import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/feed_session.dart';
import '../../../shared/widgets/atmosphere_background.dart';
import '../application/feed_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedControllerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Aura Feed'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => ref.read(feedControllerProvider.notifier).refreshFeed(),
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
                    child: feed.when(
                      loading: () => const Center(
                        child: CupertinoActivityIndicator(radius: 16),
                      ),
                      error: (error, _) => Center(
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF7A3131)),
                        ),
                      ),
                      data: (sessions) {
                        if (sessions.isEmpty) {
                          return const _EmptyFeed();
                        }

                        return ListView(
                          children: [
                            CupertinoListSection.insetGrouped(
                              header: const Text('Latest from people you follow'),
                              children: [
                                for (var i = 0; i < sessions.length; i++)
                                  _AnimatedFeedTile(
                                    delayMs: 40 * i,
                                    session: sessions[i],
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
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
}

class _AnimatedFeedTile extends StatelessWidget {
  const _AnimatedFeedTile({
    required this.delayMs,
    required this.session,
  });

  final int delayMs;
  final FeedSession session;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMs),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: _FeedTile(session: session),
    );
  }
}

class _FeedTile extends StatelessWidget {
  const _FeedTile({required this.session});

  final FeedSession session;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d · HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2B7A5A).withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 15,
              color: Color(0xFF2B7A5A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.subject} · ${session.tag}',
                  style: const TextStyle(fontSize: 13, color: Color(0xAA303632)),
                ),
                const SizedBox(height: 2),
                Text(
                  formatter.format(session.timestamp.toLocal()),
                  style: const TextStyle(fontSize: 12, color: Color(0x88303632)),
                ),
              ],
            ),
          ),
          Text(
            '${(session.durationSeconds / 60).round()}m',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF40534B),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCCFFFFFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.person_2, size: 26, color: Color(0xFF2B7A5A)),
              SizedBox(height: 8),
              Text(
                'No feed activity yet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Follow friends to see their latest study sessions here.',
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
