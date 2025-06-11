import 'package:flutter/material.dart';

/// A widget for circular action buttons used in media cards
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isActive = false,
    this.tooltip,
    this.backgroundColor,
    this.activeColor = const Color(0xFFF8C13A),
    this.inactiveColor = const Color(0xFF16232E),
    this.iconColor,
    this.size = 40,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isActive;
  final String? tooltip;
  final Color? backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        backgroundColor ?? (isActive ? activeColor : inactiveColor);
    final Color fgColor =
        iconColor ?? (isActive ? inactiveColor : Colors.white);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: IconButton(
        icon:
            isLoading
                ? SizedBox(
                  width: iconSize - 4,
                  height: iconSize - 4,
                  child: CircularProgressIndicator(
                    color: fgColor,
                    strokeWidth: 2,
                  ),
                )
                : Icon(icon, color: fgColor),
        onPressed: isLoading ? null : onPressed,
        tooltip: tooltip,
        iconSize: iconSize,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
