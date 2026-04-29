import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/mood_colors.dart';
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
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // selected tab content
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

  // format date for dashboard
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

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
        // loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading dashboard: ${snapshot.error}'),
          );
        }

        // saved entries
        final entries = snapshot.data ?? [];

        // empty state
        if (entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, size: 72, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Start your first reflection',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to write a journal entry and begin tracking your mood patterns.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // latest entry
        final latestEntry = entries.first;

        // mood color
        final moodColor = getMoodColor(latestEntry.mood);

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

              // latest entry card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  // recent entry content
                  child: Column(
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

                      const SizedBox(height: 12),

                      // mood tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: moodColor.withAlpha(45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          latestEntry.mood,
                          style: TextStyle(
                            color: moodColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text('Date: ${_formatDate(latestEntry.createdAt)}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // total entry count
              Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text('Total Entries'),
                  trailing: Text(
                    '${entries.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}