import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Etc/UTC'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick.add(response.payload);
      },
    );
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        try {
          await androidImplementation.requestNotificationsPermission();
          debugPrint('Android notification permission requested');
        } catch (e) {
          debugPrint('Error requesting notification permission: $e');
        }
      }
    }
  }
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final notificationTime = scheduledTime.subtract(const Duration(minutes: 10));

    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode, 
        title,
        body,
        tzDateTime,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'todo_notification_channel',
            'Todo Notifications',
            channelDescription: 'Notifications for upcoming tasks',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: id,
      );
      debugPrint('Notification scheduled for: $tzDateTime');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(String id) async {
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

