import 'package:flutter/material.dart';

class VisuTextField extends StatefulWidget {
  const VisuTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  @override
  State<VisuTextField> createState() => _VisuTextFieldState();
}

class _VisuTextFieldState extends State<VisuTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _hasError = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    if (_hasError) {
      labelColor = Colors.red;
    } else if (_hasFocus || _hasText) {
      labelColor = const Color(
        0xFFF8C13A,
      );
    } else {
      labelColor = const Color(0xFF16232E);
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      validator: (value) {
        final error = widget.validator?.call(value);
        setState(() {
          _hasError = error != null;
        });
        return error;
      },
      style: const TextStyle(
        color: Color(0xFF16232E),
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: labelColor, fontSize: 14),
        floatingLabelStyle: TextStyle(color: labelColor, fontSize: 14),
        prefixIcon:
            widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: labelColor)
                : null,
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF8C13A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
