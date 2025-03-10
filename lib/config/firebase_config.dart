// Manual Firebase configuration until FlutterFire CLI is working
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static FirebaseOptions get platformOptions {
    // Your web config from Firebase Console
    return const FirebaseOptions(
      apiKey: "AIzaSyCGUTIYykMbqk0TbICAbR7aOuQqLmtMMhk",
      authDomain: "coinbox-85b0f.firebaseapp.com",
      projectId: "coinbox-85b0f",
      storageBucket: "coinbox-85b0f.firebasestorage.app",
      messagingSenderId: "290828526825",
      appId: "1:290828526825:web:eddda23f57a128afb03c78"
    );
  }
}
