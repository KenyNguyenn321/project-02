import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

// entry point of app
void main() async {
  // ensures async Firebase setup works before app starts
  WidgetsFlutterBinding.ensureInitialized();

  // initialize Firebase using generated config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize basic FCM notification setup
  await NotificationService().initialize();

  // launch app
  runApp(const MyApp());
}

// root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // remove debug banner
      debugShowCheckedModeBanner: false,

      // app title
      title: 'Keny-Zen',

      // calm blue app theme
      theme: AppTheme.lightTheme,

      // first screen
      home: const SplashScreen(),
    );
  }
}