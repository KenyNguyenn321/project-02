import 'package:cloud_firestore/cloud_firestore.dart';

// model for one journal entry
class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final String mood;
  final DateTime createdAt;

  // create journal entry object
  JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  // convert Firestore document into JournalEntry
  factory JournalEntry.fromMap(String id, Map<String, dynamic> data) {
    return JournalEntry(
      id: id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      mood: data['mood'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // convert JournalEntry into Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'mood': mood,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}