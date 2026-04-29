import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

// handles Firebase Storage uploads
class StorageService {
  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // upload image file and return download URL
  Future<String> uploadEntryImage(File imageFile, String userId) async {
    // create unique file name
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // create storage path
    final ref = _storage.ref().child('entry_images/$userId/$fileName');

    // upload file to Firebase Storage
    await ref.putFile(imageFile);

    // return public download URL
    return await ref.getDownloadURL();
  }
}