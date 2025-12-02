import 'package:bookmyevent/routes/app_pages.dart';
import 'package:bookmyevent/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 // runApp(BookMyEventApp());
  await GetStorage.init();
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
        useMaterial3: true,
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