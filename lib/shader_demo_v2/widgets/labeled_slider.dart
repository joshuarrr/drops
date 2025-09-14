import 'package:flutter/material.dart';

class LabeledSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String displayValue;
  final Function(double) onChanged;
  final Color activeColor;

  // Optional parameter to show a marker at a specific position
  // This is used to show the user-set position during animation
  final double? markerPosition;

  const LabeledSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
    required this.activeColor,
    this.markerPosition,
  }) : super(key: key);

  @override
  State<LabeledSlider> createState() => _LabeledSliderState();
}

class _LabeledSliderState extends State<LabeledSlider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: TextStyle(color: widget.activeColor)),
            const Spacer(),
            Text(
              widget.displayValue,
              style: TextStyle(color: widget.activeColor),
            ),
          ],
        ),
        Stack(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: widget.activeColor,
                inactiveTrackColor: widget.activeColor.withOpacity(0.3),
                thumbColor: widget.activeColor,
                // Make tick marks visible or invisible based on division settings
                tickMarkShape: widget.divisions != null
                    ? SliderTickMarkShape.noTickMark
                    : null,
              ),
              child: Slider(
                value: widget.value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                activeColor: widget.activeColor,
                onChanged: (value) {
                  widget.onChanged(value);
                },
                onChangeStart: (value) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _isDragging = false;
                  });
                },
              ),
            ),

            // Show a marker at the user-set position during animation
            if (widget.markerPosition != null &&
                widget.markerPosition != widget.value)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate the marker position within the actual slider bounds
                    // Account for slider thumb radius (typically 12px) on both sides
                    final sliderWidth = constraints.maxWidth;
                    final thumbRadius = 12.0;
                    final trackWidth = sliderWidth - (thumbRadius * 2);
                    final trackStart = thumbRadius;

                    final normalizedPosition =
                        (widget.markerPosition! - widget.min) /
                        (widget.max - widget.min);
                    final markerLeft =
                        trackStart + (normalizedPosition * trackWidth);

                    return Stack(
                      children: [
                        Positioned(
                          left: markerLeft - 1, // Center the 2px wide marker
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 2,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.6),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Show marker value only when dragging
                        if (_isDragging)
                          Positioned(
                            left:
                                markerLeft +
                                8, // Position to the right of marker
                            top: 20, // Position below the slider
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                widget.markerPosition!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
