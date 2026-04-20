import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/feed_session.dart';
import '../../shared/providers.dart';
import '../application/social_providers.dart';
import 'qr_scanner_layer.dart';

class CircleScreen extends ConsumerStatefulWidget {
  const CircleScreen({super.key});

  @override
  ConsumerState<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends ConsumerState<CircleScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _followUser(String uid) async {
    try {
      final api = ref.read(auraApiProvider);
      await api.follow(uid);
      HapticFeedback.lightImpact();
      // ignore: unused_result
      ref.refresh(pollingCircleFeedProvider);
      // ignore: unused_result
      ref.refresh(statsSummaryProvider);
    } catch (e) {
      // Handle error gracefully
    }
  }

  void _openQrScanner() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => QrScannerLayer(
          onUidScanned: (uid) {
            Navigator.of(context).pop();
            _followUser(uid);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(pollingCircleFeedProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Circle'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _openQrScanner,
          child: const Icon(CupertinoIcons.qrcode_viewfinder),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: 'Add brother by UID',
                  onSubmitted: _followUser,
                ),
              ),
            ),
            feedAsync.when(
              data: (feed) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = feed[index];
                    return _FeedSessionCard(session: session);
                  },
                  childCount: feed.length,
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedSessionCard extends StatefulWidget {
  const _FeedSessionCard({required this.session});

  final FeedSession session;

  @override
  State<_FeedSessionCard> createState() => _FeedSessionCardState();
}

class _FeedSessionCardState extends State<_FeedSessionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    if (widget.session.isActive) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(_FeedSessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.isActive && !oldWidget.session.isActive) {
      _pulseController.repeat();
    } else if (!widget.session.isActive && oldWidget.session.isActive) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withAlpha((0.1 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (widget.session.isActive)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF5856D6),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0FF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.session.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF5856D6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\${widget.session.subject} (\${(widget.session.durationSeconds / 60).toStringAsFixed(0)} min)',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.session.isActive)
              const Text(
                'Studying',
                style: TextStyle(
                  color: Color(0xFF5856D6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
