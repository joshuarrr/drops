import 'package:flutter/material.dart';
import '../models/shader_effect.dart';

class TextInputField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Use TextEditingController to properly update field when reset occurs
    final controller = TextEditingController(text: value);

    if (enableLogging) {
      print('DEBUG: TextField initial value: "$value"');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: textColor),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            keyboardType: multiline
                ? TextInputType.multiline
                : TextInputType.text,
            maxLines: multiline ? maxLines : 1,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: multiline ? 10 : 6,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (txt) {
              if (enableLogging) {
                print('DEBUG: onChanged received text: "$txt"');
              }

              onChanged(txt);

              // Enable text effect if needed
              if (isTextEnabled != null &&
                  !isTextEnabled!() &&
                  enableText != null) {
                enableText!();
              }
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
