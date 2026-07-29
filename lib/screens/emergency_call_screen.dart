import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen> {
  String _emergencyServicesNumber = '911'; // Default fallback
  String? _personalEmergencyContact;
  bool _isLoading = true;

  // --- Map of Common Countries to Emergency Numbers ---
  static const Map<String, String> _emergencyNumberMap = {
    'united states': '911',
    'us': '911',
    'usa': '911',
    'canada': '911',
    'united kingdom': '999',
    'uk': '999',
    'india': '112', // 112 is the unified emergency number in India (or 108 for ambulances)
    'australia': '000',
    'germany': '112',
    'france': '112',
    'japan': '119',
    'philippines': '911',
    'mexico': '911',
  };

  @override
  void initState() {
    super.initState();
    _initializeEmergencyData();
  }

  // --- Step 1: Read Saved Region & Contact Info ---
  Future<void> _initializeEmergencyData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCountry = prefs.getString('user_country')?.toLowerCase().trim() ?? '';
    final savedContact = prefs.getString('emergency_phone');

    // Resolve country emergency number or default to 911 / 112
    String resolvedNumber = '911';
    if (_emergencyNumberMap.containsKey(savedCountry)) {
      resolvedNumber = _emergencyNumberMap[savedCountry]!;
    } else if (savedCountry.isNotEmpty) {
      resolvedNumber = '112'; // 112 works globally on GSM networks
    }

    setState(() {
      _emergencyServicesNumber = resolvedNumber;
      _personalEmergencyContact = savedContact;
      _isLoading = false;
    });

    // Automatically place call to resolved regional number
    _callNumber(_emergencyServicesNumber);
  }

  Future<void> _callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not initiate call to $number')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error making call: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Emergency Response', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- Emergency Services Banner ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emergency_rounded,
                          size: 60,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Contacting Emergency Services ($_emergencyServicesNumber)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _callNumber(_emergencyServicesNumber),
                          icon: const Icon(Icons.call, color: Colors.white, size: 18),
                          label: Text(
                            'Call $_emergencyServicesNumber Now',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Personal Contact Button ---
                  if (_personalEmergencyContact != null && _personalEmergencyContact!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _callNumber(_personalEmergencyContact!),
                        icon: const Icon(Icons.person_pin_rounded, color: Color(0xFF2DD4BF)),
                        label: Text(
                          'Call Personal Contact ($_personalEmergencyContact)',
                          style: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2DD4BF)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // --- First Aid Guidance ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'While You Wait For Paramedics:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildEmergencyTipCard(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    title: '1. Sit and Rest Immediately',
                    description: 'Stop all activity. Sit upright with knees bent to reduce heart strain.',
                  ),
                  _buildEmergencyTipCard(
                    icon: Icons.checkroom_rounded,
                    title: '2. Loosen Tight Clothing',
                    description: 'Unbutton tight collars, belts, or waistbands to assist breathing.',
                  ),
                  _buildEmergencyTipCard(
                    icon: Icons.air_rounded,
                    title: '3. Slow, Controlled Breathing',
                    description: 'Inhale slowly through your nose, exhale through your mouth.',
                  ),
                  _buildEmergencyTipCard(
                    icon: Icons.pan_tool_rounded,
                    title: '4. Do Not Walk Around',
                    description: 'Stay completely still until paramedics arrive.',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmergencyTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2DD4BF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}