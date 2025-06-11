import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A widget to display a media poster image (movie, series)
/// with loading and error handling
class MediaPoster extends StatelessWidget {
  const MediaPoster({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.error,
    this.errorColor = Colors.red,
    this.loadingColor = const Color(0xFFF8C13A),
    this.placeholderColor = const Color(0xFF2A3B4B),
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData errorIcon;
  final Color errorColor;
  final Color loadingColor;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    final borderRadiusValue = borderRadius ?? BorderRadius.zero;

    return ClipRRect(
      borderRadius: borderRadiusValue,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder:
            (context, url) => Container(
              color: placeholderColor,
              child: Center(
                child: CircularProgressIndicator(color: loadingColor),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: placeholderColor,
              child: Center(child: Icon(errorIcon, color: errorColor)),
            ),
      ),
    );
  }
}
