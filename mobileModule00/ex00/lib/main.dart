import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ex00',
      home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'A simple test',
            ),
            TextButton(
              onPressed: () {
                debugPrint('Button pressed');
              },
              child: const Text('Click me'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
