class AppEnv {
  static const apiBaseUrl = String.fromEnvironment(
    'AURA_API_BASE_URL',
    defaultValue: 'https://study-time-five.vercel.app',
  );

  static const devBearerToken = String.fromEnvironment(
    'AURA_DEV_BEARER_TOKEN',
    defaultValue: '',
  );

  static const profileUid = String.fromEnvironment(
    'AURA_PROFILE_UID',
    defaultValue: '',
  );
}
