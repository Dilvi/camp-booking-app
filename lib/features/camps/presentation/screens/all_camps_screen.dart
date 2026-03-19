import 'package:flutter/material.dart';

class AllCampsScreen extends StatelessWidget {
  const AllCampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Все лагеря\n(позже реализуем)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}