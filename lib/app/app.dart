import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';

class CampBookingApp extends StatelessWidget {
  const CampBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camp Booking App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}