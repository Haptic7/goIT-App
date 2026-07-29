import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DietAndLifestyleScreen extends StatefulWidget {
  const DietAndLifestyleScreen({super.key});

  @override
  State<DietAndLifestyleScreen> createState() => _DietAndLifestyleScreenState();
}

class _DietAndLifestyleScreenState extends State<DietAndLifestyleScreen> {
  bool _isLoading = true;
  
  // Stored health data
  int? _lastBpm;
  String? _lastSymptom;
  String? _symptomSeverity;

  // AI-generated tips & articles
  List<String> _dietTips = [];
  List<String> _lifestyleTips = [];
  String _articleSummary = '';

  @override
  void initState() {
    super.initState();
    _loadDataAndGenerateRecommendations();
  }

  // --- Step 1: Read SharedPreferences & Fetch Recommendations ---
  Future<void> _loadDataAndGenerateRecommendations() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _lastBpm = prefs.getInt('last_bpm');
      _lastSymptom = prefs.getString('last_symptom');
      _symptomSeverity = prefs.getString('symptom_severity');
    });

    await _fetchAiRecommendations();
  }

  // --- Step 2: Query Gemini AI for Personalize Tips ---
  Future<void> _fetchAiRecommendations() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    // Fallback defaults if no API key or health data exists yet
    if (apiKey == null || apiKey.isEmpty) {
      _useDefaultRecommendations();
      return;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
Generate health & lifestyle tips based on these patient vitals:
- Heart Rate: ${_lastBpm ?? 'Unknown'} BPM
- Recent Symptom: ${_lastSymptom ?? 'None reported'}
- Symptom Severity: ${_symptomSeverity ?? 'Low'}

Provide response strictly formatted as:
[DIET]
- Tip 1
- Tip 2
[LIFESTYLE]
- Tip 1
- Tip 2
[ARTICLE]
Title: [Article Title]
Body: [2-3 sentence overview]
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text ?? '';

      _parseAiResponse(text);
    } catch (e) {
      _useDefaultRecommendations();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Parse structured text from AI output
  void _parseAiResponse(String responseText) {
    List<String> dietList = [];
    List<String> lifestyleList = [];
    String articleText = '';

    if (responseText.contains('[DIET]')) {
      final dietPart = responseText.split('[DIET]')[1].split('[LIFESTYLE]')[0];
      dietList = dietPart
          .split('\n')
          .where((line) => line.trim().startsWith('-'))
          .map((line) => line.replaceAll('-', '').trim())
          .toList();
    }

    if (responseText.contains('[LIFESTYLE]')) {
      final lifestylePart = responseText.split('[LIFESTYLE]')[1].split('[ARTICLE]')[0];
      lifestyleList = lifestylePart
          .split('\n')
          .where((line) => line.trim().startsWith('-'))
          .map((line) => line.replaceAll('-', '').trim())
          .toList();
    }

    if (responseText.contains('[ARTICLE]')) {
      articleText = responseText.split('[ARTICLE]')[1].trim();
    }

    setState(() {
      _dietTips = dietList.isNotEmpty ? dietList : _defaultDietTips();
      _lifestyleTips = lifestyleList.isNotEmpty ? lifestyleList : _defaultLifestyleTips();
      _articleSummary = articleText.isNotEmpty ? articleText : 'Heart Healthy Living: Small daily habits reduce cardiovascular strain.';
    });
  }

  void _useDefaultRecommendations() {
    setState(() {
      _dietTips = _defaultDietTips();
      _lifestyleTips = _defaultLifestyleTips();
      _articleSummary = 'Maintaining Cardiovascular Balance: Focus on fiber-rich whole foods, magnesium intake, and active stress management.';
      _isLoading = false;
    });
  }

  List<String> _defaultDietTips() => [
        'Increase potassium-rich foods like leafy greens and bananas.',
        'Stay hydrated with 8–10 glasses of water daily.',
        'Limit excessive sodium and processed sugars.'
      ];

  List<String> _defaultLifestyleTips() => [
        'Aim for 7–8 hours of uninterrupted sleep every night.',
        'Incorporate 15–30 minutes of light aerobic walking daily.',
        'Practice 5 minutes of deep belly breathing to settle pulse rate.'
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Diet & Lifestyle Guidance', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Health Status Header ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Targeted Vitals Profile',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Heart Rate: ${_lastBpm != null ? "$_lastBpm BPM" : "Not Scanned"}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(_lastSymptom ?? 'No Symptoms'),
                          backgroundColor: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12),
                          side: BorderSide.none,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Tailored Diet Tips Section ---
                  const Text('Nutrition Recommendations', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._dietTips.map((tip) => _buildTipCard(Icons.restaurant_menu_rounded, tip)),

                  const SizedBox(height: 24),

                  // --- Tailored Lifestyle Tips Section ---
                  const Text('Lifestyle & Recovery Tips', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._lifestyleTips.map((tip) => _buildTipCard(Icons.self_improvement_rounded, tip)),

                  const SizedBox(height: 24),

                  // --- Featured Medical Reading / Article ---
                  const Text('Curated Article', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.article_rounded, color: Color(0xFF2DD4BF)),
                            SizedBox(width: 8),
                            Text('Recommended Insight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        Text(
                          _articleSummary,
                          style: const TextStyle(color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTipCard(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2DD4BF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}