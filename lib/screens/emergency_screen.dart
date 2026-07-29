import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'home_screen.dart';
import 'emergency_call_screen.dart';

//==============================================
// EMERGENCY SCREEN - FALSE ALARM
//==============================================
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _secondsLeft = 10;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted || _isExpired) return;

      setState(() {
        _secondsLeft -= 1;
      });

      if (_secondsLeft > 0) {
        _startTimer();
      } else {
        setState(() {
          _isExpired = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyCallScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpired = true;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyCallScreen()),
                    );
                  },
                  child: const Text(
                    'SOS',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Click the button if you need help.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                'Auto-redirecting in $_secondsLeft seconds',
                style: const TextStyle(fontSize: 16, color: AppColors.accent),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                  child: const Text('Return to Home Screen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}