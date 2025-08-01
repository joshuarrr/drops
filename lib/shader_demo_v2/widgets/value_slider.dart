import 'package:flutter/material.dart';
import 'dart:async';

/// A labelled slider with a numeric % read-out and a small reset button.
///
/// Originally implemented inline in `effect_controls.dart` as `buildSlider`,
/// this widget makes the control reusable and keeps `effect_controls.dart`
/// shorter.
class ValueSlider extends StatefulWidget {
  const ValueSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.sliderColor,
    this.defaultValue = 0.0,
    this.debounceMillis = 200,
    this.min = -1.0,
    this.max = 1.0,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color sliderColor;
  final double defaultValue;
  final int debounceMillis;
  final double min;
  final double max;

  @override
  State<ValueSlider> createState() => _ValueSliderState();
}

class _ValueSliderState extends State<ValueSlider> {
  Timer? _debounceTimer;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(ValueSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleSliderChange(double value) {
    setState(() {
      _currentValue = value;
    });

    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceMillis), () {
      widget.onChanged(value);
    });
  }

  void _resetToDefault() {
    setState(() {
      _currentValue = widget.defaultValue;
    });

    // Cancel existing timer and immediately apply the reset
    _debounceTimer?.cancel();
    widget.onChanged(widget.defaultValue);
  }

  @override
  Widget build(BuildContext context) {
    final bool valueChanged = _currentValue != widget.defaultValue;
    final bool isCurrentImageDark = widget.sliderColor == Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: isCurrentImageDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: widget.sliderColor,
                  inactiveTrackColor: widget.sliderColor.withOpacity(0.3),
                  thumbColor: widget.sliderColor,
                  overlayColor: widget.sliderColor.withOpacity(0.1),
                ),
                child: Slider(
                  value: _currentValue,
                  min: widget.min,
                  max: widget.max,
                  onChanged: _handleSliderChange,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${(_currentValue * 100).round()}%',
                style: TextStyle(
                  color: isCurrentImageDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: valueChanged ? () => _resetToDefault() : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: valueChanged
                      ? widget.sliderColor.withOpacity(0.1)
                      : widget.sliderColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.refresh,
                  color: valueChanged
                      ? widget.sliderColor
                      : widget.sliderColor.withOpacity(0.3),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
