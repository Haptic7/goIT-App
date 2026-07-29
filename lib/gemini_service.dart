import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> analyzeSymptoms(String currentSymptoms) async {
    try {

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Error: You must be logged in to use this feature.";
      }

      DocumentSnapshot userDoc = await _db.collection('users').doc(currentUser.uid).get();

      String medicalHistory = "None";
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data as Map<String, dynamic>;
        medicalHistory = data['medicalConditions'] ?? "None";
      }

      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) throw Exception("API Key not found in .env");

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );

      final prompt = '''
      You are an AI assistant for a heart health app called 'Heart iQ'.
      You are providing general inofrmational insights based on user symptoms.

      USER'S KNOWN MEDICAL HISTORY:
      $medicalHistory

      USER'S CURRENT SYMPTOMS:
      $currentSymptoms

      INSTRUCTIONS:
      Analyze their currrent symptoms taking their medical history into account.
      Be concise, empathetic, and clear.
      IMPORTANT: Always include a brief disclaimer that you are an AI, not a doctor, and they should seek proffessional medical help for severe chest pain or emergencies.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm sorry, I couldn't generate a response rigt now.";

    } catch (e) {
      return "An error occured while connecting to the AI: $e";
    }
  }
}