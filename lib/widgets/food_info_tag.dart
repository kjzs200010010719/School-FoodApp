import 'package:flutter/material.dart';

class FoodInfoTag extends StatelessWidget {
  const FoodInfoTag({super.key, required this.text, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = warning
        ? const Color(0xFFFFF1CC)
        : const Color(0xFFEAF5E8);
    final foregroundColor = warning
        ? const Color(0xFFD68A00)
        : const Color(0xFF4E8D57);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
