import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Sayfa"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text("Welcome Home", style: TextStyle(fontSize: 24)),
            TextButton(
              onPressed: () {
                print("Yeni entry oluşturu verin gari");
              },
              child: Text("New Entry"),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //Tüm günlük girdileri al sırala
                  children: [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
