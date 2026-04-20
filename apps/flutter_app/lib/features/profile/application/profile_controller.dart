import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_env.dart';
import '../../../data/models/profile_aggregate.dart';
import '../../../data/remote/aura_api.dart';
import '../../shared/providers.dart';

@Riverpod(keepAlive: true)
class ProfileController extends AsyncNotifier<ProfileAggregate> {
  late final AuraApi _api;

  @override
  Future<ProfileAggregate> build() async {
    _api = ref.read(auraApiProvider);

    if (AppEnv.profileUid.isEmpty) {
      return ProfileAggregate.empty;
    }

    return _api.fetchProfile(AppEnv.profileUid);
  }

  Future<void> refreshProfile() async {
    if (AppEnv.profileUid.isEmpty) {
      state = const AsyncData(ProfileAggregate.empty);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _api.fetchProfile(AppEnv.profileUid));
  }

  Future<void> followAndRefresh(String targetUid) async {
    await _api.follow(targetUid);
    await refreshProfile();
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileAggregate>(
  ProfileController.new,
);
