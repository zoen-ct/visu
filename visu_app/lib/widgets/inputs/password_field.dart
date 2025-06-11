import 'package:flutter/material.dart';
import 'app_text_field.dart';
/// A specialized widget for password fields with a functionality to show/hide
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Mot de passe',
    this.hintText = 'Entrez votre mot de passe',
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor = const Color(0xFF1D2F3E),
    this.textColor = const Color(0xFFF4F6F8),
    this.labelColor = const Color(0xFFF8C13A),
    this.iconColor = const Color(0xFFF8C13A),
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Color backgroundColor;
  final Color textColor;
  final Color labelColor;
  final Color iconColor;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscureText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: widget.iconColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      labelColor: widget.labelColor,
    );
  }
}
