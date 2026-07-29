import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/terms_consent_screen.dart'; // Adjust path based on your folder structure
import '../screens/home_screen.dart';          // Adjust path based on your folder structure

Future<void> navigateAfterAuth(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final bool hasConsented = prefs.getBool('has_accepted_terms_v1') ?? false;

  if (!context.mounted) return;

  if (!hasConsented) {
    // T&C not accepted yet -> Go to Terms & Consent Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TermsAndConsentScreen(
          onConsentGiven: () {
            // After consenting, navigate to Home Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
    );
  } else {
    // Already accepted -> Go directly to Home Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}