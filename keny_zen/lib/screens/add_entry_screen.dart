import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// screen for creating a new journal entry
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

// handles journal entry form state
class _AddEntryScreenState extends State<AddEntryScreen> {
  // controller for journal text
  final TextEditingController _contentController = TextEditingController();

  // selected mood value
  String _selectedMood = 'Calm';

  // service instances
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // track loading state
  bool _isLoading = false;

  // available mood options
  final List<String> _moods = [
    'Calm',
    'Happy',
    'Stressed',
    'Sad',
    'Overwhelmed',
  ];

  // save journal entry to Firestore
  void _saveEntry() async {
    final content = _contentController.text.trim();
    final user = _authService.currentUser;

    // prevent empty journal entries
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first.')),
      );
      return;
    }

    // make sure user is logged in
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // create entry object
      final entry = JournalEntry(
        id: '',
        userId: user.uid,
        content: content,
        mood: _selectedMood,
        createdAt: DateTime.now(),
      );

      // save entry to Firestore
      await _firestoreService.addEntry(entry);

      // stop if widget is no longer active
      if (!mounted) return;

      // return to previous screen
      Navigator.pop(context);
    } catch (e) {
      // stop if widget is no longer active
      if (!mounted) return;

      // show save error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }

    // stop if widget is no longer active
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // clean up controller
    _contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top app bar
      appBar: AppBar(
        title: const Text('New Journal Entry'),
      ),

      // form content
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // entry form
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write your thoughts:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // journal text input
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'How are you feeling today?',
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Mood:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // mood dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedMood,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _moods.map((mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMood = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // save button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveEntry,
                      child: const Text('Save Entry'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}