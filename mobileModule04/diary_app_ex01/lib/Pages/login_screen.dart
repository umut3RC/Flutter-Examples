import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen NagivateToHomePage(final _user)
  {
    CollectionReference collRef = FirebaseFirestore.instance.collection('user');
    collRef.add(
      {
        'DisplayName': _user.displayName,
        'email': _user.email,
      }
    );
    return HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await _authService.signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NagivateToHomePage(user)),
              );
            }
            else
              {
                print("User is null!");
              }
          },
          child: Text("Google ile Giriş Yap"),
        ),
      ),
    );
  }
}
