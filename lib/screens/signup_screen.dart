import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/navigation_helper.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _personalPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUpUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final personalPhone = _personalPhoneController.text.trim();
    final emergencyPhone = _emergencyPhoneController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields.')),
      );
      return;
    }

    if (personalPhone.isNotEmpty &&
        emergencyPhone.isNotEmpty &&
        personalPhone == emergencyPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency contact phone cannot be the same as your personal phone.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Firebase Auth User
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        // 2. Save User Details to Firestore
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'heart-iq',
      ).collection('users').doc(uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': email,
          'personal_phone': _personalPhoneController.text.trim(),
          'address': _addressController.text.trim(),
          'country': _countryController.text.trim(),
          'emergency_phone': _emergencyPhoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
       await navigateAfterAuth(context); // Go back or navigate to Home
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign up failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _personalPhoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Create Account', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_firstNameController, 'First Name', Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
                ),
              ],
            ),
            const SizedBox(height:12),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField(_passwordController, 'Password', Icons.lock_outline, isObscured: true),
            const SizedBox(height: 12),
            _buildTextField(_personalPhoneController, 'Personal Phone', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(_addressController, 'Address', Icons.home_outlined),
            const SizedBox(height: 12),
            
            // --- Added Country & Emergency Phone Fields ---
            _buildTextField(_countryController, 'Country / Region', Icons.public_outlined, hintText: 'e.g., United States'),
            const SizedBox(height: 12),
            _buildTextField(_emergencyPhoneController, 'Emergency Contact Phone', Icons.contact_phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUpUser,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Sign Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscured = false,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFF2DD4BF)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}