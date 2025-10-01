import 'package:flutter/material.dart';

void main() {
  runApp(const TimeIsMoneyApp());
}

class TimeIsMoneyApp extends StatelessWidget {
  const TimeIsMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Is Money',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Placeholder(), // On remplacera par l'écran principal
    );
  }
}