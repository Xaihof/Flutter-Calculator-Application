import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _displayText = '';
  bool _lastWasResult = false; // Track if the last entry was a result

  void _clear() {
    setState(() {
      _displayText = '';
      _lastWasResult = false; // Reset the flag
    });
  }

  void _delete() {
    setState(() {
      if (_displayText.isNotEmpty) {
        _displayText = _displayText.substring(0, _displayText.length - 1);
      }
    });
  }

  void _appendToExpression(String symbol) {
    setState(() {
      if (_lastWasResult) {
        if ('0123456789'.contains(symbol)) {
          // If the user starts with a number after the result, we replace the display
          _displayText = symbol;
        } else {
          // If the user starts with an operator after the result, append it
          _displayText += symbol;
        }
        _lastWasResult = false; // Reset the flag after using the result
      } else {
        // Handle percentage
        if (symbol == '%') {
          // Find the last number in the expression and convert it to a percentage
          String lastNumber = _getLastNumber();
          if (lastNumber.isNotEmpty) {
            double value = double.parse(lastNumber) / 100;
            _displayText = _displayText.substring(
                    0, _displayText.length - lastNumber.length) +
                value.toString();
          }
        } else {
          // Prevent appending multiple operators in a row
          if (_displayText.isNotEmpty) {
            if ('+-*/'.contains(symbol) &&
                '+-*/'.contains(_displayText[_displayText.length - 1])) {
              return; // Don't allow consecutive operators
            }
          }
          // Prevent multiple decimal points in the same number
          if (symbol == '.' && _displayText.isNotEmpty) {
            String lastNumber = _getLastNumber();
            if (lastNumber.contains('.')) {
              return; // Don't allow another decimal point in the same number
            }
          }
          _displayText += symbol;
        }
      }
    });
  }

  String _getLastNumber() {
    // Get the last number in the current expression
    List<String> parts = _displayText.split(RegExp(r'[\+\-\*\/]'));
    return parts.isNotEmpty ? parts.last : '';
  }

  void _calculate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_displayText);
      ContextModel cm = ContextModel();
      setState(() {
        double result = exp.evaluate(EvaluationType.REAL, cm);
        _displayText = result.toStringAsFixed(2); // Limit to 2 decimal places
        _lastWasResult = true; // Mark that the last action was a result
      });
    } catch (e) {
      setState(() {
        _displayText = 'Error';
        _lastWasResult = false; // Reset on error
      });
    }
  }

  Widget _buildButton(
    String buttonText,
    Color buttonColor,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(3.5),
      child: InkWell(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
              child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 21,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )),
        ),
        onTap: () {
          onPressed();
        },
      ),
    );
  }

  Widget _buildButtonGrid() {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      children: [
        _buildButton("7", Colors.red, () => _appendToExpression("7")),
        _buildButton("8", Colors.red, () => _appendToExpression("8")),
        _buildButton("9", Colors.red, () => _appendToExpression("9")),
        _buildButton("AC", Colors.blue, _clear),
        _buildButton("C", Colors.blue, _delete),
        _buildButton("4", Colors.red, () => _appendToExpression("4")),
        _buildButton("5", Colors.red, () => _appendToExpression("5")),
        _buildButton("6", Colors.red, () => _appendToExpression("6")),
        _buildButton("x", Colors.blue, () => _appendToExpression("*")),
        _buildButton("/", Colors.blue, () => _appendToExpression("/")),
        _buildButton("1", Colors.red, () => _appendToExpression("1")),
        _buildButton("2", Colors.red, () => _appendToExpression("2")),
        _buildButton("3", Colors.red, () => _appendToExpression("3")),
        _buildButton("+", Colors.blue, () => _appendToExpression("+")),
        _buildButton("-", Colors.blue, () => _appendToExpression("-")),
        _buildButton("0", Colors.red, () => _appendToExpression("0")),
        _buildButton("00", Colors.red, () => _appendToExpression("00")),
        _buildButton(".", Colors.red, () => _appendToExpression(".")),
        _buildButton("%", Colors.blue, () => _appendToExpression("%")),
        _buildButton("=", Colors.blue, _calculate),
        _buildButton("Save", Colors.blue, _clear),
      ],
    );
  }

  Widget _buildOutput() {
    return Padding(
      padding: const EdgeInsets.all(3.5),
      child: Container(
        width: double.maxFinite,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 7.0),
          child: Text(
            _displayText,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculator")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  children: [
                    _buildOutput(),
                    _buildButtonGrid(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
