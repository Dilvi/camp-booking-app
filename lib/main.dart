import 'package:flutter/material.dart';

void main() {
  runApp(const CampBookingApp());
}

class CampBookingApp extends StatelessWidget {
  const CampBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camp Booking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Camp Booking App'),
        ),
      ),
    );
  }
}