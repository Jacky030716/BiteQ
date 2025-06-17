import 'package:flutter/material.dart';

class FoodTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? suffixText;

  const FoodTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixText,
  });

  @override
  State<FoodTextField> createState() => _FoodTextFieldState();
}

class _FoodTextFieldState extends State<FoodTextField> {
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _onTextChange() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (_focusNode.hasFocus || _hasText)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      _focusNode.hasFocus
                          ? Colors.blueAccent.shade700
                          : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          // Text Field Container
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText:
                    (_focusNode.hasFocus || !_hasText) ? widget.hintText : null,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon:
                    widget.prefixIcon != null
                        ? Container(
                          margin: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            widget.prefixIcon,
                            color:
                                _focusNode.hasFocus
                                    ? Colors.blueAccent
                                    : Colors.grey.shade500,
                            size: 20,
                          ),
                        )
                        : null,
                suffixText: widget.suffixText,
                suffixStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 8 : 20,
                  vertical: 14,
                ),
                filled: true,
                fillColor:
                    _focusNode.hasFocus
                        ? Colors.blueAccent.withOpacity(0.03)
                        : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        _hasText
                            ? Colors.blueAccent.shade200
                            : Colors.grey.shade300,
                    width: _hasText ? 1.5 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
