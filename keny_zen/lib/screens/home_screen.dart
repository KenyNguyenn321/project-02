import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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

      // add entry button placeholder
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // add entry navigation will be added next
        },
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
    return const Padding(
      padding: EdgeInsets.all(16.0),

      // dashboard content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s Reflection',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16),

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
    );
  }
}