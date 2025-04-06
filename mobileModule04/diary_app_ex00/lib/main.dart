import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './Pages/login_screen.dart';
import './Pages/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBgbzaE7YleubYfvShboRC78hXQvZVdxb8",
      authDomain: "mydiaryapp-dae19.firebaseapp.com",
      projectId: "mydiaryapp-dae19",
      storageBucket: "mydiaryapp-dae19.firebasestorage.app",
      messagingSenderId: "571533552963",
      appId: "1:571533552963:web:d956e25eb067adfbf613f6",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return HomeScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
