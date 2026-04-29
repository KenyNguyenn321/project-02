import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// shows mood insights, trends, and wellness suggestions
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  // count moods from a list of entries
  Map<String, int> _countMoods(List<JournalEntry> entries) {
    final Map<String, int> moodCounts = {};

    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts;
  }

  // find most frequent mood
  String _getTopMood(Map<String, int> counts) {
    if (counts.isEmpty) return 'None';

    String topMood = counts.keys.first;
    int topCount = counts[topMood] ?? 0;

    counts.forEach((mood, count) {
      if (count > topCount) {
        topMood = mood;
        topCount = count;
      }
    });

    return topMood;
  }

  // calculate current journaling streak
  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = [...entries];
    sortedEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 1;
    DateTime currentDate = sortedEntries.first.createdAt;

    for (int i = 1; i < sortedEntries.length; i++) {
      final previousDate = sortedEntries[i].createdAt;
      final dayDifference = currentDate.difference(previousDate).inDays;

      if (dayDifference == 1) {
        streak++;
        currentDate = previousDate;
      } else if (dayDifference > 1) {
        break;
      }
    }

    return streak;
  }

  // count stress-related moods in a time window
  int _countStressEntries(List<JournalEntry> entries) {
    return entries.where((entry) {
      return entry.mood == 'Stressed' || entry.mood == 'Overwhelmed';
    }).length;
  }

  // get entries from last 7 days
  List<JournalEntry> _getRecentSevenDays(List<JournalEntry> entries) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return entries.where((entry) {
      return entry.createdAt.isAfter(sevenDaysAgo);
    }).toList();
  }

  // get entries from previous 7 day window
  List<JournalEntry> _getPreviousSevenDays(List<JournalEntry> entries) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    return entries.where((entry) {
      return entry.createdAt.isAfter(fourteenDaysAgo) &&
          entry.createdAt.isBefore(sevenDaysAgo);
    }).toList();
  }

  // generate trend shift message
  String _generateTrendDetection(List<JournalEntry> entries) {
    final recentEntries = _getRecentSevenDays(entries);
    final previousEntries = _getPreviousSevenDays(entries);

    if (recentEntries.isEmpty) {
      return 'No recent 7-day trend yet. Add entries this week to begin trend detection.';
    }

    if (previousEntries.isEmpty) {
      final recentMoodCounts = _countMoods(recentEntries);
      final recentTopMood = _getTopMood(recentMoodCounts);

      return '7-day trend started: Your most common recent mood is $recentTopMood. Add more entries next week to compare emotional changes over time.';
    }

    final recentStressCount = _countStressEntries(recentEntries);
    final previousStressCount = _countStressEntries(previousEntries);

    final recentTopMood = _getTopMood(_countMoods(recentEntries));
    final previousTopMood = _getTopMood(_countMoods(previousEntries));

    if (recentStressCount > previousStressCount) {
      return 'Trend shift detected: Stress-related entries increased compared to the previous 7 days. Suggested action: write down the main stress trigger and choose one small calming action today.';
    }

    if (recentStressCount < previousStressCount) {
      return 'Trend shift detected: Stress-related entries decreased compared to the previous 7 days. Suggested action: continue the routines that helped lower stress.';
    }

    if (recentTopMood != previousTopMood) {
      return 'Trend shift detected: Your top mood changed from $previousTopMood to $recentTopMood. Suggested action: reflect on what changed in your schedule, environment, or habits.';
    }

    return 'Stable trend detected: Your recent mood pattern is similar to the previous 7 days. Suggested action: keep journaling to monitor whether this pattern continues.';
  }

  // generate rule-based wellness suggestion
  String _generateWellnessAction(String topMood) {
    if (topMood == 'Stressed' || topMood == 'Overwhelmed') {
      return 'Suggested action: take a short break, breathe for one minute, and write one task you can control right now.';
    }

    if (topMood == 'Sad') {
      return 'Suggested action: write about what triggered the feeling and consider reaching out to someone you trust.';
    }

    if (topMood == 'Happy' || topMood == 'Calm') {
      return 'Suggested action: keep track of what helped create this positive mood so you can repeat it.';
    }

    return 'Suggested action: continue journaling consistently to reveal stronger emotional patterns.';
  }

  // build one mood bar
  Widget _buildMoodBar(String mood, int count, int maxCount) {
    final double value = maxCount == 0 ? 0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),

      // mood chart row
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$mood ($count)'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
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

    if (user == null) {
      return const Center(child: Text('Please log in to view insights.'));
    }

    return StreamBuilder<List<JournalEntry>>(
      // listen to user journal entries
      stream: firestoreService.getEntries(user.uid),

      // rebuild insights when entries change
      builder: (context, snapshot) {
        // loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // error state
        if (snapshot.hasError) {
          return Center(child: Text('Error loading insights: ${snapshot.error}'));
        }

        // saved entries
        final entries = snapshot.data ?? [];

        // analytics values
        final moodCounts = _countMoods(entries);
        final topMood = _getTopMood(moodCounts);
        final streak = _calculateStreak(entries);
        final trendDetection = _generateTrendDetection(entries);
        final wellnessAction = _generateWellnessAction(topMood);

        // chart scaling
        final int maxCount = moodCounts.isEmpty
            ? 0
            : moodCounts.values.reduce((a, b) => a > b ? a : b);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),

          // insights content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insights',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // streak card
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_fire_department),
                  title: const Text('Current Streak'),
                  trailing: Text(
                    '$streak days',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  // summary text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entries: ${entries.length}'),
                      const SizedBox(height: 6),
                      Text('Top Mood: $topMood'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // mood chart card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  // chart content
                  child: moodCounts.isEmpty
                      ? const Text('No mood data yet.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mood Frequency',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ...moodCounts.entries.map((entry) {
                              return _buildMoodBar(
                                entry.key,
                                entry.value,
                                maxCount,
                              );
                            }),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // trend detection card
              Card(
                child: ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('7-Day Trend Detection'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(trendDetection),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // wellness action card
              Card(
                child: ListTile(
                  leading: const Icon(Icons.self_improvement),
                  title: const Text('Wellness Action'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(wellnessAction),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // privacy-safe boundary
              const Card(
                child: ListTile(
                  leading: Icon(Icons.health_and_safety),
                  title: Text('Reflection Boundary'),
                  subtitle: Text(
                    'These insights are based on journaling patterns and are meant for reflection only. Consider seeking professional support when needed.',
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