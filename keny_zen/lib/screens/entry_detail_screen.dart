import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/firestore_service.dart';

// screen that shows one journal entry in detail
class EntryDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const EntryDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

// handles edit and delete state
class _EntryDetailScreenState extends State<EntryDetailScreen> {
  // Firestore service instance
  final FirestoreService _firestoreService = FirestoreService();

  // controller for editable content
  late TextEditingController _contentController;

  // selected mood value
  late String _selectedMood;

  // edit mode state
  bool _isEditing = false;

  // loading state
  bool _isLoading = false;

  // available mood options
  final List<String> _moods = [
    'Calm',
    'Happy',
    'Stressed',
    'Sad',
    'Overwhelmed',
  ];

  @override
  void initState() {
    super.initState();

    // load existing entry values
    _contentController = TextEditingController(text: widget.entry.content);
    _selectedMood = widget.entry.mood;
  }

  // update journal entry in Firestore
  void _updateEntry() async {
    final content = _contentController.text.trim();

    // prevent empty journal entries
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // save updated entry
      await _firestoreService.updateEntry(
        widget.entry.id,
        content,
        _selectedMood,
      );

      // stop if widget is no longer active
      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated.')),
      );
    } catch (e) {
      // stop if widget is no longer active
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // show update error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  // delete journal entry from Firestore
  void _deleteEntry() async {
    await _firestoreService.deleteEntry(widget.entry.id);

    // stop if widget is no longer active
    if (!mounted) return;

    // return to entry history
    Navigator.pop(context);
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
        title: const Text('Entry Details'),

        // edit toggle button
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
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

            // editable or read-only content
            _isEditing
                ? TextField(
                    controller: _contentController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    widget.entry.content,
                    style: const TextStyle(fontSize: 16),
                  ),

            const SizedBox(height: 16),

            // editable or read-only mood
            _isEditing
                ? DropdownButtonFormField<String>(
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
                  )
                : Text(
                    'Mood: ${widget.entry.mood}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            const SizedBox(height: 8),

            // created date
            Text(
              'Date: ${widget.entry.createdAt.month}/${widget.entry.createdAt.day}/${widget.entry.createdAt.year}',
            ),

            const SizedBox(height: 24),

            // save changes button
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _updateEntry,
                        child: const Text('Save Changes'),
                      ),
              ),

            const SizedBox(height: 12),

            // delete entry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deleteEntry,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}