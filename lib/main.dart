// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; 
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/providers/locale_provider.dart';
import 'package:timeismoney/services/storage_service.dart';
import 'package:timeismoney/services/notification_service.dart';
import 'package:timeismoney/services/celebration_manager.dart';
import 'package:timeismoney/l10n/app_localizations.dart';
// Import du HomeScreen
import 'package:timeismoney/screens/home_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration du mode immersif pour Android (cache les barres système)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final storage = StorageService();
  final notificationService = NotificationService();
  await notificationService.init();
  
  final celebrationManager = CelebrationManager(storage: storage);
  
  final controller = MultiTimerController(
    storage: storage, 
    notificationService: notificationService,
    celebrationManager: celebrationManager,
  );
  await controller.init();

  // Initialisation du service de synchronisation du temps
  // final timeSyncService = TimeSyncService();
  // await timeSyncService.fetchNetworkDateTime();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MultiTimerController>.value(value: controller),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<CelebrationManager>.value(value: celebrationManager),
        // Provider<TimeSyncService>.value(value: timeSyncService),
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
          localizationsDelegates: [
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
          // Démarrage sur le HomeScreen
          home: const HomeScreen(), 
        );
      },
    );
  }
}