import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  TextEditingController _controller = TextEditingController();
  String _currentInput = '';
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Masukkan Angka',
              ),
              onChanged: (value) {
                setState(() {
                  _currentInput = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCalcButton('7'),
                buildCalcButton('8'),
                buildCalcButton('9'),
                buildCalcButton('/'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCalcButton('4'),
                buildCalcButton('5'),
                buildCalcButton('6'),
                buildCalcButton('*'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCalcButton('1'),
                buildCalcButton('2'),
                buildCalcButton('3'),
                buildCalcButton('-'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCalcButton('0'),
                buildCalcButton('C', textColor: Colors.red),
                buildCalcButton('=', textColor: Colors.green),
                buildCalcButton('+'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '$_currentInput',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Hasil: $_result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCalcButton(String text, {Color? textColor}) {
    return ElevatedButton(
      onPressed: () {
        onButtonPressed(text);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          color: textColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        shape: CircleBorder(),
      ),
    );
  }

  void onButtonPressed(String buttonText) {
    if (buttonText == '=') {
      calculate();
    } else if (buttonText == 'C') {
      clear();
    } else {
      appendToInput(buttonText);
    }
  }

  void calculate() {
    try {
      Parser parser = Parser();
      Expression expression = parser.parse(_currentInput);
      _result = expression.evaluate(EvaluationType.REAL, ContextModel()).toString();
      setState(() {});
    } catch (e) {
      _result = 'Error';
      setState(() {});
    }
  }

  void clear() {
    _controller.clear();
    _currentInput = '';
    _result = '';
    setState(() {});
  }

  void appendToInput(String text) {
    _currentInput += text;
    setState(() {});
  }
}
