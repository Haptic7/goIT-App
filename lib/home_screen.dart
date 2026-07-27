import 'package:flutter/material.dart';
import 'package:heart_iq/app_colors.dart';
import 'emergency_screen.dart';
import 'diet_lifestyle_screen.dart';
import 'scan_screen.dart';
import 'symptom_check_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.white60)),
            const Text('User', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 155, 26, 26),
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
                },
                label: const Text('EMERGENCY', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LAST BIOMETRIC SCAN', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('72 BPM', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  Text('Status: Optimal Cardiovascular Baseline', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DietAndLifestyleScreen()));
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 18),
                            SizedBox(height: 4),
                            Text('Diet and Lifestyle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face, size: 18),
                            SizedBox(height: 4),
                            Text('Face Scan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SymptomCheckScreen()));
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description, size: 18),
                            SizedBox(height: 4),
                            Text('Symptom Check', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}