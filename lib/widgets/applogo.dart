import 'package:flutter/material.dart';


class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 200});

  static const Color teal = Color(0xFF0F5C5C);

  @override
  Widget build(BuildContext context) {

    return Image.asset(
      'assets/images/PahiramLogo.png',
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
        child: Text('P', style: TextStyle(color: Colors.white, fontSize: size * 0.5, fontWeight: FontWeight.w800)),
      ),
    );
  }
}