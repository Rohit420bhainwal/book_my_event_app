import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';
import '../controller/chat_controller.dart';

class FCMService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// 🔥 INIT
  static Future<void> init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ✅ Request permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ Local notification init
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );

    // ✅ Notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_channel',
      'Chat Notifications',
      description: 'Notifications for chat messages',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 🔕 FOREGROUND handler
    FirebaseMessaging.onMessage.listen(_onMessage);

    // 🔔 Background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // 🔔 Terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// 🟢 FOREGROUND MESSAGE HANDLER
  static void _onMessage(RemoteMessage message) {
    debugPrint("🔥 FCM RECEIVED (FOREGROUND)");
    debugPrint("DATA => ${message.data}");

    if (message.data['type'] != 'chat') return;

    final senderId = message.data['senderId'];

    // ✅ If user is already chatting with sender → NO notification
    if (ChatController.isChatOpenWith(senderId)) {
      debugPrint("🟢 Chat already open → no notification");
      return;
    }

    // ✅ App foreground BUT not on chat → SHOW local notification
    debugPrint("🔔 App foreground → showing local notification");
    _showLocalNotification(message);
  }

  /// 🔔 SHOW LOCAL NOTIFICATION
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final data = message.data;

    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for chat messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "New Message",
      data['message'] ?? "You received a message",
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  /// 🔔 BACKGROUND TAP HANDLER
  static void _onMessageOpened(RemoteMessage message) {
    _handleMessage(message);
  }

  /// 📲 NAVIGATION HANDLER
  static void _handleMessage(RemoteMessage message) {
    final data = message.data;

    final box = GetStorage();
    final userData = box.read("userData");
    final role = userData["user"]["role"].toString(); // provider | customer
    final loggedInUserId = userData["user"]["id"].toString();

    final senderId = data["senderId"];
    final receiverId = data["receiverId"];

    String providerId;
    String customerId;

    if (role == "provider") {
      providerId = loggedInUserId;
      customerId = senderId == loggedInUserId ? receiverId : senderId;
    } else {
      customerId = loggedInUserId;
      providerId = senderId == loggedInUserId ? receiverId : senderId;
    }

    if (data["type"] == "chat") {
      Get.toNamed(
        Routes.chatScreen,
        arguments: {
          "providerId": providerId,
          "customerId": customerId,
          "serviceId": data["serviceId"],
          "serviceName": data["serviceName"],
          "loggedInUserId": loggedInUserId,
        },
      );
    }
  }


  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    final data = jsonDecode(payload);

    final box = GetStorage();
    final userData = box.read("userData");
    final role = userData["user"]["role"].toString();
    final loggedInUserId = userData["user"]["id"].toString();

    final senderId = data["senderId"];
    final receiverId = data["receiverId"];

    String providerId;
    String customerId;

    if (role == "provider") {
      providerId = loggedInUserId;
      customerId = senderId == loggedInUserId ? receiverId : senderId;
    } else {
      customerId = loggedInUserId;
      providerId = senderId == loggedInUserId ? receiverId : senderId;
    }

    Get.toNamed(
      Routes.chatScreen,
      arguments: {
        "providerId": providerId,
        "customerId": customerId,
        "serviceId": data["serviceId"],
        "serviceName": data["serviceName"],
        "loggedInUserId": loggedInUserId,
      },
    );
  }

}
