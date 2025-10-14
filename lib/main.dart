// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; 
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/providers/locale_provider.dart';
import 'package:timeismoney/services/storage_service.dart';
import 'package:timeismoney/l10n/app_localizations.dart';
// Import du nouveau Splash Screen
import 'package:timeismoney/screens/splash_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  final controller = MultiTimerController(storage: storage);
  await controller.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MultiTimerController>.value(value: controller),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
      ],
      child: const TimeIsMoneyApp(),
    ),
  );
}

class TimeIsMoneyApp extends StatelessWidget {
  const TimeIsMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Time Is Money',
          debugShowCheckedModeBanner: false,
          
          // Configuration de la localisation
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('fr', ''), // Français
            Locale('en', ''), // Anglais
            Locale('es', ''), // Espagnol
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          theme: ThemeData(
            brightness: Brightness.dark, 
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.black,
          ),
          // Démarrage sur le Splash Screen au lieu du HomeScreen
          home: const SplashScreen(), 
        );
      },
    );
  }
}