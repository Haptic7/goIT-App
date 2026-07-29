import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heart_iq/screens/app_colors.dart';
import 'signup_screen.dart';
import '../utils/navigation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginUser() async {
  // Validate inputs first
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields.')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 1. Authenticate with Firebase
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 2. PASTE STEP 3 HERE: Check T&C consent & navigate
    if (mounted) {
      await navigateAfterAuth(context);
    }
  } on FirebaseAuthException catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed.')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Heart iQ - Login', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.accent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.accent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
              child: _isLoading
                ? const CircularProgressIndicator(color: AppColors.background)
                : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navigate to Sign Up Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text(
                "Dont't have an account? Sign Up",
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}