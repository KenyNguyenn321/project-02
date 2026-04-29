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

  // get entries from the last 7 days
  List<JournalEntry> _getLastSevenDayEntries(List<JournalEntry> entries) {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    // keep entries inside 7-day window
    return entries.where((entry) {
      return entry.createdAt.isAfter(cutoffDate);
    }).toList();
  }

  // generate 7-day trend assistant message
  String _generateSevenDayTrend(List<JournalEntry> entries) {
    final recentEntries = _getLastSevenDayEntries(entries);

    if (recentEntries.isEmpty) {
      return 'No 7-day trend yet. Add entries this week to generate a trend summary.';
    }

    final recentMoodCounts = _countMoods(recentEntries);
    final topRecentMood = _getMostFrequentMood(recentMoodCounts);

    if (topRecentMood == 'Stressed' || topRecentMood == 'Overwhelmed') {
      return '7-day trend: Stress-related moods appeared most often this week. Suggested action: take a short break, write one cause of stress, and choose one small task to complete first.';
    }

    if (topRecentMood == 'Sad') {
      return '7-day trend: Sadness appeared often this week. Suggested action: write about what triggered the feeling and consider reaching out to someone you trust.';
    }

    if (topRecentMood == 'Happy' || topRecentMood == 'Calm') {
      return '7-day trend: Your recent mood pattern is mostly positive. Suggested action: keep doing the routines or environments that supported this mood.';
    }

    return '7-day trend: Your moods are mixed this week. Suggested action: continue journaling to find clearer patterns over time.';
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
      return 'Your entries show positive emotional patterns. Keep building habits that support this mood.';
    }

    return 'Your entries show mixed emotions. Continue journaling to better understand your patterns.';
  }

  // build one simple mood bar
  Widget _buildMoodBar(String mood, int count, int maxCount) {
    final double percent = maxCount == 0 ? 0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),

      // mood row
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$mood ($count)'),

          const SizedBox(height: 6),

          // visual bar background
          LinearProgressIndicator(
            value: percent,
            minHeight: 10,
          ),
        ],
      ),
    );
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

        // generated 7-day assistant insight
        final sevenDayTrend = _generateSevenDayTrend(entries);

        // max mood count for chart scaling
        final int maxCount = moodCounts.isEmpty
            ? 0
            : moodCounts.values.reduce((a, b) => a > b ? a : b);

        return SingleChildScrollView(
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
                'Mood Frequency Chart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // chart card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: moodCounts.isEmpty
                      ? const Text('No mood data yet.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: moodCounts.entries.map((moodEntry) {
                            return _buildMoodBar(
                              moodEntry.key,
                              moodEntry.value,
                              maxCount,
                            );
                          }).toList(),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '7-Day Trend Assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // must-solve 7-day assistant card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(sevenDayTrend),
                ),
              ),

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

              const SizedBox(height: 16),

              // challenge boundary
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'These insights are rule-based wellness reflections only. Keny-Zen avoids diagnosis, avoids medical claims, and keeps the user in control of interpretation.',
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