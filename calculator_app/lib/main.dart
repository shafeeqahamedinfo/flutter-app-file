import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

void main() {
  runApp(const CalculatorProApp());
}

class CalculatorProApp extends StatefulWidget {
  const CalculatorProApp({super.key});

  @override
  State<CalculatorProApp> createState() => _CalculatorProAppState();
}

class _CalculatorProAppState extends State<CalculatorProApp> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator Pro',
      debugShowCheckedModeBanner: false,
      theme: _isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: CalculatorHome(
        isDark: _isDark,
        onThemeToggle: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;
  const CalculatorHome({required this.isDark, required this.onThemeToggle, super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _expression = '';
  String _result = '';
  double _memory = 0.0;
  final List<String> _history = [];

  final TextStyle btnStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  final double _buttonSpacing = 8.0;

  void _append(String val) {
    setState(() {
      // avoid two operators in a row (simple guard)
      if (_expression.isNotEmpty && _isOperator(_expression[_expression.length - 1]) && _isOperator(val)) {
        // replace last operator
        _expression = _expression.substring(0, _expression.length - 1) + val;
      } else {
        _expression += val;
      }
    });
  }

  bool _isOperator(String s) {
    return "+-×÷*/^".contains(s) || s == '%' ;
  }

  void _clearAll() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _backspace() {
    if (_expression.isNotEmpty) {
      setState(() {
        _expression = _expression.substring(0, _expression.length - 1);
      });
    }
  }

  void _evaluate() {
    if (_expression.trim().isEmpty) return;
    try {
      String exp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '^')
          .replaceAll('π', '${math.pi}')
          .replaceAll('√', 'sqrt')
          .replaceAll('ln', 'ln')
          .replaceAll('log', 'log');

      Parser p = Parser();
      Expression parsed = p.parse(_prepareForParser(exp));
      ContextModel cm = ContextModel();
      double eval = parsed.evaluate(EvaluationType.REAL, cm);
      String resStr = _formatDouble(eval);

      setState(() {
        _result = resStr;
        _history.insert(0, '$_expression = $_result');
        if (_history.length > 50) _history.removeLast();
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  String _prepareForParser(String exp) {
    // math_expressions supports `sqrt(...)`, `log(...)` (natural log?), and `ln` isn't built-in.
    // We'll map some common functions:
    // ensure percent handling: replace 'number%' with '(number/100)'
    // naive percent handling: convert trailing % after a number or parenthesis
    String s = exp;
    // handle percent: e.g. 50% -> (50/100)
    s = s.replaceAllMapped(RegExp(r'(\d+(\.\d+)?)%'), (m) => '(${m[1]}/100)');
    // handle sqrt symbol usage like √9 or √(9) to sqrt(...)
    s = s.replaceAllMapped(RegExp(r'√\s*\('), (m) => 'sqrt(');
    s = s.replaceAllMapped(RegExp(r'√\s*(\d+(\.\d+)?)'), (m) => 'sqrt(${m[1]})');
    // add support for ln() using log() with base e: math_expressions has 'ln' as 'ln' operator often works,
    // but to be safe, keep ln as ln and allow parser to resolve.
    // Replace 'log(' with 'log10(' if user expects base-10; we will treat 'log' as natural log for simplicity.
    return s;
  }

  String _formatDouble(double v) {
    if (v.isInfinite || v.isNaN) return 'Error';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsPrecision(12).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _toggleSign() {
    setState(() {
      if (_expression.isEmpty) {
        _expression = '-';
        return;
      }
      // try to negate last number token
      var tokens = _tokenize(_expression);
      if (tokens.isNotEmpty) {
        String last = tokens.removeLast();
        // if last is number
        if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(last)) {
          if (last.startsWith('-')) last = last.substring(1);
          else last = '-$last';
        } else {
          // fallback: prepend '-(' and append ')'
          _expression = '-(' + _expression + ')';
          return;
        }
        _expression = tokens.join('') + last;
      }
    });
  }

  List<String> _tokenize(String exp) {
    // naive tokenizer splitting numbers and operators
    List<String> out = [];
    String buffer = '';
    for (int i = 0; i < exp.length; i++) {
      String ch = exp[i];
      if (RegExp(r'[\d\.]').hasMatch(ch)) {
        buffer += ch;
      } else {
        if (buffer.isNotEmpty) {
          out.add(buffer);
          buffer = '';
        }
        out.add(ch);
      }
    }
    if (buffer.isNotEmpty) out.add(buffer);
    return out;
  }

  void _clearEntry() {
    setState(() {
      _expression = '';
    });
  }

  void _memoryAdd() {
    try {
      double v = double.parse(_result.isEmpty ? '0' : _result);
      _memory += v;
      _showSnack('Added to memory: ${_formatDouble(v)}');
    } catch (e) {
      _showSnack('Nothing to add to memory');
    }
  }

  void _memorySub() {
    try {
      double v = double.parse(_result.isEmpty ? '0' : _result);
      _memory -= v;
      _showSnack('Subtracted from memory: ${_formatDouble(v)}');
    } catch (e) {
      _showSnack('Nothing to subtract from memory');
    }
  }

  void _memoryRecallClear() {
    setState(() {
      if (_memory == 0.0) {
        _showSnack('Memory is 0');
      } else {
        _expression += _formatDouble(_memory);
      }
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 700)));
  }

  // scientific helpers:
  void _applyUnary(String fn) {
    try {
      Parser p = Parser();
      Expression parsed = p.parse(_prepareForParser(_expression));
      ContextModel cm = ContextModel();
      double val = parsed.evaluate(EvaluationType.REAL, cm);
      double res;
      switch (fn) {
        case 'sin':
          res = math.sin(val);
          break;
        case 'cos':
          res = math.cos(val);
          break;
        case 'tan':
          res = math.tan(val);
          break;
        case 'asin':
          res = math.asin(val);
          break;
        case 'acos':
          res = math.acos(val);
          break;
        case 'atan':
          res = math.atan(val);
          break;
        case 'sqrt':
          res = math.sqrt(val);
          break;
        case '1/x':
          res = 1 / val;
          break;
        case 'x²':
          res = val * val;
          break;
        case 'ln':
          res = math.log(val);
          break;
        case 'log':
          res = math.log(val) / math.ln10;
          break;
        case '+/-':
          res = -val;
          break;
        default:
          res = val;
      }
      String resStr = _formatDouble(res);
      setState(() {
        _result = resStr;
        _history.insert(0, '$fn($_expression) = $_result');
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  Widget _buildButton(String label, {Color? color, VoidCallback? onTap, double? flex = 1}) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex!.toInt(),
      child: Padding(
        padding: EdgeInsets.all(_buttonSpacing / 2),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(18),
            backgroundColor: color ?? theme.colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: onTap ?? () => _onButtonPressed(label),
          child: Text(label, style: btnStyle),
        ),
      ),
    );
  }

  void _onButtonPressed(String label) {
    switch (label) {
      case 'C':
        _clearEntry();
        break;
      case 'AC':
        _clearAll();
        break;
      case '⌫':
        _backspace();
        break;
      case '=':
        _evaluate();
        break;
      case '+/-':
        _toggleSign();
        break;
      case '%':
        _append('%');
        break;
      case 'M+':
        _memoryAdd();
        break;
      case 'M-':
        _memorySub();
        break;
      case 'MRC':
        _memoryRecallClear();
        break;
      case 'sin':
      case 'cos':
      case 'tan':
      case 'sqrt':
      case 'x²':
      case '1/x':
      case 'ln':
      case 'log':
        _applyUnary(label);
        break;
      default:
        _append(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator Pro'),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Switch to light' : 'Switch to dark',
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display & history toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _expression.isEmpty ? '0' : _expression,
                            style: const TextStyle(fontSize: 26),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _result.isEmpty ? '' : 'Ans = $_result',
                            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // History
            if (_history.isNotEmpty)
              SizedBox(
                height: isPortrait ? 120 : 160,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) {
                    final item = _history[i];
                    return Dismissible(
                      key: Key(item + i.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => setState(() => _history.removeAt(i)),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            // reuse expression part before =
                            final parts = item.split('=');
                            if (parts.isNotEmpty) {
                              setState(() {
                                _expression = parts[0].trim();
                                _result = parts.length > 1 ? parts[1].trim() : '';
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Buttons
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Memory & percent row
                    Row(children: [
                      _buildButton('M+', color: null, onTap: () => _onButtonPressed('M+')),
                      _buildButton('M-', color: null, onTap: () => _onButtonPressed('M-')),
                      _buildButton('MRC', color: null, onTap: () => _onButtonPressed('MRC')),
                      _buildButton('(', color: null),
                      _buildButton(')', color: null),
                    ]),
                    const SizedBox(height: 4),
                    // scientific row
                    Row(children: [
                      _buildButton('sin', color: null, onTap: () => _onButtonPressed('sin')),
                      _buildButton('cos', color: null, onTap: () => _onButtonPressed('cos')),
                      _buildButton('tan', color: null, onTap: () => _onButtonPressed('tan')),
                      _buildButton('√', color: null, onTap: () => _onButtonPressed('sqrt')),
                      _buildButton('x²', color: null, onTap: () => _onButtonPressed('x²')),
                    ]),
                    const SizedBox(height: 4),
                    // row 1
                    Row(children: [
                      _buildButton('AC', color: null),
                      _buildButton('C', color: null),
                      _buildButton('⌫', color: null),
                      _buildButton('÷', color: null),
                      _buildButton('%', color: null),
                    ]),
                    const SizedBox(height: 4),
                    // row 2
                    Row(children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('×'),
                      _buildButton('1/x', color: null, onTap: () => _onButtonPressed('1/x')),
                    ]),
                    const SizedBox(height: 4),
                    // row 3
                    Row(children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-'),
                      _buildButton('ln', color: null, onTap: () => _onButtonPressed('ln')),
                    ]),
                    const SizedBox(height: 4),
                    // row 4
                    Row(children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+'),
                      _buildButton('log', color: null, onTap: () => _onButtonPressed('log')),
                    ]),
                    const SizedBox(height: 4),
                    // last row
                    Row(children: [
                      _buildButton('+/-', color: null),
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('=', color: Theme.of(context).colorScheme.primaryContainer, onTap: () => _onButtonPressed('=')),
                      _buildButton('^', color: null),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
