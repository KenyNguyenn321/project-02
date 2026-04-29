import 'package:flutter/material.dart';

// allows user to manage preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// manages settings switches
class _SettingsScreenState extends State<SettingsScreen> {
  // dark mode placeholder state
  bool _darkModeEnabled = false;

  // daily reminder placeholder state
  bool _dailyReminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),

      // settings content
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // dark mode setting
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle dark mode preference'),
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),

        // daily reminder setting
        SwitchListTile(
          title: const Text('Daily Reminder'),
          subtitle: const Text('Enable journaling reminder notifications'),
          value: _dailyReminderEnabled,
          onChanged: (value) {
            setState(() {
              _dailyReminderEnabled = value;
            });
          },
        ),

        const SizedBox(height: 16),

        // account info section
        const Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            subtitle: Text('Signed in with Firebase Authentication'),
          ),
        ),
      ],
    );
  }
}