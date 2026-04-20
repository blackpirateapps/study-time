import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/following_user.dart';
import '../../../data/models/feed_session.dart';
import '../../../data/models/stats_summary.dart';
import '../../../data/remote/aura_api.dart';
import '../../shared/providers.dart';

part 'social_providers.g.dart';

@riverpod
Future<List<FollowingUser>> followingUsers(FollowingUsersRef ref) {
  final api = ref.watch(auraApiProvider);
  return api.fetchFollowing();
}

@riverpod
Future<StatsSummary> statsSummary(StatsSummaryRef ref) {
  final api = ref.watch(auraApiProvider);
  return api.fetchStatsSummary();
}

@riverpod
Stream<List<FeedSession>> pollingCircleFeed(PollingCircleFeedRef ref) async* {
  final api = ref.watch(auraApiProvider);

  // Initial fetch
  yield await api.fetchFeed();

  // Poll every 60 seconds while there's a listener
  final timer = Timer.periodic(const Duration(seconds: 60), (_) async {
    try {
      final feed = await api.fetchFeed();
      if (!ref.state.isClosed) {
        ref.state = AsyncValue.data(feed);
      }
    } catch (e, st) {
      if (!ref.state.isClosed) {
        ref.state = AsyncValue.error(e, st);
      }
    }
  });

  ref.onDispose(timer.cancel);
}
