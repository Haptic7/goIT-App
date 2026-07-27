import 'package:flutter/material.dart';
//import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heart_iq/app_colors.dart';
import 'login_screen.dart';
//import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  runApp(const HeartIQApp());
}

class HeartIQApp extends StatelessWidget {
  const HeartIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart iQ',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
      ),
      home: const LoginScreen(),
    );
  }
}