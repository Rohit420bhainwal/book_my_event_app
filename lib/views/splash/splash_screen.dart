import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Clean logo (no border, no background, no box shadow)
            Center(
              child: CircleAvatar(
                radius: 90,
                backgroundColor:
                theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: const AssetImage(
                  'assets/images/book_my_event_logo.jpg',
                ),
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            Text(
              'BookMyEvent',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // Tagline
            Text(
              'Your Event, Simplified',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            const SizedBox(height: 16),

            // Loading Text
            Text(
              'Starting BookMyEvent...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
