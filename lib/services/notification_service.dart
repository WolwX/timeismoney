// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Configuration pour Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration pour iOS
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuration générale
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Initialisation
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Demander les permissions sur iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Gérer les interactions avec les notifications si nécessaire
    print('Notification tapped: ${response.payload}');
  }

  // Notification pour la fin du timer (mode minuteur)
  Future<void> showTimerFinishedNotification({
    required String timerName,
    required double targetAmount,
    required String currency,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timer_finished_channel',
      'Timer Finished',
      channelDescription: 'Notifications when timer reaches target amount',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // ID de notification
      'Timer terminé !',
      '$timerName a atteint son objectif de ${targetAmount.toStringAsFixed(2)} $currency',
      platformChannelSpecifics,
      payload: 'timer_finished',
    );
  }

  // Notification pour les paliers de gain (mode normal)
  Future<void> showGainMilestoneNotification({
    required String timerName,
    required double milestoneAmount,
    required String currency,
    required Duration elapsedTime,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'gain_milestone_channel',
      'Gain Milestones',
      channelDescription: 'Notifications for gain milestones',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    final timeString = hours > 0 ? '${hours}h ${minutes}min' : '${minutes}min';

    await _flutterLocalNotificationsPlugin.show(
      1, // ID de notification différent
      'Palier de gain atteint !',
      '$timerName : ${milestoneAmount.toStringAsFixed(0)} $currency gagnés en $timeString',
      platformChannelSpecifics,
      payload: 'gain_milestone',
    );
  }

  // Notification pour les rappels périodiques (optionnel)
  Future<void> showPeriodicReminderNotification({
    required String timerName,
    required double currentGains,
    required String currency,
    required Duration elapsedTime,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'periodic_reminder_channel',
      'Periodic Reminders',
      channelDescription: 'Periodic reminders about current gains',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: true,
      enableVibration: false,
      playSound: false,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    final timeString = hours > 0 ? '${hours}h ${minutes}min' : '${minutes}min';

    await _flutterLocalNotificationsPlugin.show(
      2, // ID de notification différent
      'Rappel Time Is Money',
      '$timerName : ${currentGains.toStringAsFixed(2)} $currency en $timeString',
      platformChannelSpecifics,
      payload: 'periodic_reminder',
    );
  }

  // Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Annuler une notification spécifique
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}