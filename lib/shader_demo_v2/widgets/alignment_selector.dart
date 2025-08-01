import 'package:flutter/material.dart';

class AlignmentSelector extends StatelessWidget {
  final String label;
  final int currentValue;
  final ValueChanged<int> onChanged;
  final Color sliderColor;
  final List<IconData> icons;
  final List<String> tooltips;

  const AlignmentSelector({
    super.key,
    required this.label,
    required this.currentValue,
    required this.onChanged,
    required this.sliderColor,
    required this.icons,
    required this.tooltips,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: sliderColor, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            icons.length,
            (index) => Tooltip(
              message: tooltips[index],
              child: InkWell(
                onTap: () => onChanged(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentValue == index
                        ? sliderColor.withOpacity(0.3)
                        : sliderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Icon(icons[index], color: sliderColor, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
