import 'package:flutter/material.dart';

/// A widget to display an error message with the possibility to retry
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = 48.0,
    this.textColor = const Color(0xFFF4F6F8),
    this.buttonText = 'Réessayer',
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final Color textColor;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: textColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
              ),
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }
}
