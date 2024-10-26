import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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
  double _result = 0;
  String _showVal = '0';
  bool _canPoint = true;

  void _numberController(int num) {
    setState(() {
      debugPrint('Button pressed: $num');
      if (_showVal == '0') {
        _showVal = num.toString();
      } else {
        _showVal += num.toString();
      }
    });
  }

  void _symbolController(String sym) {
    setState(() {
      debugPrint('Button pressed: $sym');
      if (sym == 'AC') {
        _showVal = '0';
        _result = 0;
        _canPoint = true;
      } else if (sym == 'C') {
        if (_showVal[_showVal.length - 1] == '.') {
          _canPoint = true;
        }
        if (_showVal.length > 1) {
          _showVal = _showVal.substring(0, _showVal.length - 1);
        } else {
          _showVal = '0';
        }
      } else if (sym == '00') {
        if ((_showVal != '0' &&
                int.tryParse(_showVal[_showVal.length - 1]) != null) ||
            _showVal[_showVal.length - 1] == '.') {
          _showVal += '00';
        }
      } else if (int.tryParse(_showVal[_showVal.length - 1]) != null) {
        if (sym == '=') {
          _result = GetTotalResult();
        } else {
          if (sym == '.') {
            if (_canPoint) {
              _showVal += sym;
            }
            _canPoint = false;
          } else {
            _canPoint = true;
            _showVal += sym;
          }
        }
      } else if (sym == '-') {
        if (_showVal[_showVal.length - 1] != '.' &&
            int.tryParse(_showVal[_showVal.length - 2]) != null) {
          _showVal += sym;
        }
      }
    });
  }

  double GetTotalResult() {
    try {
      String realString = _showVal.replaceAll('x', '*');
      Parser parser = Parser();
      Expression exp = parser.parse(realString);

      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      return result;
    } catch (e) {
      debugPrint("Error: $e");
      return 0.0;
    }
  }

  String GetResultString() {
    String retRes = '';
    if (_result == 0.0) //_result == 0.0 ? '0' : _result.toString(),
    {
      retRes = '0';
    } else if (_result == double.infinity || _result.isNaN) {
      retRes = 'Undefined';
    } else {
      // String formattedNumber = number.toStringAsFixed(20);
      retRes = _result.toString();
      // retRes = _result.toStringAsFixed(20);
    }
    return (retRes);
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

  /*
  double GetTotalResult()
  {
    double num1 = 0;
    double num2 = 0;

    String lastSyms = '';
    bool  inPoint = false;
    double pointFactor = 10.0;
    bool  willNegative = false;

    if (int.tryParse(_showVal[_showVal.length - 1]) == null)
    {
      _showVal = _showVal.substring(0, _showVal.length - 1);
    }
    for (int i = 0; i < _showVal.length; i++)
    {
      if (int.tryParse(_showVal[i]) != null)// sayı ekle
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
        if (willNegative)
        {
          num1 *= -1;
          willNegative = false;
        debugPrint('-->>>' + num1.toString());
        }
      }
      else if (_showVal[i] == '-' && _showVal[i - 1] != '.' && int.tryParse(_showVal[i - 1]) == null)
      {
        willNegative = true;
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
  */

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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            _showVal,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            GetResultString(),
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