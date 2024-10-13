import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'm00-e00',
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
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
                print('Button pressed');
              },
              child: const Text('Click me'),
            ),
          ],
        ),
      ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
