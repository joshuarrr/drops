import 'package:flutter/material.dart';

import '../controllers/animation_state_manager.dart';
import '../models/parameter_range.dart';

class RangeLockableSlider extends StatefulWidget {
  final String label;
  final ParameterRange range;
  final double min;
  final double max;
  final int? divisions;
  final Color activeColor;
  final String Function(double value) formatValue;
  final ParameterRange defaults;
  final String parameterId;
  final bool animationEnabled;
  final ValueChanged<ParameterRange> onRangeChanged;

  const RangeLockableSlider({
    super.key,
    required this.label,
    required this.range,
    required this.min,
    required this.max,
    required this.divisions,
    required this.activeColor,
    required this.formatValue,
    required this.defaults,
    required this.parameterId,
    required this.animationEnabled,
    required this.onRangeChanged,
  });

  @override
  State<RangeLockableSlider> createState() => _RangeLockableSliderState();
}

class _RangeLockableSliderState extends State<RangeLockableSlider> {
  late final AnimationStateManager _animationManager;

  @override
  void initState() {
    super.initState();
    _animationManager = AnimationStateManager();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _animationManager,
      builder: (context, _) {
        final isLocked = _animationManager.isParameterLocked(
          widget.parameterId,
        );
        final currentAnimatedValue = _animationManager.getCurrentAnimatedValue(
          widget.parameterId,
        );
        final bool isAnimating =
            widget.animationEnabled &&
            !isLocked &&
            currentAnimatedValue != null;

        final ParameterRange range = widget.range;
        final bool revealMinHandle =
            !isLocked &&
            (widget.animationEnabled || range.userMin > widget.min);
        final String displayValue =
            '${widget.formatValue(range.userMin)}–${widget.formatValue(range.userMax)}';
        final bool canReset =
            range.userMin != widget.defaults.userMin ||
            range.userMax != widget.defaults.userMax;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(color: widget.activeColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: isAnimating
                        ? widget.activeColor.withOpacity(0.9)
                        : widget.activeColor,
                    fontWeight: isAnimating
                        ? FontWeight.w500
                        : FontWeight.normal,
                    fontSize: 12, // Reduced font size
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: canReset ? _handleReset : null,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: canReset
                          ? widget.activeColor.withOpacity(0.1)
                          : widget.activeColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: canReset
                          ? widget.activeColor
                          : widget.activeColor.withOpacity(0.3),
                      size: 16,
                    ),
                  ),
                ),
                if (widget.animationEnabled)
                  GestureDetector(
                    onTap: () {
                      _animationManager.toggleParameterLock(widget.parameterId);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(
                        4,
                      ), // Same padding as reset button
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? widget.activeColor.withOpacity(0.15)
                            : widget.activeColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: widget.activeColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : Icons.lock_open,
                        color: isLocked
                            ? widget.activeColor
                            : widget.activeColor.withOpacity(0.7),
                        size: 16, // Same size as reset button
                      ),
                    ),
                  ),
              ],
            ),
            _SliderTrack(
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              activeColor: widget.activeColor,
              range: range,
              showRangeHandles: revealMinHandle,
              isAnimating: isAnimating,
              animatedValue: isAnimating ? currentAnimatedValue : null,
              onRangeChanged: (RangeValues values) {
                final updated = range.copy()
                  ..setUserMin(values.start)
                  ..setUserMax(values.end)
                  ..setCurrent(values.end);
                widget.onRangeChanged(updated);
              },
              onSingleChanged: (double value) {
                final updated = range.copy()
                  ..setUserMax(value)
                  ..setCurrent(value);
                widget.onRangeChanged(updated);
              },
            ),
            if (widget.animationEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isLocked
                      ? 'Manual control (unlock to animate)'
                      : (isAnimating
                            ? 'Animated (handles reflect your min/max)'
                            : 'Ready to animate once unlocked'),
                  style: TextStyle(
                    color: widget.activeColor.withOpacity(0.7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleReset() {
    final reset = widget.defaults.copy()..setCurrent(widget.defaults.userMax);
    widget.onRangeChanged(reset);
  }
}

class _SliderTrack extends StatelessWidget {
  final double min;
  final double max;
  final int? divisions;
  final Color activeColor;
  final ParameterRange range;
  final bool showRangeHandles;
  final bool isAnimating;
  final double? animatedValue;
  final ValueChanged<RangeValues> onRangeChanged;
  final ValueChanged<double> onSingleChanged;

  const _SliderTrack({
    required this.min,
    required this.max,
    required this.divisions,
    required this.activeColor,
    required this.range,
    required this.showRangeHandles,
    required this.isAnimating,
    required this.animatedValue,
    required this.onRangeChanged,
    required this.onSingleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: activeColor,
      inactiveTrackColor: activeColor.withOpacity(0.3),
      thumbColor: activeColor,
    );

    Widget slider;
    if (showRangeHandles) {
      slider = SliderTheme(
        data: sliderTheme,
        child: RangeSlider(
          values: RangeValues(range.userMin, range.userMax),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (values) {
            onRangeChanged(values);
          },
        ),
      );
    } else {
      slider = SliderTheme(
        data: sliderTheme,
        child: Slider(
          value: range.userMax,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (value) {
            onSingleChanged(value);
          },
        ),
      );
    }

    return Stack(
      children: [
        slider,
        if (animatedValue != null)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sliderWidth = constraints.maxWidth;
                const thumbRadius = 12.0;
                final trackWidth = sliderWidth - (thumbRadius * 2);
                final trackStart = thumbRadius;
                final normalizedPosition =
                    ((animatedValue! - min) / (max - min)).clamp(0.0, 1.0);
                final markerLeft =
                    trackStart + (normalizedPosition * trackWidth);

                return Stack(
                  children: [
                    Positioned(
                      left: markerLeft - 1,
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
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
