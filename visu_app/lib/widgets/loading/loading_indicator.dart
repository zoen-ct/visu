import 'package:flutter/material.dart';

/// A widget to display a uniform loading indicator throughout the application
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color = const Color(0xFFF8C13A),
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
