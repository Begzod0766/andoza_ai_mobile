class AppConfig {
  // API Configuration
  // Note: Android emulator uses 10.0.2.2 to refer to host's localhost
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Origin of the web "Studio" (React/Three.js) that the app embeds in a
  /// WebView for 3D room editing. Default targets the emulator host loopback;
  /// override with `--dart-define=STUDIO_BASE_URL=http://<lan-ip>:5173` for a
  /// physical device. The frontend must be served with a VITE_API_URL that is
  /// reachable from the device (see plans/studio-port-plan.md, Phase 7A).
  static const String studioBaseUrl = String.fromEnvironment(
    'STUDIO_BASE_URL',
    defaultValue: 'http://10.0.2.2:5173',
  );

  /// Phone + SMS-code sign-in. Off until an SMS provider is connected: the app
  /// then opens on login/password sign-in with registration below it.
  /// Turn on with `--dart-define=SMS_LOGIN_ENABLED=true`.
  static const bool smsLoginEnabled =
      bool.fromEnvironment('SMS_LOGIN_ENABLED', defaultValue: false);

  /// Google Sign-In: the OAuth *web* client id. The ID token is minted for this
  /// audience so the backend (`POST /auth/google`) can verify it; on Android it
  /// is also what Credential Manager needs to return an ID token at all.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '632412937266-ruq48osgghaa4jn0fk8vjd7mr270ccb0.apps.googleusercontent.com',
  );

  /// Google Sign-In iOS OAuth client id ("iOS upload", bundle uz.andozaai.app).
  /// Must match GIDClientID and the reversed-client-id URL scheme in
  /// ios/Runner/Info.plist. If overridden to empty, the Google button is hidden
  /// on iOS (the native SDK cannot start without it).
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '632412937266-nb16ekesaj9ubuahnmio29187nu5uhre.apps.googleusercontent.com',
  );

  // LiDAR Configuration
  static const bool lidarEnabled =
      String.fromEnvironment('LIDAR_ENABLED', defaultValue: 'true') == 'true';

  // Debug Configuration
  static const bool debugLogging =
      String.fromEnvironment('DEBUG_LOGGING', defaultValue: 'true') == 'true';

  // App Configuration
  static const String appName = 'Andoza AI Mobile';
  static const String appVersion = '0.1.0';
}
