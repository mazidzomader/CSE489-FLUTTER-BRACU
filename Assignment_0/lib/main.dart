import 'dart:math';
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Assignment 00 [24241189]'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _score = 0;
  int _num1 = 0;
  int _num2 = 0;
  String _feedbackMessage = '';
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNumbers();
  }

  void _generateNumbers() {
    setState(() {
      _num1 = _random.nextInt(100);
      _num2 = _random.nextInt(100);
      while (_num1 == _num2) {
        _num2 = _random.nextInt(100);
      }
    });
  }

  void _checkAnswer(int selected, int other) {
    setState(() {
      if (selected > other) {
        _score++;
        _feedbackMessage = 'Correct!';
      } else {
        _score--;
        _feedbackMessage = 'Incorrect!';
      }
      _generateNumbers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Bigger Number Game',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Press the button of the larger number. If you get it right, you will earn a point. If you get it wrong, you will lose a point',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _checkAnswer(_num1, _num2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    '$_num1',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _checkAnswer(_num2, _num1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    '$_num2',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Score:', style: TextStyle(fontSize: 24)),
            Text(
              '$_score',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _score < 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            if (_feedbackMessage.isNotEmpty)
              Text(
                _feedbackMessage,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _feedbackMessage == 'Correct!'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
