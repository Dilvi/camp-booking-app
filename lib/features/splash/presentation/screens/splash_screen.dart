import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/storage/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await TokenStorage.getToken();

    if (!mounted) return;

    if (token != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// фон
          Container(color: Colors.white),

          /// звезды сверху (заходят под статусбар)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_top.png',
              fit: BoxFit.cover,
            ),
          ),

          /// центр — логотип
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 180,
            ),
          ),

          /// палатки снизу (заходят под навбар)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_bottom.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}