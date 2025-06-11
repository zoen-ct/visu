import 'package:flutter/material.dart';

/// A widget to display a message when a list is empty
/// with the possibility of an action (like "Add" or "Search")
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.info_outline,
    this.iconColor = const Color(0xFFF8C13A),
    this.iconSize = 64.0,
    this.textColor = const Color(0xFFF4F6F8),
    this.subtitleColor = Colors.grey,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final Color textColor;
  final Color subtitleColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: textColor, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(color: subtitleColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.add),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8C13A),
                foregroundColor: const Color(0xFF16232E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
