import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class CampBookingApp extends StatelessWidget {
  const CampBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camp Booking App',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}