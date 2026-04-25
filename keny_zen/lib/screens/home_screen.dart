import 'package:flutter/material.dart';

// temporary home screen until journal dashboard is built
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // temporary centered text
      body: Center(
        child: Text('Keny-Zen Home Dashboard'),
      ),
    );
  }
}