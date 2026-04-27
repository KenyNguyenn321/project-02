import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_entry_screen.dart';
import 'entry_history_screen.dart';
import 'insights_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

// main dashboard after login
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// controls bottom navigation state
class _HomeScreenState extends State<HomeScreen> {
  // selected bottom nav index
  int _selectedIndex = 0;

  // auth service instance
  final AuthService _authService = AuthService();

  // list of main screens
  final List<Widget> _screens = const [
    DashboardContent(),
    EntryHistoryScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  // update current tab
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // logout user
  void _logout() async {
    await _authService.logout();

    // stop if widget is no longer active
    if (!mounted) return;

    // return to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // open add entry screen
  void _openAddEntryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top app bar
      appBar: AppBar(
        title: const Text('Keny-Zen'),

        // logout action
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // show selected screen
      body: _screens[_selectedIndex],

      // bottom navigation tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

      // add entry button
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntryScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// dashboard tab content
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // service instances
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();

    // current signed-in user
    final user = authService.currentUser;

    // show message if user is missing
    if (user == null) {
      return const Center(
        child: Text('Please log in to view dashboard.'),
      );
    }

    return StreamBuilder<List<JournalEntry>>(
      // listen to user entries
      stream: firestoreService.getEntries(user.uid),

      // rebuild dashboard with latest data
      builder: (context, snapshot) {
        // show loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // show error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading dashboard: ${snapshot.error}'),
          );
        }

        // get entries
        final entries = snapshot.data ?? [];

        // latest entry if it exists
        final JournalEntry? latestEntry = entries.isEmpty ? null : entries.first;

        return Padding(
          padding: const EdgeInsets.all(16.0),

          // dashboard content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today’s Reflection',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // show latest entry card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: latestEntry == null
                      ? const Text('No entries yet. Tap + to add one.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Entry:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              latestEntry.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            Text('Mood: ${latestEntry.mood}'),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // show total entries
              Text(
                'Total Entries: ${entries.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}