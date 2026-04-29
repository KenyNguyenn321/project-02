import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/zen_logo.dart';
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
    return Scaffold(
      // gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.calmGradient,
        ),

        // center splash content
        child: Center(
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(28.0),

              // logo and app branding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ZenLogo(size: 95),
                  SizedBox(height: 18),
                  Text(
                    'Keny-Zen',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reflect and Reset',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}