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

  void _numberController(int num) {
    setState(() {
      debugPrint('Button pressed: $num');
    });
  }

  void _symbolController(String sym) {
    setState(() {
      debugPrint('Button pressed: $sym');
    });
  }

  Widget GetMyButton(String showText, bool isSymbol, Color btnColor) {
    if (showText == '') {
      return (Expanded(
        child: TextButton(
          onPressed: () {},
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: const Text(''),
        ),
      ));
    }
    return (Expanded(
      child: TextButton(
        onPressed: () {
          if (isSymbol) {
            _symbolController(showText);
          } else {
            _numberController(int.parse(showText));
          }
        },
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(Colors.blueGrey),
        ),
        child: Text(
          showText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 42,
            color: btnColor,
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey[900],
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title:
              const Text('Calculator', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          children: [
           const  Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '0',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                            style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 42),
                          ),
                        ),
                      ],
                    ),
                    //SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '0',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 42),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                color: Colors.blueGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetMyButton('7', false, Colors.blueGrey[900]!),
                          GetMyButton('8', false, Colors.blueGrey[900]!),
                          GetMyButton('9', false, Colors.blueGrey[900]!),
                          GetMyButton('C', true, Colors.red),
                          GetMyButton('AC', true, Colors.red),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetMyButton('4', false, Colors.blueGrey[900]!),
                          GetMyButton('5', false, Colors.blueGrey[900]!),
                          GetMyButton('6', false, Colors.blueGrey[900]!),
                          GetMyButton('+', true, Colors.white),
                          GetMyButton('-', true, Colors.white),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetMyButton('1', false, Colors.blueGrey[900]!),
                          GetMyButton('2', false, Colors.blueGrey[900]!),
                          GetMyButton('3', false, Colors.blueGrey[900]!),
                          GetMyButton('x', true, Colors.white),
                          GetMyButton('/', true, Colors.white),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetMyButton('0', false, Colors.blueGrey[900]!),
                          GetMyButton('.', true, Colors.blueGrey[900]!),
                          GetMyButton('00', true, Colors.blueGrey[900]!),
                          GetMyButton('=', true, Colors.white),
                          GetMyButton('', false, Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}