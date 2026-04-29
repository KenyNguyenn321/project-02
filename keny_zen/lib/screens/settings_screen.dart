import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

// allows user to manage wellness preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// manages settings switches and notification status
class _SettingsScreenState extends State<SettingsScreen> {
  // daily reminder preference state
  bool _dailyReminderEnabled = false;

  // FCM token preview
  String _notificationStatus = 'Not checked yet';

  // notification service instance
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    // load saved settings when screen opens
    _loadSettings();

    // load notification status
    _loadNotificationStatus();
  }

  // load saved settings from local storage
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // stop if widget is no longer active
    if (!mounted) return;

    setState(() {
      _dailyReminderEnabled = prefs.getBool('dailyReminderEnabled') ?? false;
    });
  }

  // save daily reminder setting
  void _saveDailyReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    // save reminder preference locally
    await prefs.setBool('dailyReminderEnabled', value);

    setState(() {
      _dailyReminderEnabled = value;
    });
  }

  // load notification permission and token status
  void _loadNotificationStatus() async {
    try {
      // request notification permission
      await _notificationService.requestPermission();

      // get FCM token
      final token = await _notificationService.getToken();

      // stop if widget is no longer active
      if (!mounted) return;

      setState(() {
        _notificationStatus = token == null
            ? 'FCM token not available yet'
            : 'FCM connected: ${token.substring(0, 12)}...';
      });
    } catch (e) {
      // stop if widget is no longer active
      if (!mounted) return;

      setState(() {
        _notificationStatus = 'Notification setup unavailable';
      });
    }
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

        // daily reminder setting
        SwitchListTile(
          title: const Text('Daily Reminder'),
          subtitle: const Text('Enable journaling reminder preference'),
          value: _dailyReminderEnabled,
          onChanged: _saveDailyReminder,
        ),

        const SizedBox(height: 12),

        // notification status card
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Notification Setup'),
            subtitle: Text(_notificationStatus),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadNotificationStatus,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // wellness boundary note
        const Card(
          child: ListTile(
            leading: Icon(Icons.health_and_safety),
            title: Text('Wellness Boundary'),
            subtitle: Text(
              'Keny-Zen provides reflection support and wellness suggestions only. It does not diagnose, treat, or replace professional healthcare.',
            ),
          ),
        ),

        const SizedBox(height: 12),

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