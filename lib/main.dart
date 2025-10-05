// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:timeismoney/providers/timer_controller.dart'; 
import 'package:timeismoney/services/storage_service.dart';
// Import du nouveau Splash Screen
import 'package:timeismoney/screens/splash_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  final controller = TimerController(storage: storage);
  await controller.init();

  runApp(
    ChangeNotifierProvider<TimerController>.value(
      value: controller,
      child: const TimeIsMoneyApp(),
    ),
  );
}

class TimeIsMoneyApp extends StatelessWidget {
  const TimeIsMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Is Money',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, 
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
      ),
      // Démarrage sur le Splash Screen au lieu du HomeScreen
      home: const SplashScreen(), 
    );
  }
}