import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// shows mood insights + streaks
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  // count moods
  Map<String, int> _countMoods(List<JournalEntry> entries) {
    final Map<String, int> moodCounts = {};

    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts;
  }

  // most frequent mood
  String _getTopMood(Map<String, int> counts) {
    if (counts.isEmpty) return 'None';

    String top = counts.keys.first;
    int max = counts[top]!;

    counts.forEach((mood, count) {
      if (count > max) {
        top = mood;
        max = count;
      }
    });

    return top;
  }

  // calculate daily streak
  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    // sort newest → oldest
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 1;
    DateTime current = entries.first.createdAt;

    for (int i = 1; i < entries.length; i++) {
      final prev = entries[i].createdAt;

      if (current.difference(prev).inDays == 1) {
        streak++;
        current = prev;
      } else {
        break;
      }
    }

    return streak;
  }

  // simple insight text
  String _generateInsight(String mood) {
    if (mood == 'Stressed' || mood == 'Overwhelmed') {
      return 'You have logged stress frequently. Try taking a short break.';
    }

    if (mood == 'Sad') {
      return 'You have logged sadness often. Consider talking to someone.';
    }

    if (mood == 'Happy' || mood == 'Calm') {
      return 'Your recent moods are positive. Keep your routine going.';
    }

    return 'Keep journaling to discover patterns.';
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final firestore = FirestoreService();

    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: Text('Login required'));
    }

    return StreamBuilder<List<JournalEntry>>(
      stream: firestore.getEntries(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final entries = snapshot.data ?? [];

        final counts = _countMoods(entries);
        final topMood = _getTopMood(counts);
        final streak = _calculateStreak(entries);
        final insight = _generateInsight(topMood);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insights',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // streak card (NEW)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '$streak days',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entries: ${entries.length}'),
                      Text('Top Mood: $topMood'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // insight
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(insight),
                ),
              ),

              const SizedBox(height: 16),

              // safe note
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This app provides wellness reflections only and does not diagnose or replace professional care.',
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