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
        // TODO: Replace with your production URL
        return 'https://api.yourapp.com/api';

      case 'staging':
        // TODO: Replace with your staging URL
        return 'https://staging-api.yourapp.com/api';

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
      // Android emulator uses 10.0.2.2 to reach host machine
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
