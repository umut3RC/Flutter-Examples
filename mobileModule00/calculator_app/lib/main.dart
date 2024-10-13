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
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
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
  String _showVal = '0';

  void _numberController(int num) {
    setState(() {
      print('Button pressed: ' + num.toString());
      //_value += num;
      //_value *= 10;
      // _value += num;
      if (_showVal == '0')
        _showVal = num.toString();
      else
        _showVal += num.toString();
    });
  }
  void _symbolController(String sym) {
    setState(() {
      print('Button pressed: ' + sym);
      if (sym == 'AC')
      {
        _value = 0;
        _showVal = '0';
        _result = 0;
      }
      else if (sym == 'C')
      {
        _value = 0;
        _showVal = _result.toString();
      }
      else if (int.tryParse(_showVal[_showVal.length - 1]) != null)
      {
        if (sym == '=')
        {
          _result = GetTotalResult();
          print ('res:' + _result.toString());
        }
        else
          _showVal += sym;
      }
    });
  }

  int GetTotalResult()
  {
    int num1 = 0;
    int num2 = 0;
    String lastSyms = '';

    if (int.tryParse(_showVal[_showVal.length - 1]) == null)
    {
      _showVal = _showVal.substring(0, _showVal.length - 1);
      print('yep' + _showVal);
    }
    for (int i = 0; i < _showVal.length; i++)
    {
      if (int.tryParse(_showVal[i]) != null)// sayı direk ekle
          {
        num1 *= 10;
        num1 += int.parse(_showVal[i]);
      }
      else//sayı değil işlem
          {
        if (lastSyms != '')
        {
          num2 = UseSymbol(lastSyms, num1, num2);
          num1 = 0;
          lastSyms = _showVal[i];
        }
        else
        {
          lastSyms = _showVal[i];
          num2 = num1;
          num1 = 0;
        }
      }
    }
    num2 = UseSymbol(lastSyms, num1, num2);
    return (num2);
  }
  int UseSymbol(String sym, int num1, int num2)
  {
    switch(sym)
    {
      case '+':
        return num1 + num2;
      case '-':
        return num1 - num2;
      case 'x':
        return num1 * num2;
      case '/':
        return (num1 / num2).round();
      default:
        return 0;
    }
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
                  _showVal,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _result.toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
