import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// signup screen for new users
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// handles signup form and Firebase signup logic
class _SignupScreenState extends State<SignupScreen> {
  // controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // instance of auth service
  final AuthService _authService = AuthService();

  // track loading state
  bool _isLoading = false;

  // function to handle signup
  void _signup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // create Firebase account
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // stop if widget is no longer active
      if (!mounted) return;

      // save safe context after async check
      final navigator = Navigator.of(context);

      // navigate to home if signup works
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      // stop if widget is no longer active
      if (!mounted) return;

      // save safe context after async check
      final messenger = ScaffoldMessenger.of(context);

      // show error message
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
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
    // clean up controllers
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // center content
      body: Padding(
        padding: const EdgeInsets.all(24.0),

        // keep content centered
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // email input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 12),

            // password input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 24),

            // signup button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),

            const SizedBox(height: 12),

            // navigate back to login screen
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}