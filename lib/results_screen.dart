import 'package:flutter/material.dart';
import 'package:heart_iq/app_colors.dart';
import 'home_screen.dart';

//==============================================
// RESULTS SCREEN
//==============================================
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Metrics Evaluation'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.check_circle_outline, size: 72, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Biometric Metrics Extracted', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _buildResultRow('Heart Rate (Calculated)', '74 BPM'),
            _buildResultRow('Heart Rate Variability (HRV)', '62 ms'),
            _buildResultRow('Cardiovascular Stress Index', 'Low / Normal'),
            _buildResultRow('Phenotypic CAD Risk Match', '0.12 (Low Probability)'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text('Return to Dashboard', style: TextStyle(color: AppColors.accent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accent)),
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
InputDecoration InputDecoration_buildInputDecoration (String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}