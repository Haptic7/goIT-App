import 'package:flutter/material.dart';

//==============================================
// DIET AND LIFESTYLE SCREEN
//==============================================
class DietAndLifestyleScreen extends StatelessWidget {
  const DietAndLifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diet and Lifestyle'), automaticallyImplyLeading: true),
      body: const Center(
        child: Text('Diet and Lifestyle Content Goes Here', style: TextStyle(fontSize: 18, color: Colors.white70)),
      ),
    );
  }
}