import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// splash screen shown when app starts
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// manages splash timer and auth routing
class _SplashScreenState extends State<SplashScreen> {
  // auth service instance
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // wait briefly before checking login status
    Timer(const Duration(seconds: 2), () {
      _checkAuthState();
    });
  }

  // checks if user is already logged in
  void _checkAuthState() {
    // stop if widget is no longer active
    if (!mounted) return;

    // choose screen based on current user
    final nextScreen = _authService.currentUser == null
        ? const LoginScreen()
        : const HomeScreen();

    // navigate to correct screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // center app branding
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Keny-Zen',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Reflect and Reset',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}