import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/app_env.dart';

class AuthTokenProvider {
  Future<String?> getBearerToken() async {
    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.getIdToken();
      }
    }

    if (AppEnv.devBearerToken.isNotEmpty) {
      return AppEnv.devBearerToken;
    }

    return null;
  }
}
