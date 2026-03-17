import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class CampBookingApp extends StatelessWidget {
  const CampBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camp Booking App',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}