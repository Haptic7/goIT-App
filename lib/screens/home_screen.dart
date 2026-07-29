import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heart_iq/screens/app_colors.dart';
import 'emergency_screen.dart';
import 'diet_lifestyle_screen.dart';
import 'scan_screen.dart';
import 'symptom_check_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Dynamic variables populated from device storage
  int? _lastBpm;
  String _lastScanTime = "No scans yet";

  String _lastSymptom = "No symptoms logged";
  String _symptomSeverity = "N/A";
  String _symptomDate = "--";

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  // Fetch saved data from Face Scan and Symptom Check
  Future<void> _loadHealthData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _lastBpm = prefs.getInt('last_bpm');
      _lastScanTime = prefs.getString('last_scan_time') ?? "No scans yet";
      _lastSymptom = prefs.getString('last_symptom') ?? "No symptoms logged";
      _symptomSeverity = prefs.getString('symptom_severity') ?? "N/A";
      _symptomDate = prefs.getString('symptom_date') ?? "--";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      // Top App Bar styled with AppColors
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: Colors.white,
        title: const Text(
          'Heart iQ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                );
              },
              icon: const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.white),
              label: const Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),

      // Main Content Dashboard
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.card,
        onRefresh: _loadHealthData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health Summary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Face Scan Summary Card
              _buildScanSummaryCard(),

              const SizedBox(height: 16),

              // 2. Symptom Summary Card
              _buildSymptomSummaryCard(),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar with AppColors
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _navigateToFeature(index);
        },
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Diet & Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.center_focus_strong_rounded),
            label: 'Face Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late_rounded),
            label: 'Symptom Check',
          ),
        ],
      ),
    );
  }

  // Widget: Face Scan Summary Card
  Widget _buildScanSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite_rounded, color: AppColors.accent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Latest Face Scan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                _lastScanTime,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            children: [
              Text(
                _lastBpm != null ? '$_lastBpm' : '--',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BPM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    'Resting Pulse',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget: Symptom Summary Card
  Widget _buildSymptomSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment_turned_in_rounded, color: AppColors.accent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Latest Symptom Check',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                _symptomDate,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lastSymptom,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reported Symptom',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
              Chip(
                label: Text('Severity: $_symptomSeverity'),
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                labelStyle: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                side: BorderSide.none,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Handle Bottom Toolbar Navigations
  void _navigateToFeature(int index) async {
    if (index == 0) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DietAndLifestyleScreen()),
      );
    } else if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanScreen()),
      );
      _loadHealthData();
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SymptomCheckScreen()),
      );
      _loadHealthData();
    }
  }
}