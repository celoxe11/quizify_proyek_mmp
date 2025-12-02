# quizify_proyek_mmp

A Multiplatform Quiz App with Flutter

## Cara Setup buat Development

**1. Buka Terminal**
```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=quizify-proyek-mmp
```

Ini akan menamnbahkan configurasi firebase (`google-services.json` di `android`)

*Seharusnya bisa nambahin `GoogleService-Info.plist` di ios, tapi entah kenapa gk bisa.*

Jadi kalau mau run di `ios` atau `macos`, tambahkan secara manual file `GoogleService-Info.plist` ke `ios/Runner`
Unduh filenya ada di:
- Firebase Console > Project Settings
- Scroll ke Your Apps
- Pilih Apple Apps
- Download `GoogleService-Info.plist`

**2. Install Dependecies**
```bash
flutter pub get
```
Catatan: Mohon sabar, nunggu errornya hilang agak lama

**3. Menambahkan fingerprint (SHA) untuk Google Sign-In**

Jalani ini terlebih dahulu untuk mendapatkan file-file gradlenya
```bash
flutter create . --platforms=android
```

Beberapa layanan Firebase (mis. Google Sign-In, Phone Auth, Dynamic Links) memerlukan fingerprint sertifikat aplikasi (SHA-1 dan SHA-256) agar fitur otentikasi berfungsi. Script `run-gradle-with-jdk.ps1` menjalankan Gradle `signingReport` menggunakan JDK 17 yang disediakan lokal (tanpa merubah `JAVA_HOME` sistem), lalu menampilkan fingerprint yang dipakai untuk menandatangani APK.

Jalankan perintah ini dari root proyek:
```powershell
cd android
.\run-gradle-with-jdk.ps1 signingReport
```

Salin nilai **SHA-1** dan **SHA-256** yang muncul di output, lalu tambahkan ke Firebase Console:
- Buka Firebase Console → Project settings → General → pada bagian "Your apps" pilih aplikasi Android → klik "Add fingerprint"
- Tempelkan **SHA-1** dan simpan; ulangi untuk **SHA-256**
- Setelah menambahkan fingerprint, unduh ulang `google-services.json` dari Firebase dan ganti file di `android/app/google-services.json`
- Rebuild aplikasi agar konfigurasi baru diterapkan

Catatan: Untuk build production gunakan fingerprint dari release keystore. Jika memakai Play App Signing, tambahkan fingerprint App signing certificate dari Play Console (bukan upload key). 



4. Jalankan backend, pull dari https://github.com/celoxe11/Quizify-Web-Service-Proyek-WS-
```bash
npm i
node seeder
```

``` bash
npm run dev 

// atau

npx nodemon index
```
