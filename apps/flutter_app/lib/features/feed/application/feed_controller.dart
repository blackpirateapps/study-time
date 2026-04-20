import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/feed_session.dart';
import '../../../data/remote/aura_api.dart';
import '../../shared/providers.dart';

@Riverpod(keepAlive: true)
class FeedController extends AsyncNotifier<List<FeedSession>> {
  late final AuraApi _api;

  @override
  Future<List<FeedSession>> build() async {
    _api = ref.read(auraApiProvider);
    return _api.fetchFeed();
  }

  Future<void> refreshFeed() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_api.fetchFeed);
  }
}

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<FeedSession>>(
  FeedController.new,
);
