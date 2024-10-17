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
  double _result = 0;
  String _showVal = '0';
  bool _canPoint = true;

  void _numberController(int num) {
    setState(() {
      print('Button pressed: ' + num.toString());
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
        _showVal = '0';
        _result = 0;
        _canPoint = true;
      }
      else if (sym == 'C')
      {
        if (_showVal[_showVal.length - 1] == '.')
        {
          _canPoint = true;
        }
        if (_showVal.length > 1)
        {
          _showVal = _showVal.substring(0, _showVal.length - 1);
        }
        else
        {
          _showVal = '0';
        }
      }
      else if (sym == '00')
      {
        if ((_showVal != '0' && int.tryParse(_showVal[_showVal.length - 1]) != null)
            || _showVal[_showVal.length - 1] == '.')
        {
          _showVal += '00';
        }
      }
      else if (int.tryParse(_showVal[_showVal.length - 1]) != null)
      {
        if (sym == '=')
        {
          _result = GetTotalResult();
        }
        else
        {
          if (sym == '.')
          {
            if (_canPoint)
            {
              _showVal += sym;
            }
            _canPoint = false;
          }
          else
          {
            _canPoint = true;
            _showVal += sym;
          }
        }
      }
    });
  }

  double GetTotalResult()
  {
    double num1 = 0;
    double num2 = 0;
    String lastSyms = '';
    bool  inPoint = false;
    double pointFactor = 10.0;

    if (int.tryParse(_showVal[_showVal.length - 1]) == null)
    {
      _showVal = _showVal.substring(0, _showVal.length - 1);
    }
    for (int i = 0; i < _showVal.length; i++)
    {
      if (int.tryParse(_showVal[i]) != null)// sayı direk ekle
      {
        if (inPoint)
        {
          num1 = num1 + (int.parse(_showVal[i]) / pointFactor);
          pointFactor *= 10.0;
        }
        else
        {
          num1 *= 10;
          num1 += int.parse(_showVal[i]);
        }
      }
      else if (_showVal[i] == '.')
      {
        inPoint = true;
      }
      else//sayı değil işlem
      {
        if (lastSyms != '')
        {
          num2 = UseSymbol(lastSyms, num1, num2);
          lastSyms = _showVal[i];
        }
        else
        {
          lastSyms = _showVal[i];
          num2 = num1;
        }
        num1 = 0;
        inPoint = false;
        pointFactor = 10.0;
      }
    }
    num2 = UseSymbol(lastSyms, num1, num2);
    return (num2);
  }
  double UseSymbol(String sym, double num1, double num2)
  {
    switch(sym)
    {
      case '+':
        return num2 + num1;
      case '-':
        return num2 - num1;
      case 'x':
        return num2 * num1;
      case '/':
        return (num2 / num1);
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
                  _result == 0.0 ? '0' : _result.toString(),
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
