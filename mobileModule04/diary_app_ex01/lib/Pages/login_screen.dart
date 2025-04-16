import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<Widget> AddUserToFirebase(User _user) async {
    if (_user == null) {
      print("User is null!");
      return HomeScreen();
    }

    CollectionReference usersRef = FirebaseFirestore.instance.collection(
      'user',
    );

    // Aynı email ile kayıtlı kullanıcı var mı kontrol et
    QuerySnapshot existingUsers =
        await usersRef.where('email', isEqualTo: _user.email).limit(1).get();

    if (existingUsers.docs.isEmpty) {
      // Kullanıcı daha önce kaydedilmemiş, ekleyelim
      await usersRef.add({
        'DisplayName': _user.displayName,
        'email': _user.email,
      });
      print("Yeni kullanıcı kaydedildi.");
    } else {
      print("Kullanıcı zaten kayıtlı.");
    }

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
              await AddUserToFirebase(user);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else {
              print("User is null!");
            }
          },

          child: Text("Google ile Giriş Yap"),
        ),
      ),
    );
  }
}
