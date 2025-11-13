import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<bool> _isAndroidPermissionGranted() async {
    return await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  static Future<bool> _requestAndroidNotificationsPermission() async {
    return await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  static Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iOSImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnabled = await _isAndroidPermissionGranted();

      if (!notificationEnabled) {
        final requestNotificationsPermission =
            await _requestAndroidNotificationsPermission();
        return requestNotificationsPermission;
      }
      return notificationEnabled;
    } else {
      return false;
    }
  }

  static Future<void> showNotification(String title, String body) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'eventfinder_channel',
          'EventFinder Notifications',
          channelDescription: 'EventFinder app notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
