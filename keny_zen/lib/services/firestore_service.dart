import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

// handles journal entry database operations
class FirestoreService {
  // journal entries collection
  final CollectionReference _entriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');

  // add new journal entry
  Future<void> addEntry(JournalEntry entry) async {
    await _entriesCollection.add(entry.toMap());
  }

  // get entries for current user
  Stream<List<JournalEntry>> getEntries(String userId) {
    return _entriesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      // convert each document into a JournalEntry
      return snapshot.docs.map((doc) {
        return JournalEntry.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // update existing journal entry
  Future<void> updateEntry(String entryId, String content, String mood) async {
    await _entriesCollection.doc(entryId).update({
      'content': content,
      'mood': mood,
    });
  }

  // delete journal entry
  Future<void> deleteEntry(String entryId) async {
    await _entriesCollection.doc(entryId).delete();
  }
}