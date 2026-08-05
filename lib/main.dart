import 'dart:convert';

import 'package:bookmyevent/routes/app_pages.dart';
import 'package:bookmyevent/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {

  await Firebase.initializeApp();

  final FlutterLocalNotificationsPlugin localNotifications =
  FlutterLocalNotificationsPlugin();

  const androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings =
  InitializationSettings(android: androidSettings);

  await localNotifications.initialize(initSettings);

  final data = message.data;

  if (data['type'] != 'chat') return;

  print("messageData: ${data}");
  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "New message",
    data['message'] ?? '',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'chat_channel',
        'Chat Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    payload: jsonEncode(data),
  );
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();


  // 🔥 REGISTER BACKGROUND HANDLER (HERE)
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  //await FCMService.init();
 // runApp(BookMyEventApp());

  // Stripe.publishableKey = "pk_test_51Sh33oCtpKweHSzBMdAE7de66uGJ4oGD1PwRHWNmMqzJ9ANZlvfwhsu7fTPs7g2FegRIR134GPaIVgegMkOcqJQw00wgzzAeTN";
  //
  print("HERE!");
  // await Stripe.instance.applySettings();

  runApp(const BookMyEventApp());
}

class BookMyEventApp extends StatelessWidget {
  const BookMyEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BookMyEvent',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      theme: ThemeData(
      //  useMaterial3: true,
        primaryColor: const Color(0xFF3F51B5), // Blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5), // Indigo/Blue
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF009688), // Teal
          surface: const Color(0xFFF5F5F5), // Light grey
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        /*textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF212121)), // dark text
          bodyMedium: TextStyle(color: Color(0xFF757575)), // secondary text
        ),*/
        textTheme: GoogleFonts.interTextTheme(),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF3F51B5),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}