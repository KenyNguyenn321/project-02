import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// allows user to manage preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// manages settings switches
class _SettingsScreenState extends State<SettingsScreen> {
  // dark mode preference state
  bool _darkModeEnabled = false;

  // daily reminder preference state
  bool _dailyReminderEnabled = false;

  @override
  void initState() {
    super.initState();

    // load saved settings when screen opens
    _loadSettings();
  }

  // load saved settings from local storage
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // stop if widget is no longer active
    if (!mounted) return;

    setState(() {
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      _dailyReminderEnabled = prefs.getBool('dailyReminderEnabled') ?? false;
    });
  }

  // save dark mode setting
  void _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    // save value locally
    await prefs.setBool('darkModeEnabled', value);

    setState(() {
      _darkModeEnabled = value;
    });
  }

  // save daily reminder setting
  void _saveDailyReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    // save value locally
    await prefs.setBool('dailyReminderEnabled', value);

    setState(() {
      _dailyReminderEnabled = value;
    });
  }

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
          subtitle: const Text('Save dark mode preference locally'),
          value: _darkModeEnabled,
          onChanged: _saveDarkMode,
        ),

        // daily reminder setting
        SwitchListTile(
          title: const Text('Daily Reminder'),
          subtitle: const Text('Save journaling reminder preference locally'),
          value: _dailyReminderEnabled,
          onChanged: _saveDailyReminder,
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