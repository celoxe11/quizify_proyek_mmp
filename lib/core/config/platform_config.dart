import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform-aware configuration for API base URLs.
///
/// Supports compile-time environment variables via --dart-define:
/// - API_BASE_URL: Override for any platform
/// - API_ENV: Set to 'dev', 'staging', or 'prod' for predefined URLs
///
/// Example usage:
/// ```bash
/// # Development (auto-detects platform)
/// flutter run
///
/// # Staging environment
/// flutter run --dart-define=API_ENV=staging
///
/// # Production with custom URL
/// flutter run --dart-define=API_BASE_URL=https://api.yourapp.com/api
///
/// # Android release build for production
/// flutter build apk --dart-define=API_ENV=prod
/// ```
class PlatformConfig {
  /// Gets the appropriate base URL based on platform and environment.
  static String getBaseUrl() {
    // 1. Check for explicit base URL override
    const explicitUrl = String.fromEnvironment('API_BASE_URL');
    if (explicitUrl.isNotEmpty) {
      return explicitUrl;
    }

    // 2. Check for environment (dev/staging/prod)
    const environment = String.fromEnvironment('API_ENV', defaultValue: 'dev');

    switch (environment) {
      case 'prod':
      case 'production':
        if (kIsWeb) {
          // Web: Use relative path (Firebase Hosting will rewrite to Cloud Function)
          return '/api';
        }
        // Mobile: Use direct Cloud Function URL
        return 'https://asia-southeast2-proyek-mmp-484808.cloudfunctions.net/api';

      case 'staging':
        if (kIsWeb) {
          return '/api';
        }
        return 'https://asia-southeast2-proyek-mmp-484808.cloudfunctions.net/api';

      case 'dev':
      case 'development':
      default:
        // Development: auto-detect platform
        return _getDevBaseUrl();
    }
  }

  /// Returns the appropriate development base URL based on the platform.
  static String _getDevBaseUrl() {
    if (kIsWeb) {
      // Web: use localhost
      return 'http://localhost:3000/api';
    }

    // Mobile/Desktop: check platform
    if (Platform.isAndroid) {
      // For physical devices, use LOCAL_IP environment variable
      // Example: flutter run --dart-define=LOCAL_IP=192.168.1.100
      const localIp = String.fromEnvironment('LOCAL_IP');
      if (localIp.isNotEmpty) {
        return 'http://$localIp:3000/api';
      }

      // For emulator: use 10.0.2.2 (requires backend to listen on 0.0.0.0)
      // Note: If using ADB reverse (adb reverse tcp:3000 tcp:3000), you can use localhost
      return 'http://10.0.2.2:3000/api';
    }

    // iOS simulator, macOS, Windows, Linux: use localhost
    return 'http://localhost:3000/api';
  }

  /// Current environment name (useful for debugging)
  static String get environment {
    const env = String.fromEnvironment('API_ENV', defaultValue: 'dev');
    return env;
  }

  /// Whether running in production mode
  static bool get isProduction {
    const env = String.fromEnvironment('API_ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
}
