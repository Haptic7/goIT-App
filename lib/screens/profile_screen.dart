import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Personal Details Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _personalPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Password Management Controllers
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Emergency Contact Controller
  final TextEditingController _emergencyPhoneController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // --- Step 1: Load Existing Saved Profile Settings ---
  Future<void> _loadUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    try {
      // 1. Read document from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _firstNameController.text = data?['firstName'] ?? '';
          _lastNameController.text = data?['lastName'] ?? '';
          _emailController.text = data?['email'] ?? user.email ?? '';
          _personalPhoneController.text = data?['personal_phone'] ?? '';
          _addressController.text = data?['address'] ?? '';
          _countryController.text = data?['country'] ?? '';
          _emergencyPhoneController.text = data?['emergency_phone'] ?? '';
        });
      }
    } catch (e) {
      _showSnackBar('Error loading profile from cloud: $e', Colors.redAccent);
    }
  }

  setState(() => _isLoading = false);
}

Future<void> _saveUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final newPassword = _newPasswordController.text;
  final confirmPassword = _confirmPasswordController.text;

  final personalPhone = _personalPhoneController.text.trim();
  final emergencyPhone = _emergencyPhoneController.text.trim();

  // Password Update via Firebase Auth
  if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
    if (newPassword != confirmPassword) {
      _showSnackBar('New passwords do not match.', Colors.redAccent);
      return;
    }
    try {
      await user.updatePassword(newPassword);
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Failed to update password.', Colors.redAccent);
      return;
    }
  }

  // --- Phone Conflict Check ---
  if (personalPhone.isNotEmpty &&
        emergencyPhone.isNotEmpty &&
        personalPhone == emergencyPhone) {
      _showSnackBar('Emergency contact phone cannot be the same as your personal phone.', Colors.redAccent);
      return;
    }
    
  try {
    // 1. Update Firestore Document
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'personal_phone': _personalPhoneController.text.trim(),
      'address': _addressController.text.trim(),
      'country': _countryController.text.trim(),
      'emergency_phone': _emergencyPhoneController.text.trim(),
    });

    // 2. Mirror to SharedPreferences for instant offline access in Emergency Screen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_first_name', _firstNameController.text.trim());
    await prefs.setString('user_last_name', _lastNameController.text.trim());
    await prefs.setString('user_country', _countryController.text.trim());
    await prefs.setString('emergency_phone', _emergencyPhoneController.text.trim());

    _showSnackBar('Profile updated successfully!', const Color(0xFF2DD4BF));
  } catch (e) {
    _showSnackBar('Failed to update profile: $e', Colors.redAccent);
  }
}

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _personalPhoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Account Profile', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Avatar
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2DD4BF),
                    child: Icon(Icons.person, size: 45, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Personal Details
                  _buildSectionHeader('Personal Details'),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _personalPhoneController,
                    label: 'Personal Phone',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    hintText: '+1 555-0199',
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _addressController,
                    label: 'Home / Primary Address',
                    icon: Icons.home_outlined,
                    hintText: '123 Health St, Suite 100',
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    controller: _countryController,
                    label: 'Country / Region',
                    icon: Icons.public_outlined,
                    hintText: 'e.g., United States, India, United Kingdom',
                  ),

                  // Section 2: Security & Password
                  _buildSectionHeader('Security & Password'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    icon: Icons.lock_reset_outlined,
                    isObscured: true,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    icon: Icons.check_circle_outline,
                    isObscured: true,
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Emergency Contact
                  _buildSectionHeader('Emergency Contact'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Emergency Contact Phone Number',
                    icon: Icons.contact_phone_outlined,
                    keyboardType: TextInputType.phone,
                    hintText: '+11234567890',
                  ),
                  const SizedBox(height: 30),

                  // Save Settings Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveUserProfile,
                      icon: const Icon(Icons.save, color: Colors.black),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isObscured = false,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isObscured,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFF2DD4BF)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2DD4BF)),
        ),
      ),
    );
  }
}