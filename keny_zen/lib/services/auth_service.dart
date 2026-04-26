import 'package:firebase_auth/firebase_auth.dart';

// handles all authentication logic
class AuthService {
  // instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get current logged-in user
  User? get currentUser => _auth.currentUser;

  // listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // sign up user with email + password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  // log in user with email + password
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // log out current user
  Future<void> logout() async {
    await _auth.signOut();
  }
}