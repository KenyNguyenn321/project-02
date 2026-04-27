import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// displays saved journal entries
class EntryHistoryScreen extends StatelessWidget {
  const EntryHistoryScreen({super.key});

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

        // show empty state
        if (entries.isEmpty) {
          return const Center(
            child: Text('No journal entries yet. Tap + to add one.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            // current entry
            final entry = entries[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),

              // entry card content
              child: ListTile(
                title: Text(
                  entry.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('Mood: ${entry.mood}'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            );
          },
        );
      },
    );
  }
}