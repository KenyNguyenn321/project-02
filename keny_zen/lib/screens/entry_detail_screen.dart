import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/firestore_service.dart';

// screen that shows one journal entry in detail
class EntryDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const EntryDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    // Firestore service instance
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      // top app bar
      appBar: AppBar(
        title: const Text('Entry Details'),
      ),

      // entry detail content
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // vertical layout
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal Entry',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // entry content
            Text(
              entry.content,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // mood label
            Text(
              'Mood: ${entry.mood}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // created date
            Text(
              'Date: ${entry.createdAt.month}/${entry.createdAt.day}/${entry.createdAt.year}',
            ),

            const SizedBox(height: 24),

            // delete entry button
            ElevatedButton.icon(
              onPressed: () async {
                // delete entry from Firestore
                await firestoreService.deleteEntry(entry.id);

                // stop if screen is no longer active
                if (!context.mounted) return;

                // return to previous screen after delete
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Entry'),
            ),
          ],
        ),
      ),
    );
  }
}