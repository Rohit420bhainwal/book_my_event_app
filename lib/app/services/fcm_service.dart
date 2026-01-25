import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../controller/chat_controller.dart';


class FCMService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// 🔹 Call this in main() after Firebase.initializeApp()
  static Future<void> init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔔 Permission (iOS / Android 13+)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 🔔 Local notification init
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );

    // 🔥 FOREGROUND messages
    FirebaseMessaging.onMessage.listen(_onMessage);

    // 🔥 Background → foreground (tap)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // 🔥 Terminated → open
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// 🔹 FOREGROUND message handler
  static void _onMessage(RemoteMessage message) {
    debugPrint("🔥 FCM RECEIVED (FOREGROUND)");
    debugPrint("DATA => ${message.data}");

    print("dsds: ");
    if (message.data['type'] != 'chat') return;

    final senderId = message.data['senderId'];
    final messageText = message.data['message'] ?? '';

    // 🛑 Chat already open → DO NOT show notification
    if (ChatController.isChatOpenWith(senderId)) {
      debugPrint("🛑 Chat open with $senderId → notification skipped");
      return;
    }

    // ✅ Show local notification
    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "New message",
      messageText,
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

  /// 🔹 Notification tapped (background)
  static void _onMessageOpened(RemoteMessage message) {
    debugPrint("📲 Notification opened (background)");
    _handleMessage(message);
  }

  /// 🔹 Handle navigation (background / terminated)
  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    debugPrint("➡️ HANDLE MESSAGE: $data");

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

  /// 🔹 Local notification tap
  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    final data = jsonDecode(payload);
    debugPrint("📦 NOTIFICATION PAYLOAD: $data");

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
