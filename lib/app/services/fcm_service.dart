import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';


class FCMService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// 🔹 Call this in main() after Firebase.initializeApp()
  static Future<void> init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // iOS permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground notification setup
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );

    // 🔥 Foreground messages
    FirebaseMessaging.onMessage.listen(_onMessage);

    // 🔥 App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // 🔥 App opened from terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// 🔹 Foreground message
  static void _onMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    print("notification_data ${notification}");

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// 🔹 Background → foreground
  static void _onMessageOpened(RemoteMessage message) {
    _handleMessage(message);
  }

  /// 🔹 Handle navigation
  static void _handleMessage(RemoteMessage message) {
    final data = message.data;

    print("data: ${data}");
    if (data["type"] == "chat") {
      Get.toNamed(
        Routes.chatScreen,
        arguments: {
          "senderId": data["senderId"],
          "receiverId": data["receiverId"],
        },
      );
    }
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    final data = jsonDecode(payload);
    print("payload_data: ${data}");
    if (data["type"] == "chat") {
      Get.toNamed(
        Routes.chatScreen,
        arguments: {
          "senderId": data["senderId"],
          "receiverId": data["receiverId"],
        },
      );
    }
  }
}
