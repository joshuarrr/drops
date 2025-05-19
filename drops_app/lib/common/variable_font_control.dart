import 'package:flutter/material.dart';
import '../theme/custom_fonts.dart';

/// A control widget for variable fonts that provides sliders for each available axis.
class VariableFontControl extends StatefulWidget {
  const VariableFontControl({
    Key? key,
    required this.fontFamily,
    required this.onAxisValuesChanged,
    this.initialAxisValues,
    this.textColor,
  }) : super(key: key);

  /// The font family name of the variable font
  final String fontFamily;

  /// Called when any axis value changes
  final Function(Map<String, double>) onAxisValuesChanged;

  /// Initial values for each axis (optional)
  final Map<String, double>? initialAxisValues;

  /// Text color for labels
  final Color? textColor;

  @override
  State<VariableFontControl> createState() => _VariableFontControlState();
}

class _VariableFontControlState extends State<VariableFontControl> {
  late Map<String, double> _axisValues;
  late List<String> _availableAxes;
  late Map<String, Map<String, dynamic>> _axisInfo;

  // Default axes info to fall back on if font-specific info is not available
  final Map<String, Map<String, dynamic>> _defaultAxisInfo = {
    'wght': {'name': 'Weight', 'min': 100.0, 'max': 1000.0, 'default': 400.0},
    'wdth': {'name': 'Width', 'min': 1.0, 'max': 1000.0, 'default': 100.0},
    'CONT': {'name': 'Contrast', 'min': 1.0, 'max': 1000.0, 'default': 100.0},
    'slnt': {'name': 'Slant', 'min': -10.0, 'max': 0.0, 'default': 0.0},
    'opsz': {'name': 'Optical Size', 'min': 8.0, 'max': 144.0, 'default': 14.0},
  };

  @override
  void initState() {
    super.initState();
    _updateFontInfo();
  }

  @override
  void didUpdateWidget(VariableFontControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If font family changed, update available axes
    if (oldWidget.fontFamily != widget.fontFamily) {
      _updateFontInfo();

      // Schedule callback after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAxisValuesChanged(_axisValues);
      });
    }
    // Update axis values if they changed from outside
    else if (widget.initialAxisValues != null &&
        widget.initialAxisValues != oldWidget.initialAxisValues) {
      // Only update changed values, keeping current slider positions for others
      bool hasChanges = false;
      for (final axis in _availableAxes) {
        if (widget.initialAxisValues!.containsKey(axis) &&
            (_axisValues[axis] == null ||
                _axisValues[axis] != widget.initialAxisValues![axis])) {
          final value = widget.initialAxisValues![axis];
          if (value != null) {
            _axisValues[axis] = value;
            hasChanges = true;
          }
        }
      }

      // If there were changes, notify parent after the build phase
      if (hasChanges) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onAxisValuesChanged(_axisValues);
        });
      }
    }
  }

  void _updateFontInfo() {
    // Get the axis info for this specific font
    _axisInfo = _getAxisInfoForFont();
    // Get available axes for this font
    _availableAxes = _getAvailableAxes();
    // Initialize axis values based on available axes
    _axisValues = _initializeAxisValues();
  }

  Map<String, Map<String, dynamic>> _getAxisInfoForFont() {
    // Get the axis info specific to this font, if available
    if (widget.fontFamily == CustomFonts.kyivTypeSansFamily) {
      return KyivTypeSansFont.availableAxesInfo;
    } else if (widget.fontFamily == CustomFonts.kyivTypeSerifFamily) {
      return KyivTypeSerifFont.availableAxesInfo;
    } else if (widget.fontFamily == CustomFonts.kyivTypeTitlingFamily) {
      return KyivTypeTitlingFont.availableAxesInfo;
    }

    // If font-specific info is not available, return default info
    return _defaultAxisInfo;
  }

  Map<String, double> _initializeAxisValues() {
    Map<String, double> values = {};

    // Use initial values if provided, otherwise use defaults from axis info
    for (final axis in _availableAxes) {
      values[axis] =
          widget.initialAxisValues?[axis] ??
          _axisInfo[axis]?['default'] ??
          _defaultAxisInfo[axis]?['default'] ??
          400.0;
    }

    return values;
  }

  List<String> _getAvailableAxes() {
    // Determine which axes are available for this font
    if (widget.fontFamily == CustomFonts.kyivTypeSansFamily) {
      return KyivTypeSansFont.availableAxes;
    } else if (widget.fontFamily == CustomFonts.kyivTypeSerifFamily) {
      return KyivTypeSerifFont.availableAxes;
    } else if (widget.fontFamily == CustomFonts.kyivTypeTitlingFamily) {
      return KyivTypeTitlingFont.availableAxes;
    }

    // Default to weight axis if font is not recognized
    return ['wght'];
  }

  String _getAxisDisplayName(String axis) {
    return _axisInfo[axis]?['name'] ??
        _defaultAxisInfo[axis]?['name'] ??
        axis.toUpperCase();
  }

  double _getAxisMinValue(String axis) {
    return _axisInfo[axis]?['min'] ?? _defaultAxisInfo[axis]?['min'] ?? 100.0;
  }

  double _getAxisMaxValue(String axis) {
    return _axisInfo[axis]?['max'] ?? _defaultAxisInfo[axis]?['max'] ?? 900.0;
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        widget.textColor ?? Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variable Font Axes',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ..._availableAxes.map((axis) => _buildAxisSlider(axis, textColor)),
      ],
    );
  }

  Widget _buildAxisSlider(String axis, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getAxisDisplayName(axis),
              style: TextStyle(color: textColor, fontSize: 14),
            ),
            Text(
              _axisValues[axis]!.toInt().toString(),
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ],
        ),
        Slider(
          value: _axisValues[axis]!,
          min: _getAxisMinValue(axis),
          max: _getAxisMaxValue(axis),
          divisions:
              (_getAxisMaxValue(axis).toInt() - _getAxisMinValue(axis).toInt()),
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) {
            setState(() {
              _axisValues[axis] = value;
            });

            // Notify parent after the current build phase completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onAxisValuesChanged(_axisValues);
            });
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
