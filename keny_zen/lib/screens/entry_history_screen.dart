import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/mood_colors.dart';
import 'entry_detail_screen.dart';

// displays saved journal entries
class EntryHistoryScreen extends StatelessWidget {
  const EntryHistoryScreen({super.key});

  // format date for entry cards
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
        child: Text('Please log in to view entries.'),
      );
    }

    return StreamBuilder<List<JournalEntry>>(
      // listen to journal entries from Firestore
      stream: firestoreService.getEntries(user.uid),

      // rebuild UI when Firestore data changes
      builder: (context, snapshot) {
        // show loading while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // show error if Firestore fails
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading entries: ${snapshot.error}'),
          );
        }

        // saved entries list
        final entries = snapshot.data ?? [];

        // show designed empty state
        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.self_improvement, size: 64, color: Colors.blue),
                SizedBox(height: 12),
                Text(
                  'No journal entries yet.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('Tap + to start your first reflection.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            // current entry
            final entry = entries[index];

            // mood color
            final moodColor = getMoodColor(entry.mood);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),

              // entry card content
              child: ListTile(
                leading: entry.imageUrl == null
                    ? Icon(Icons.notes, color: moodColor)
                    : Icon(Icons.image, color: moodColor),
                title: Text(
                  entry.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),

                  // mood and date row
                  child: Row(
                    children: [
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
                          entry.mood,
                          style: TextStyle(
                            color: moodColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_formatDate(entry.createdAt)),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),

                // open entry details
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EntryDetailScreen(entry: entry),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}