import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/journal_entry.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

// screen for creating a new journal entry
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

// handles journal entry form state
class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _contentController = TextEditingController();

  String _selectedMood = 'Calm';

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;

  // selected image file
  File? _selectedImage;

  final List<String> _moods = [
    'Calm',
    'Happy',
    'Stressed',
    'Sad',
    'Overwhelmed',
  ];

  // pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }

  // save journal entry to Firestore
  void _saveEntry() async {
    final content = _contentController.text.trim();
    final user = _authService.currentUser;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first.')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // upload image if selected
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadEntryImage(
          _selectedImage!,
          user.uid,
        );
      }

      final entry = JournalEntry(
        id: '',
        userId: user.uid,
        content: content,
        mood: _selectedMood,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
      );

      await _firestoreService.addEntry(entry);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write your thoughts:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

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

              const SizedBox(height: 20),

              // image picker button
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Attach Image'),
              ),

              const SizedBox(height: 12),

              // preview selected image
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150),

              const SizedBox(height: 24),

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
      ),
    );
  }
}