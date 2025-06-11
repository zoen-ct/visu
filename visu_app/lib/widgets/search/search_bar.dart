import 'dart:async';
import 'package:flutter/material.dart';
/// A widget to display a reusable search bar
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.onSearch,
    this.onClear,
    this.hintText = 'Rechercher...',
    this.debounceTime = const Duration(milliseconds: 500),
    this.backgroundColor = const Color(0xFF1D2F3E),
    this.textColor = const Color(0xFFF4F6F8),
    this.hintColor = Colors.grey,
    this.iconColor = const Color(0xFFF8C13A),
    this.autofocus = false,
    this.initialValue = '',
  });

  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String hintText;
  final Duration debounceTime;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;
  final Color iconColor;
  final bool autofocus;
  final String initialValue;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.initialValue.isNotEmpty) {
      _onSearchChanged(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceTime, () {
      widget.onSearch(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: widget.hintColor),
          prefixIcon: Icon(Icons.search, color: widget.iconColor),
          suffixIcon:
              _controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: widget.iconColor),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}
