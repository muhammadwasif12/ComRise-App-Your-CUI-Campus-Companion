import 'package:flutter/material.dart';

class UniTipsScreen extends StatelessWidget {
  const UniTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation'),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emoji_emotions, size: 100, color: Color(0xFFFF5722)),
            SizedBox(height: 20),
            Text(
              'Daily Motivation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Stay inspired and motivated!'),
          ],
        ),
      ),
    );
  }
}
