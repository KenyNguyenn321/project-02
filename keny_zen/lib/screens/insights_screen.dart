import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// displays mood insights and trends
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  // count how many times each mood appears
  Map<String, int> _countMoods(List<JournalEntry> entries) {
    final Map<String, int> moodCounts = {};

    // loop through entries and count moods
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts;
  }

  // find most common mood
  String _getMostFrequentMood(Map<String, int> moodCounts) {
    if (moodCounts.isEmpty) {
      return 'None';
    }

    String topMood = moodCounts.keys.first;
    int topCount = moodCounts[topMood] ?? 0;

    // find mood with highest count
    moodCounts.forEach((mood, count) {
      if (count > topCount) {
        topMood = mood;
        topCount = count;
      }
    });

    return topMood;
  }

  // generate simple rule-based wellness insight
  String _generateInsight(List<JournalEntry> entries, String topMood) {
    if (entries.isEmpty) {
      return 'Start journaling to receive mood insights.';
    }

    if (topMood == 'Stressed' || topMood == 'Overwhelmed') {
      return 'You have logged stress often. Consider taking a short break or doing a calming activity.';
    }

    if (topMood == 'Sad') {
      return 'You have logged sadness often. Consider writing about what caused it or reaching out to someone you trust.';
    }

    if (topMood == 'Happy' || topMood == 'Calm') {
      return 'Your recent entries show positive emotional patterns. Keep building habits that support this mood.';
    }

    return 'Your entries show mixed emotions. Continue journaling to better understand your patterns.';
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
        child: Text('Please log in to view insights.'),
      );
    }

    return StreamBuilder<List<JournalEntry>>(
      // listen to entries for insight generation
      stream: firestoreService.getEntries(user.uid),

      // rebuild when entries change
      builder: (context, snapshot) {
        // show loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // show error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading insights: ${snapshot.error}'),
          );
        }

        // get entries
        final entries = snapshot.data ?? [];

        // mood counts for trends
        final moodCounts = _countMoods(entries);

        // most common mood
        final topMood = _getMostFrequentMood(moodCounts);

        // generated wellness suggestion
        final insight = _generateInsight(entries, topMood);

        return Padding(
          padding: const EdgeInsets.all(16.0),

          // insights layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mood Insights',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  // summary info
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Entries: ${entries.length}'),
                      const SizedBox(height: 8),
                      Text('Most Frequent Mood: $topMood'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Mood Frequency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // mood frequency list
              ...moodCounts.entries.map((moodEntry) {
                return Card(
                  child: ListTile(
                    title: Text(moodEntry.key),
                    trailing: Text('${moodEntry.value}'),
                  ),
                );
              }),

              const SizedBox(height: 16),

              const Text(
                'Generated Insight',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // rule-based insight
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(insight),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}