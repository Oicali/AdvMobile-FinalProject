import 'dart:async';
import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/widgets/applogo.dart';

// Widget class (XState naming convention)
class SplashState extends StatefulWidget {
  const SplashState({super.key});

  @override
  State<SplashState> createState() => SplashPage();
}

// State class (XPage naming convention)
class SplashPage extends State<SplashState> {
  Timer? timer;
  bool visible = false;

  static const Color mint = Color(0xFF74C5A8);
  static const Color teal = Color(0xFF0F5C5C);

  // Fade the logo in, then go to Login after about 2 seconds
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => visible = true);
    });
    timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  // Cancel the timer so it can't navigate after the screen is gone
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: Column(
          children: [
            // Logo and tagline, centered
            Expanded(
              child: Center(
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogo(size: 180),
                      SizedBox(height: 14),
                      Text(
                        'Borrow what you need. Lend what you don\'t.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: teal),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Small loader at the bottom
            const Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}