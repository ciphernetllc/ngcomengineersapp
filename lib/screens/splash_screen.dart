import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () => Navigator.pushReplacementNamed(context, '/onboarding'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with scale and fade animation
                Image.asset(
                  'assets/images/ngcom_logo.webp',
                  width: 200,
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 600.ms),
                const SizedBox(height: 24),
                // Text with slide and fade animation
                Text(
                  'Connectivity Redefined',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 800.ms)
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),
          // Loading indicator at the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  strokeWidth: 3,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1500.ms, duration: 500.ms),
            ),
          ),
        ],
      ),
    );
  }
}
