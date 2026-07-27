import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heart_iq/app_colors.dart';

//==============================================
// SYMPTOM CHECK SCREEN
//==============================================
class SymptomCheckScreen extends StatefulWidget {
  const SymptomCheckScreen({super.key});
  
  @override
  State<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends State<SymptomCheckScreen> {

  final _symptomController = TextEditingController();

  String _aiAdvice = "Enter your symptoms above to get advice.";
  bool _isLoading = false;

  String? _errorText;

  Future<void> _getAIAdvice() async {
    if (_symptomController.text.trim().isEmpty) {
      setState(() {
        _errorText = "Please enter your symptoms before checking.";
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    final apiKey = dotenv.get('GEMINI_API_KEY'); // Replace with your actual API key

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      // Instructions for the AI model to provide advice based on symptoms
      systemInstruction: Content.system('''
        You are a helpful triage assistant.
        If the user inpts mild, common symptoms (like a light headache, mild couch, or fatigue), suggest gentle home remedies like drinking more water, resting, or eating specific healthy foods (e.g., nuts, broths).
        DO NOT DIAGNOSE DISEASES
        If the symptoms are severs or concerning (e.g., chest pain, shortness of breath, severe bleeding, high fever), immediately advise them to seek professional medical help or go to an emergency room.
      '''),
    );
    
    try {
      final prompt = _symptomController.text;
      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);

      setState(() {
        _aiAdvice = response.text ?? "I couldn't process that. Please try again.";
      });
    } catch (e) {
      setState(() {
        _aiAdvice = "Error communicating with AI: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Check'), automaticallyImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'List your symptoms below and we will provide a preliminary analysis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
             'This is not a substitute for professional medical advice.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            const SizedBox(height: 32),
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                labelText: 'How are you feeling today?',
                border: const OutlineInputBorder(),
                hintText: 'e.g., I have a slight headache and feel tired.',
                errorText: _errorText,
                ),
                maxLines: 3,
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null: _getAIAdvice,
                child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Check Symptoms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent),
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    _aiAdvice,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}