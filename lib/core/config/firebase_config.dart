import 'package:firebase_core/firebase_core.dart';
import 'package:quizify_proyek_mmp/firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    // Check if Firebase is already initialized to prevent duplicate app error
    // This is especially important during hot reload in development
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}
