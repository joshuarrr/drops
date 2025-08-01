import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final Color textColor;
  final bool enableLogging;
  final bool Function()? isTextEnabled;
  final Function()? enableText;
  final bool multiline;
  final int maxLines;

  const TextInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.textColor,
    this.enableLogging = false,
    this.isTextEnabled,
    this.enableText,
    this.multiline = false,
    this.maxLines = 5,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastValue = '';

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();

    if (widget.enableLogging) {}
  }

  @override
  void didUpdateWidget(TextInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update the controller if the external value has actually changed
    // and it's different from what we currently have
    if (widget.value != _lastValue && widget.value != _controller.text) {
      if (widget.enableLogging) {
        print(
          'DEBUG: External value changed from "$_lastValue" to "${widget.value}"',
        );
      }

      _lastValue = widget.value;

      // Only update if the field is not currently focused (to avoid interrupting user input)
      if (!_focusNode.hasFocus) {
        _controller.text = widget.value;
        _controller.selection = TextSelection.collapsed(
          offset: widget.value.length,
        );
      } else {
        // If focused, be more careful about cursor position
        final int cursorPos = _controller.selection.baseOffset;
        _controller.text = widget.value;

        // Try to restore cursor position, but clamp it to valid range
        if (cursorPos >= 0 && cursorPos <= widget.value.length) {
          _controller.selection = TextSelection.collapsed(offset: cursorPos);
        } else {
          _controller.selection = TextSelection.collapsed(
            offset: widget.value.length,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(color: widget.textColor, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: widget.textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            style: TextStyle(color: widget.textColor),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            keyboardType: widget.multiline
                ? TextInputType.multiline
                : TextInputType.text,
            maxLines: widget.multiline ? widget.maxLines : 1,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: widget.multiline ? 10 : 6,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (txt) {
              if (widget.enableLogging) {}

              _lastValue = txt;
              widget.onChanged(txt);

              // Enable text effect if needed
              if (widget.isTextEnabled != null &&
                  !widget.isTextEnabled!() &&
                  widget.enableText != null) {
                widget.enableText!();
              }
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
