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
    // Initialize timezone without using flutter_native_timezone
    tz.initializeTimeZones();
    // Use local timezone - this is a simpler approach that works for most cases
    tz.setLocalLocation(tz.getLocation('Etc/UTC'));

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick.add(response.payload);
      },
    );

    // Request permissions
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
      // For Android, we need to use a different approach for requesting permissions
      // This works for Android 13+ (API level 33+)
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
                  
      // The correct method is requestNotificationsPermission
      if (androidImplementation != null) {
        try {
          await androidImplementation.requestNotificationsPermission();
          debugPrint('Android notification permission requested');
        } catch (e) {
          debugPrint('Error requesting notification permission: $e');
          // Fallback for older versions of the plugin or Android
        }
      }
    }
  }

  // Schedule a notification 10 minutes before task due time
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Calculate 10 minutes before the task time
    final notificationTime = scheduledTime.subtract(const Duration(minutes: 10));
    
    // Don't schedule if the notification time is in the past
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    // Convert to TZDateTime using UTC offset
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode, // Use hashCode of the id as the notification id
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

  // Cancel a notification
  Future<void> cancelNotification(String id) async {
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

