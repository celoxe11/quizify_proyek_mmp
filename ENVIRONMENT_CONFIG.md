# Environment Configuration Guide

This project uses Flutter's `--dart-define` for environment-specific configuration (similar to .env files).

## Quick Start

### Development (Auto-detects platform)
```bash
# Android emulator -> http://10.0.2.2:3000/api
# iOS/Web/Desktop -> http://localhost:3000/api
flutter run
```

### Staging Environment
```bash
flutter run --dart-define=API_ENV=staging
```

### Production Environment
```bash
flutter run --dart-define=API_ENV=prod
```

### Custom API URL
```bash
flutter run --dart-define=API_BASE_URL=https://custom-api.com/api
```

## Platform-Specific URLs

The app automatically detects your platform:

| Platform | Default Dev URL |
|----------|----------------|
| Android Emulator | `http://10.0.2.2:3000/api` |
| iOS Simulator | `http://localhost:3000/api` |
| Web | `http://localhost:3000/api` |
| Desktop | `http://localhost:3000/api` |

## Building for Production

### Android APK
```bash
flutter build apk --dart-define=API_ENV=prod
```

### Android App Bundle
```bash
flutter build appbundle --dart-define=API_ENV=prod
```

### iOS
```bash
flutter build ipa --dart-define=API_ENV=prod
```

### Web
```bash
flutter build web --dart-define=API_ENV=prod
```

## Configuration File

Edit `lib/core/config/platform_config.dart` to set your environment URLs:

```dart
case 'prod':
  return 'https://api.yourapp.com/api';  // Your production URL

case 'staging':
  return 'https://staging-api.yourapp.com/api';  // Your staging URL
```

## VS Code Launch Configuration

Add to `.vscode/launch.json` for easy environment switching:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart"
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=API_ENV=staging"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=API_ENV=prod"]
    }
  ]
}
```

## Android Studio / IntelliJ

1. Run → Edit Configurations
2. Add `--dart-define=API_ENV=prod` to "Additional run args"
3. Save as a new configuration

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `API_ENV` | Environment name | `dev`, `staging`, `prod` |
| `API_BASE_URL` | Override base URL | `https://api.example.com/api` |

## Tips

- **No .env file needed**: Flutter compiles the values at build time
- **Secure**: Values are compiled into the binary (not in plain text files)
- **Multiple environments**: Create different build configurations for each environment
- **CI/CD friendly**: Pass `--dart-define` in your build scripts

## Example CI/CD (GitHub Actions)

```yaml
- name: Build APK (Production)
  run: flutter build apk --dart-define=API_ENV=prod --release
```
