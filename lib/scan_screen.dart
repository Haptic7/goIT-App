import 'package:flutter/material.dart';
import 'package:heart_iq/app_colors.dart';
import 'results_screen.dart';

//==============================================
// SCAN SCREEN
//==============================================
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  Future<void> _runMockScan() async {
    setState(() {
      _isScanning = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Scan'), automaticallyImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _isScanning ? AppColors.accent : Colors.transparent, width: 3),
                ),
                child: Center(
                  child: _isScanning
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.accent),
                            SizedBox(height: 16),
                            Text('TS-CAN Processing Optical Vectors...', style: TextStyle(color: Colors.white70)),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_front, size: 80, color: Colors.white38),
                            SizedBox(height: 16),
                            Text('Align your face inside the framing area', style: TextStyle(color: Colors.white60)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning ? Colors.grey : AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isScanning ? null : _runMockScan,
                child: Text(_isScanning ? 'Processing Analysis...' : 'Start 45s Scan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}