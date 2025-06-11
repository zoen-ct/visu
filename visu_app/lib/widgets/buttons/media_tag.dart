import 'package:flutter/material.dart';

/// A widget to display a tag on media cards
class MediaTag extends StatelessWidget {
  const MediaTag({
    super.key,
    required this.label,
    this.backgroundColor = const Color(0xFFF8C13A),
    this.textColor = const Color(0xFF16232E),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 20,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
