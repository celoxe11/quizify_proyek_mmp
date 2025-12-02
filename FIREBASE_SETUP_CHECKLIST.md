# 🚀 Firebase Authentication - Quick Start Checklist

Use this checklist to track your Firebase setup progress.

---

## Phase 1: Firebase Console Setup ☁️

- [v] Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [v] Add Flutter app to Firebase project
- [v] Enable Email/Password authentication
- [v] Enable Google Sign-In authentication
- [v] Download `google-services.json` (Android)
- [v] Download `GoogleService-Info.plist` (iOS)
- [ ] Copy Firebase config for Web
- [ ] Note down Firebase credentials:
  - [ ] API Key
  - [ ] Project ID
  - [ ] App ID
  - [ ] Messaging Sender ID
  - [ ] Google Client ID

---

## Phase 2: Database Setup 🗄️

- [ ] Backup existing MySQL database
- [ ] Run ALTER TABLE command to remove `password_hash`
- [ ] Run ALTER TABLE command to add `firebase_uid` column
- [ ] Add index on `firebase_uid` column
- [ ] Test database connection
- [ ] Verify table structure matches new schema

---

## Phase 3: Flutter Dependencies 📦

- [v] Add `firebase_core` to pubspec.yaml
- [v] Add `firebase_auth` to pubspec.yaml
- [v] Add `google_sign_in` to pubspec.yaml
- [v] Add `provider` to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Verify no dependency conflicts

---

## Phase 4: Android Configuration 🤖

- [ ] Place `google-services.json` in `android/app/`
- [ ] Update `android/build.gradle.kts` with Google Services plugin
- [ ] Update `android/app/build.gradle.kts`:
  - [ ] Add Google Services plugin
  - [ ] Set minSdk to 21
- [v] Add internet permission to `AndroidManifest.xml`
- [v] Get SHA-1 certificate fingerprint:
  ```bash
  cd android
  ./gradlew signingReport
  ```
- [v] Add SHA-1 to Firebase Console (Android app settings)
- [v] Test build: `flutter build apk --debug`

---

## Phase 5: iOS Configuration 🍎

- [ ] Place `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Update `ios/Runner/Info.plist` with URL schemes
- [ ] Get REVERSED_CLIENT_ID from `GoogleService-Info.plist`
- [ ] Add REVERSED_CLIENT_ID to URL schemes
- [ ] Update `ios/Podfile` (platform iOS 12.0 minimum)
- [ ] Run `cd ios && pod install && cd ..`
- [ ] Test build: `flutter build ios --debug`

---

## Phase 6: Web Configuration 🌐

- [ ] Update `web/index.html` with Firebase SDK
- [ ] Add Firebase config object to HTML
- [ ] Test on Chrome: `flutter run -d chrome`

---

## Phase 7: Firebase Configuration Files 📝

- [ ] Update `lib/core/config/firebase_config.dart` with your credentials:
  - [ ] API Key
  - [ ] App ID
  - [ ] Messaging Sender ID
  - [ ] Project ID
  - [ ] Auth Domain
  - [ ] Storage Bucket

---

## Phase 8: Backend API Setup 🔌

- [ ] Create backend API (Node.js/PHP/Python/etc.)
- [ ] Implement POST /api/users (create user)
- [ ] Implement GET /api/users/firebase/:firebaseUid
- [ ] Implement GET /api/users/email/:email
- [ ] Implement PUT /api/users/:userId
- [ ] Implement DELETE /api/users/:userId
- [ ] Implement GET /api/users/generate-id
- [ ] Test all endpoints with Postman/Thunder Client
- [ ] Deploy backend to server
- [ ] Update `lib/core/services/database_service.dart` with backend URL

---

## Phase 9: Code Integration 🧩

- [ ] Verify `lib/main.dart` initializes Firebase
- [ ] Verify `lib/main.dart` wraps app with MultiProvider
- [ ] Update login page to use AuthProvider
- [ ] Update register page to use AuthProvider
- [ ] Add logout functionality
- [ ] Add password reset feature
- [ ] Handle authentication state changes

---

## Phase 10: Testing 🧪

- [ ] Test email/password registration
- [ ] Test email/password login
- [ ] Test Google Sign-In
- [ ] Test logout
- [ ] Test password reset
- [ ] Test MySQL user creation
- [ ] Test Firebase-MySQL linking via firebase_uid
- [ ] Test error handling (wrong password, existing email, etc.)
- [ ] Test on Android device/emulator
- [ ] Test on iOS device/simulator (if available)
- [ ] Test on Web browser

---

## Phase 11: Security 🔒

- [ ] Add Firebase config files to `.gitignore`
- [ ] Set up Firebase Security Rules
- [ ] Enable App Check (optional but recommended)
- [ ] Implement rate limiting on backend
- [ ] Validate all user inputs
- [ ] Use HTTPS for all API calls
- [ ] Review and test authentication flows

---

## Phase 12: Deployment 🚀

- [ ] Build release version: `flutter build apk --release`
- [ ] Build iOS release: `flutter build ios --release`
- [ ] Build web release: `flutter build web --release`
- [ ] Test release builds
- [ ] Deploy backend API to production
- [ ] Update Firebase config for production
- [ ] Enable production authentication methods in Firebase

---

## Troubleshooting Checklist 🔧

If something doesn't work, check:

- [ ] Firebase is initialized before runApp()
- [ ] Google Services files are in correct locations
- [ ] Package versions are compatible
- [ ] minSdk is at least 21 (Android)
- [ ] Internet permissions are set
- [ ] Backend server is running and accessible
- [ ] Firebase credentials are correct
- [ ] SHA-1 certificate is added to Firebase (Android)
- [ ] URL schemes are correct (iOS)
- [ ] MySQL database connection is working

---

## Quick Commands 💻

```bash
# Install dependencies
flutter pub get

# Clean and rebuild
flutter clean
flutter pub get

# Run on device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Check for issues
flutter doctor

# Generate SHA-1 (Android)
cd android && ./gradlew signingReport && cd ..

# Install iOS pods
cd ios && pod install && cd ..
```

---

## 📞 Need Help?

- Check `FIREBASE_SETUP_GUIDE.md` for detailed instructions
- Review error messages carefully
- Check Firebase Console for authentication logs
- Verify backend API is responding correctly
- Test database connectivity

---

**Progress**: 0 / 12 phases complete

Update this checklist as you complete each step!
