import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/following_user.dart';
import '../../../data/models/feed_session.dart';
import '../../../data/models/stats_summary.dart';
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

  // Poll every 60 seconds while there's a listener
  while (true) {
    yield await api.fetchFeed();
    await Future.delayed(const Duration(seconds: 60));
  }
}
