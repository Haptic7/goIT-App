import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart'; // Import your HomeScreen widget

class TermsAndConsentScreen extends StatefulWidget {
  final VoidCallback onConsentGiven;

  const TermsAndConsentScreen({super.key, required this.onConsentGiven});

  @override
  State<TermsAndConsentScreen> createState() => _TermsAndConsentScreenState();
}

class _TermsAndConsentScreenState extends State<TermsAndConsentScreen> {
  bool _hasConsentedBiometrics = false;
  bool _hasAcceptedMedicalDisclaimer = false;

  bool get _canProceed => _hasConsentedBiometrics && _hasAcceptedMedicalDisclaimer;

  Future<void> _saveConsentAndProceed() async {
  if (!_canProceed) return;

  // 1. Save consent status locally
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('has_accepted_terms_v1', true);

  // 2. Redirect straight to the Home Screen
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your HomeScreen widget
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Biometric & Health Clearance', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon & Description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Color(0xFF2DD4BF), size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Please review and accept our privacy policy to use facial wellness scanning.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable Policy Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      '''
HEARTIQ TERMS OF SERVICE & BIOMETRIC PRIVACY POLICY

1. Medical Disclaimer & Non-Diagnostic Notice
The Application provides remote photoplethysmography (rPPG) assessment tools for general wellness purposes only. It is NOT a certified medical device and does NOT provide diagnosis, medical advice, or treatment plans. If you are experiencing a medical emergency, call 911 or local emergency services immediately.

2. Biometric Data Retention & Destruction (BIPA Compliance)
In compliance with the Illinois Biometric Information Privacy Act (BIPA):
• Collection: We temporarily process facial geometry and blood volume pulse (BVP) waveforms using your camera to estimate wellness metrics.
• On-Device Processing: Processing occurs exclusively in your device's volatile memory (RAM). No raw video, biometric identifiers, or mathematical templates are uploaded to cloud servers or third parties.
• Immediate Erasure: All biometric data is automatically, permanently destroyed immediately upon scan completion.

3. Limitation of Liability
The Application is provided "AS IS". heartiQ is not liable for health decisions or outcomes derived from software outputs.
                      ''',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox 1: Biometric Consent
              _buildCheckboxRow(
                value: _hasConsentedBiometrics,
                onChanged: (val) => setState(() => _hasConsentedBiometrics = val ?? false),
                text: 'I explicitly consent to the capture, local processing, and immediate erasure of my facial biometric identifiers for wellness estimation.',
              ),

              const SizedBox(height: 8),

              // Checkbox 2: Medical Disclaimer
              _buildCheckboxRow(
                value: _hasAcceptedMedicalDisclaimer,
                onChanged: (val) => setState(() => _hasAcceptedMedicalDisclaimer = val ?? false),
                text: 'I understand this app provides general wellness info, does NOT diagnose medical conditions, and is not a substitute for a doctor.',
              ),

              const SizedBox(height: 16),

              // Agree & Proceed Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canProceed ? _saveConsentAndProceed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'AGREE & START SCAN',
                    style: TextStyle(
                      color: _canProceed ? Colors.black : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2DD4BF),
              checkColor: Colors.black,
              side: const BorderSide(color: Colors.white38, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}