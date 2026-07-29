import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SymptomCheckScreen extends StatefulWidget {
  const SymptomCheckScreen({super.key});

  @override
  State<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends State<SymptomCheckScreen> {
  final TextEditingController _symptomController = TextEditingController();
  
  bool _isAnalyzing = false;
  String? _aiResponseText;
  String _calculatedSeverity = 'Low';

  // --- Step A: Process User Input with AI ---
  Future<void> _analyzeSymptomWithAI() async {
    final userText = _symptomController.text.trim();
    if (userText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms first.')),
      );
      return;
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key not found in .env file.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
User reported health symptoms: "$userText".
Provide a brief analysis in 2 parts:
1. Assign an overall severity level strictly as one word: "Low", "Moderate", or "High".
2. Give 1-2 sentences of safe, non-diagnostic guidance.
Format your output exactly like:
Severity: [Low/Moderate/High]
Advice: [Your brief guidance]
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      if (responseText.contains('Severity: High')) {
        _calculatedSeverity = 'High';
      } else if (responseText.contains('Severity: Moderate')) {
        _calculatedSeverity = 'Moderate';
      } else {
        _calculatedSeverity = 'Low';
      }

      // Check if widget is still in the tree before updating state
      if (!mounted) return;

      setState(() {
        _aiResponseText = responseText;
      });

      await _saveSymptomData(userText, _calculatedSeverity);

    } catch (e) {
      // Guard context usage across the async gap
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error contacting AI: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // --- Step B: Save User Inputs & AI Output to Disk ---
  Future<void> _saveSymptomData(String symptom, String severity) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final dateString = "Today, ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    await prefs.setString('last_symptom', symptom);
    await prefs.setString('symptom_severity', severity);
    await prefs.setString('symptom_date', dateString);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Symptom Checker', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe What You Are Feeling',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            
            // User Input Field
            TextField(
              controller: _symptomController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Mild headache, feeling fatigued after walking...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeSymptomWithAI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Analyze Symptoms',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // AI Response Display
            if (_aiResponseText != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Analysis',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Chip(
                          label: Text('Severity: $_calculatedSeverity'),
                          backgroundColor: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold),
                          side: BorderSide.none,
                        )
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    Text(
                      _aiResponseText!,
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Return Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Save & Return to Home', style: TextStyle(color: Color(0xFF2DD4BF))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}