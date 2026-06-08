import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              child: const Image(image: AssetImage('images/app_icon')),
            ),
            const SizedBox(height: 20),
            const Text(
              'CurrenSee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Smart Currency Conversion',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 60),
            CircularProgressIndicator(color:Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
            const SizedBox(height: 40),
            const Text(
              'By ABC Finance Ltd.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}