import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_token_provider.dart';
import '../../core/services/background_sync.dart';
import '../../data/local/local_study_log_store.dart';
import '../../data/remote/aura_api.dart';

final authTokenProviderProvider = Provider<AuthTokenProvider>((ref) {
  return AuthTokenProvider();
});

final localStudyLogStoreProvider = Provider<LocalStudyLogStore>((ref) {
  return LocalStudyLogStore();
});

final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  return BackgroundSyncService();
});

final auraApiProvider = Provider<AuraApi>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return AuraApi(tokenProvider);
});
