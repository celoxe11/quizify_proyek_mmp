# Firebase Authentication Setup - Complete Guide

## 📋 Overview

This guide provides a complete setup for Firebase Authentication in your Flutter project with MySQL database integration. Users are stored in both Firebase (for authentication) and MySQL (for application data).

## 🏗️ Architecture

- **Firebase**: Handles authentication and password storage
- **MySQL**: Stores user profile data and application-specific information
- **Link**: `firebase_uid` column in MySQL links the two systems

---

## ✅ Step-by-Step Implementation

### **Step 1: Firebase Console Setup**

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Enter project name (e.g., "quizify-app")
   - Follow the setup wizard

2. **Add Flutter App**
   - Click the Flutter icon
   - Register your app
   - Download configuration files:
     - **Android**: `google-services.json` → `android/app/`
     - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`
     - **Web**: Copy the config object

3. **Enable Authentication Methods**
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password**
   - Enable **Google Sign-In**
   - For Google: Download the OAuth client ID

---

### **Step 2: Update MySQL Database**

Run this SQL script to update your users table:

```sql
-- Add firebase_uid column and remove password_hash
ALTER TABLE `user` 
  DROP COLUMN `password_hash`,
  ADD COLUMN `firebase_uid` VARCHAR(128) UNIQUE DEFAULT NULL AFTER `email`,
  ADD INDEX `idx_firebase_uid` (`firebase_uid`);
```

**Final Schema:**
```sql
CREATE TABLE `user` (
  `id` VARCHAR(10) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `username` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `firebase_uid` VARCHAR(128) UNIQUE DEFAULT NULL,
  `role` ENUM('teacher','student') NOT NULL,
  `subscription_id` INT NOT NULL,
  `is_active` TINYINT(1) DEFAULT '1',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_firebase_uid` (`firebase_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

---

### **Step 3: Install Dependencies**

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  
  # Google Sign-In
  google_sign_in: ^6.1.6
  
  # HTTP & Database
  http: ^1.1.2
  mysql1: ^0.20.0
  
  # State Management
  provider: ^6.1.1
```

Then run:
```bash
flutter pub get
```

---

### **Step 4: Configure Firebase**

#### **Update `lib/core/config/firebase_config.dart`**

Replace with your Firebase credentials:

```dart
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'YOUR_API_KEY',
        appId: 'YOUR_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
        storageBucket: 'YOUR_PROJECT_ID.appspot.com',
      ),
    );
  }
}
```

---

### **Step 5: Android Configuration**

#### **1. Update `android/build.gradle.kts`**

Add Google Services plugin:

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
        classpath("com.google.gms:google-services:4.4.0")  // Add this
    }
}
```

#### **2. Update `android/app/build.gradle.kts`**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Add this
}

android {
    namespace = "com.yourcompany.quizify_proyek_mmp"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yourcompany.quizify_proyek_mmp"
        minSdk = 21  // Firebase requires minimum SDK 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
}
```

#### **3. Add `google-services.json`**

Place the downloaded `google-services.json` file in `android/app/`

#### **4. Update `android/app/src/main/AndroidManifest.xml`**

Add internet permission:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="Quizify"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Your existing configuration -->
    </application>
</manifest>
```

---

### **Step 6: iOS Configuration**

#### **1. Add `GoogleService-Info.plist`**

Place the downloaded file in `ios/Runner/`

#### **2. Update `ios/Runner/Info.plist`**

Add URL schemes for Google Sign-In:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>

<key>GIDClientID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>
```

#### **3. Update Podfile**

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

Then run:
```bash
cd ios
pod install
cd ..
```

---

### **Step 7: Web Configuration**

#### **Update `web/index.html`**

Add Firebase SDK scripts before the closing `</body>` tag:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quizify</title>
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
  
  <!-- Firebase Configuration -->
  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
    import { getAuth } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";
    
    const firebaseConfig = {
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_PROJECT_ID.appspot.com",
      messagingSenderId: "YOUR_SENDER_ID",
      appId: "YOUR_APP_ID"
    };
    
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
  </script>
</body>
</html>
```

---

### **Step 8: Backend API Setup**

Create a Node.js/PHP/Python backend with these endpoints:

#### **Required API Endpoints:**

1. **POST /api/users** - Create new user
2. **GET /api/users/firebase/:firebaseUid** - Get user by Firebase UID
3. **GET /api/users/email/:email** - Get user by email
4. **PUT /api/users/:userId** - Update user
5. **DELETE /api/users/:userId** - Delete user
6. **GET /api/users/generate-id** - Generate unique user ID

#### **Example Node.js Implementation:**

```javascript
const express = require('express');
const mysql = require('mysql2/promise');
const app = express();

app.use(express.json());

// MySQL connection
const pool = mysql.createPool({
  host: 'localhost',
  user: 'your_user',
  password: 'your_password',
  database: 'your_database',
  waitForConnections: true,
  connectionLimit: 10
});

// Create user
app.post('/api/users', async (req, res) => {
  try {
    const { id, name, username, email, firebase_uid, role, subscription_id } = req.body;
    
    const [result] = await pool.execute(
      'INSERT INTO user (id, name, username, email, firebase_uid, role, subscription_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, name, username, email, firebase_uid, role, subscription_id]
    );
    
    res.status(201).json({ ...req.body, created_at: new Date(), updated_at: new Date() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user by Firebase UID
app.get('/api/users/firebase/:firebaseUid', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM user WHERE firebase_uid = ?',
      [req.params.firebaseUid]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Generate unique ID
app.get('/api/users/generate-id', async (req, res) => {
  const id = 'U' + Date.now().toString().slice(-9);
  res.json({ id });
});

app.listen(3000, () => console.log('API running on port 3000'));
```

---

### **Step 9: Update Database Service URL**

In `lib/core/services/database_service.dart`, replace:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
```

With your actual backend URL:
- **Local**: `http://localhost:3000/api`
- **Production**: `https://your-api.com/api`

---

## 📱 Usage Examples

### **Example 1: Login Screen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.signIn(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  
                  if (success && mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (authProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authProvider.error!)),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Sign in with Google'),
              onPressed: () async {
                final success = await authProvider.signInWithGoogle(role: 'student');
                
                if (success && mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### **Example 2: Registration Screen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            
            DropdownButton<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            
            const SizedBox(height: 20),
            
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.register(
                    name: _nameController.text,
                    username: _usernameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    role: _selectedRole,
                  );
                  
                  if (success && mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (authProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authProvider.error!)),
                    );
                  }
                },
                child: const Text('Register'),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔒 Security Best Practices

1. **Never commit Firebase config files** to version control
   - Add to `.gitignore`:
     ```
     android/google-services.json
     ios/GoogleService-Info.plist
     lib/core/config/firebase_config.dart
     ```

2. **Use environment variables** for sensitive data
3. **Enable Firebase Security Rules**
4. **Implement rate limiting** on your backend API
5. **Validate all inputs** on both client and server side
6. **Use HTTPS** for all API calls

---

## 🧪 Testing

```bash
# Test Firebase connection
flutter run

# Test authentication flow
# 1. Register a new user
# 2. Sign out
# 3. Sign in with same credentials
# 4. Try Google Sign-In
```

---

## 🐛 Troubleshooting

### **Error: MissingPluginException**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
cd ios && pod install && cd ..
flutter run
```

### **Error: Google Sign-In not working**
- Verify SHA-1 and SHA-256 certificates are added in Firebase Console
- Check that `google-services.json` is up to date

### **Error: API connection failed**
- Check backend URL in `database_service.dart`
- Ensure backend server is running
- Verify network permissions in AndroidManifest.xml

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)

---

## 📝 Notes

- Passwords are **only stored in Firebase**, not in MySQL
- MySQL stores the `firebase_uid` to link accounts
- For password reset, use Firebase's built-in functionality
- The `subscription_id` field can be used for premium features

---

**Created by:** GitHub Copilot  
**Last Updated:** November 24, 2025
