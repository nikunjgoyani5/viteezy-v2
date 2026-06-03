import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Remote Config parameter key for the valid license key.
/// App allows access only when the built-in key (from [appLicenseKeyBuiltIn]) matches this value.
const String kRemoteConfigKeyAppLicenseKey = 'app_license_key';

/// Fetches and exposes Firebase Remote Config values.
/// Access is allowed only when [app_license_key] from Remote Config matches the app's built-in key.
class RemoteConfigService {
  RemoteConfigService._();

  static FirebaseRemoteConfig get _remoteConfig => FirebaseRemoteConfig.instance;

  /// The license key from Remote Config. App is unlocked only when this equals [appLicenseKeyBuiltIn].
  static String get appLicenseKey =>
      _remoteConfig.getString(kRemoteConfigKeyAppLicenseKey).trim();

  /// Built-in license key, set at build time. Pass via dart-define:
  /// flutter build apk --dart-define=APP_LICENSE_KEY=your_secret_key
  static String get appLicenseKeyBuiltIn =>
      const String.fromEnvironment('APP_LICENSE_KEY', defaultValue: '');

  /// Access is allowed when: running in debug (e.g. flutter run) OR license key from Remote Config matches the app's key.
  static bool get hasValidLicenseKey {
    if (kDebugMode) return true; // Allow access when running directly (flutter run / IDE)
    return appLicenseKey.isNotEmpty && appLicenseKey == appLicenseKeyBuiltIn;
  }

  /// Initialize Remote Config: set defaults, fetch, and activate.
  /// Call this in main() and await before runApp().
  static Future<void> initialize({
    Duration fetchTimeout = const Duration(seconds: 10),
  }) async {
    final remoteConfig = _remoteConfig;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: fetchTimeout,
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.setDefaults(<String, dynamic>{
      kRemoteConfigKeyAppLicenseKey: '',
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      // On failure, defaults apply (empty key = app stays locked)
    }
  }
}
