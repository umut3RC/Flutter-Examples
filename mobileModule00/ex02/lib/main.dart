import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _value = 0;
  int _result = 0;

  void _numberController(int num) {
    setState(() {
      print('Button pressed: ' + num.toString());
      //_value += num;
    });
  }
  void _symbolController(String sym) {
    setState(() {
      print('Button pressed: ' + sym);
      //_counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                  _value.toString(),
                  textAlign: TextAlign.right,
              ),
              Text(_result.toString()),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextButton(
                      onPressed:() {_numberController(7);},
                      child: const Text('7'),
                    ),
                    TextButton(
                      onPressed:() {_numberController(8);},
                      child: const Text('8'),
                    ),
                    TextButton(
                      onPressed:() {_numberController(9);},
                      child: const Text('9'),
                    ),
                    TextButton(
                      onPressed:() {_symbolController('C');},
                      child: const Text('C'),
                    ),
                    TextButton(
                      onPressed:() {_symbolController('AC');},
                      child: const Text('AC'),
                    ),
                  ],

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextButton(
                      onPressed:() {_numberController(4);},
                      child: const Text('4'),
                    ),
                    TextButton(
                      onPressed:() {_numberController(5);},
                      child: const Text('5'),
                    ),
                    TextButton(
                      onPressed:() {_numberController(6);},
                      child: const Text('6'),
                    ),
                    TextButton(
                      onPressed:() {_symbolController('+');},
                      child: const Text('+'),
                    ),
                    TextButton(
                      onPressed:() {_symbolController('-');},
                      child: const Text('-'),
                    ),
                  ],

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextButton(
                      onPressed:() {_numberController(1);},
                      child: const Text('1'),
                    ),
                    TextButton(
                      onPressed:() {_numberController(2);},
                      child: const Text('2'),
                    ),
                    TextButton(
                      onPressed:() {_numberController(3);},
                      child: const Text('3'),
                    ),
                    TextButton(
                      onPressed:() {_symbolController('x');},
                      child: const Text('x'),
                    ),
                    TextButton(
                      onPressed:() {_symbolController('/');},
                      child: const Text('/'),
                    ),
                  ],

                ),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  TextButton(
                    onPressed:() {_numberController(0);},
                    child: const Text('0'),
                  ),
                  TextButton(
                    onPressed:() {_symbolController('.');},
                    child: const Text('.'),
                  ),
                  TextButton(
                    onPressed:() {_symbolController('00');},
                    child: const Text('00'),
                  ),
                  TextButton(
                    onPressed:() {_symbolController('=');},
                    child: const Text('='),
                  ),
                ],

              ),
              ]
            ),

          ],
        ),
      ),
    );
  }
}
