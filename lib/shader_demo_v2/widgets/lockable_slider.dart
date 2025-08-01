import 'package:flutter/material.dart';
import 'labeled_slider.dart';
import '../controllers/animation_state_manager.dart';

/// A slider that can be individually locked/unlocked for animation
/// When unlocked and animation is enabled, the parameter will be animated
/// When locked, the parameter stays at the slider position regardless of animation
class LockableSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final Function(double) onChanged;
  final Color activeColor;

  // Parameter identification for lock state management
  final String parameterId;
  final bool animationEnabled;
  final double defaultValue;

  const LockableSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
    required this.activeColor,
    required this.parameterId,
    required this.animationEnabled,
    this.defaultValue = 0.0,
  }) : super(key: key);

  @override
  State<LockableSlider> createState() => _LockableSliderState();
}

class _LockableSliderState extends State<LockableSlider> {
  late final AnimationStateManager _animationManager;

  @override
  void initState() {
    super.initState();
    _animationManager = AnimationStateManager();
  }

  /// Format animated value for display using the same format as the original displayValue
  String _formatAnimatedValue(double animatedValue) {
    // Try to match the format of the original displayValue
    if (widget.displayValue.contains('%')) {
      return '${(animatedValue * 100).round()}%';
    } else if (widget.displayValue.contains('°')) {
      return '${animatedValue.toInt()}°';
    } else if (widget.displayValue.contains('px')) {
      return '${animatedValue.round()}px';
    } else if (widget.displayValue.contains('x')) {
      return '${animatedValue.toStringAsFixed(1)}x';
    } else if (widget.displayValue.contains('.') &&
        widget.displayValue.length > 4) {
      // High precision (3 decimal places)
      return animatedValue.toStringAsFixed(3);
    } else if (widget.displayValue.contains('.')) {
      // Medium precision (1-2 decimal places)
      final decimalPlaces = widget.displayValue.split('.')[1].length;
      return animatedValue.toStringAsFixed(decimalPlaces);
    } else {
      // Integer or default formatting
      return animatedValue.toStringAsFixed(1);
    }
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

        // Determine what value and display to show
        final bool isAnimating =
            widget.animationEnabled &&
            !isLocked &&
            currentAnimatedValue != null;
        final double displayedValue = isAnimating
            ? currentAnimatedValue!
            : widget.value;
        final String displayedText = isAnimating
            ? _formatAnimatedValue(currentAnimatedValue!)
            : widget.displayValue;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.label, style: TextStyle(color: widget.activeColor)),
                const Spacer(),
                Text(
                  displayedText,
                  style: TextStyle(
                    color: isAnimating
                        ? widget.activeColor.withOpacity(0.9)
                        : widget.activeColor,
                    fontWeight: isAnimating
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
                // Reset button (always show)
                GestureDetector(
                  onTap: (widget.value != widget.defaultValue)
                      ? () => widget.onChanged(widget.defaultValue)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: (widget.value != widget.defaultValue)
                          ? widget.activeColor.withOpacity(0.1)
                          : widget.activeColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: (widget.value != widget.defaultValue)
                          ? widget.activeColor
                          : widget.activeColor.withOpacity(0.3),
                      size: 16,
                    ),
                  ),
                ),
                if (widget.animationEnabled) ...[
                  // Lock/unlock button - only show when animation is enabled
                  GestureDetector(
                    onTap: () {
                      // print(
                        'Lock button tapped for ${widget.parameterId}, current state: ${isLocked ? "locked" : "unlocked"}',
                      );
                      _animationManager.toggleParameterLock(widget.parameterId);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8), // Larger touch area
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
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            LabeledSlider(
              label: '', // Don't duplicate the label
              value: displayedValue.clamp(
                widget.min,
                widget.max,
              ), // Ensure animated values stay in bounds
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              displayValue: '', // Don't duplicate the display value
              onChanged: widget
                  .onChanged, // Always allow changes - user can drag even when animating
              activeColor: isAnimating
                  ? widget.activeColor.withOpacity(0.6) // Dimmed when animating
                  : widget.activeColor,
            ),
            if (widget.animationEnabled && !isLocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isAnimating
                      ? 'Animated (lock to fix value)'
                      : 'Ready to animate (currently unlocked)',
                  style: TextStyle(
                    color: widget.activeColor.withOpacity(0.7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (widget.animationEnabled && isLocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Manual control (unlock to animate)',
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
}
