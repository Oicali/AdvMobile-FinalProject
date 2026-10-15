import 'package:flutter/material.dart';

// Small pill tag; attention = orange (overdue / not available)
class StatusTag extends StatelessWidget {
  final String text;
  final bool attention;
  const StatusTag({super.key, required this.text, this.attention = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: attention ? const Color(0xFFFFE9D6) : const Color(0xFFE3F0EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: attention ? const Color(0xFF7A3A0B) : const Color(0xFF0F5C5C),
        ),
      ),
    );
  }
}