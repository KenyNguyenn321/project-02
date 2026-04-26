import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// main dashboard after login
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // auth service instance
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keny-Zen'),

        // logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            // logout user and go back to login
            onPressed: () async {
              await authService.logout();

              if (!context.mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // main content
      body: const Padding(
        padding: EdgeInsets.all(16.0),

        // simple placeholder UI for now
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s Reflection',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // placeholder recent entry
            Text(
              '"Start your journaling journey..."',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),

            SizedBox(height: 8),

            Text(
              '[No entries yet]',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),

      // floating button to add entry (we build next)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // placeholder for next screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}