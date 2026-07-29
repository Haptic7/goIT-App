import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heart_iq/firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:heart_iq/services/rppg_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final rppgService = RppgService();
  await rppgService.initModel();
  await dotenv.load(fileName: ".env");

  runApp(const HeartIQApp());
}

class HeartIQApp extends StatelessWidget {
  const HeartIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'heartiQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}