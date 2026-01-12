# Backend Connection Guide

This guide explains how to connect your Flutter app to the backend on different devices.

## Prerequisites

**Important**: Your backend server must listen on `0.0.0.0` instead of `localhost` or `127.0.0.1`:

```javascript
// In your backend server file (server.js, app.js, etc.)
app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:3000');
});
```

## Running on Android Emulator

The app is already configured to use `10.0.2.2:3000` for Android emulators.

**Just run:**
```bash
flutter run
```

**Optional - Using ADB Reverse (if 10.0.2.2 doesn't work):**
```bash
adb reverse tcp:3000 tcp:3000
flutter run
```

## Running on Physical Android Device

Your PC's local IP: **192.168.137.1**

**Steps:**

1. **Connect your phone and PC to the same WiFi network**

2. **Check your PC's local IP** (if different from above):
   ```powershell
   ipconfig
   # Look for "IPv4 Address" under your active network adapter
   ```

3. **Run the app with LOCAL_IP:**
   ```bash
   flutter run --dart-define=LOCAL_IP=192.168.137.1
   ```

4. **Allow firewall access** if prompted on your PC
ipconfig
## Running on iOS Simulator

```bash
flutter run
# Uses localhost:3000 automatically
```

## Production Deployment

For production, use environment variables:

```bash
# Staging
flutter run --dart-define=API_ENV=staging

# Production
flutter build apk --dart-define=API_ENV=prod

# Custom URL
flutter run --dart-define=API_BASE_URL=https://your-api.com/api
```

## Troubleshooting

### "Request timeout" error

1. **Check backend is running:**
   ```bash
   curl http://localhost:3000/api/check-google-user/test
   ```

2. **For physical device:**
   - Ensure phone and PC are on same WiFi
   - Check PC firewall allows port 3000
   - Verify PC's IP hasn't changed
   - Try: `flutter run --dart-define=LOCAL_IP=YOUR_IP_HERE`

3. **For emulator:**
   - Ensure backend listens on `0.0.0.0`
   - Try ADB reverse: `adb reverse tcp:3000 tcp:3000`

### Backend not accessible

**Check if backend is listening on correct interface:**
```bash
# On your PC, this should show 0.0.0.0:3000 or *:3000
netstat -ano | findstr :3000
```

### Finding your current IP

```powershell
# Windows
ipconfig

# Or use this command:
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "127.*" }
```

## Quick Reference

| Scenario | Command |
|----------|---------|
| Android Emulator | `flutter run` |
| Physical Phone | `flutter run --dart-define=LOCAL_IP=192.168.137.1` |
| iOS Simulator | `flutter run` |
| Web | `flutter run -d chrome` |
| Staging Environment | `flutter run --dart-define=API_ENV=staging` |
| Production Build | `flutter build apk --dart-define=API_ENV=prod` |
