import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: "AIzaSyBgbzaE7YleubYfvShboRC78hXQvZVdxb8",
      authDomain: "mydiaryapp-dae19.firebaseapp.com",
      projectId: "mydiaryapp-dae19",
      storageBucket: "mydiaryapp-dae19.firebasestorage.app",
      messagingSenderId: "571533552963",
      appId: "1:571533552963:web:d956e25eb067adfbf613f6"
    );
  }
}


// WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp(
//   options: FirebaseOptions(
//       apiKey: "AIzaSyBgbzaE7YleubYfvShboRC78hXQvZVdxb8",
//       authDomain: "mydiaryapp-dae19.firebaseapp.com",
//       projectId: "mydiaryapp-dae19",
//       storageBucket: "mydiaryapp-dae19.firebasestorage.app",
//       messagingSenderId: "571533552963",
//       appId: "1:571533552963:web:d956e25eb067adfbf613f6"
//   ),
// );