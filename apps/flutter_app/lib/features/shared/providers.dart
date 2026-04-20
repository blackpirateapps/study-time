import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/database/app_database.dart';
import '../../core/services/auth_token_provider.dart';
import '../../data/remote/aura_api.dart';
import '../../data/remote/sync_api_client.dart';
import '../../data/repositories/study_repository.dart';

final authTokenProviderProvider = Provider<AuthTokenProvider>((ref) {
  return AuthTokenProvider();
});

final auraApiProvider = Provider<AuraApi>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return AuraApi(tokenProvider);
});

final syncApiClientProvider = Provider<SyncApiClient>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return SyncApiClient(tokenProvider);
});

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepository(AppDatabase.instance);
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});
