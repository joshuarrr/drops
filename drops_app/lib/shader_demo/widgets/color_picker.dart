import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:developer' as developer;

class ColorPicker extends StatefulWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;
  final Color textColor;
  final String label;

  const ColorPicker({
    Key? key,
    required this.currentColor,
    required this.onColorChanged,
    required this.textColor,
    required this.label,
  }) : super(key: key);

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _key = GlobalKey();
  final String _logTag = 'ColorPicker';

  // Custom log function that uses both dart:developer and debugPrint
  void _log(String message) {
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  void initState() {
    super.initState();
    _log('ColorPicker initialized for "${widget.label}" - DEBUG TEST');
    // Only log in debug mode, and be more selective about what we output
    assert(() {
      // Print only if we have no key, which might indicate a potential issue
      if (widget.key == null) {
        _log('ColorPicker for "${widget.label}" initialized without a key');
      }
      return true;
    }());
  }

  @override
  void dispose() {
    _log('ColorPicker for "${widget.label}" disposing');
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _log('Removing overlay for "${widget.label}"');
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _toggleExpanded() {
    _log('ColorPicker tapped: ${widget.label}');
    if (_isExpanded) {
      _removeOverlay();
      setState(() {
        _isExpanded = false;
        _log(
          'ColorPicker state changed: ${widget.label}, isExpanded: $_isExpanded',
        );
      });
    } else {
      setState(() {
        _isExpanded = true;
        _log(
          'ColorPicker state changed: ${widget.label}, isExpanded: $_isExpanded',
        );
      });
      // Wait for the build phase to complete before showing overlay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showColorOptions();
      });
    }
  }

  void _showColorOptions() {
    _removeOverlay(); // Remove existing overlay if any

    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    _log('Showing color options at position: ($position), size: ($size)');

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height + 5,
        width: 200,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: Colors.black.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildColorOptionsWidget(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _log('Overlay inserted for "${widget.label}"');
  }

  Widget _buildColorOptionsWidget() {
    // Pre-defined color options
    final List<Color> colorOptions = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
    ];

    _log('Building color options widget with ${colorOptions.length} colors');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...colorOptions.map((color) {
              final bool isSelected = color.value == widget.currentColor.value;
              return GestureDetector(
                onTap: () {
                  _log(
                    'Color selected: ${widget.label} - ${_colorToString(color)}',
                  );
                  widget.onColorChanged(color);
                  _removeOverlay();
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? widget.textColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
            // Custom color picker button
            GestureDetector(
              onTap: () {
                _log('Custom color picker tapped: ${widget.label}');
                _removeOverlay();
                setState(() {
                  _isExpanded = false;
                });
                _showCustomColorPicker(context);
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.green, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.textColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _colorToString(Color color) {
    return 'Color(0x${color.value.toRadixString(16).padLeft(8, '0')})';
  }

  @override
  Widget build(BuildContext context) {
    // Add build log
    _log(
      'Building ColorPicker: ${widget.label}, expanded: $_isExpanded, color: ${_colorToString(widget.currentColor)}',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Make the entire row clickable instead of just the small circle
        GestureDetector(
          key: _key,
          onTap: _toggleExpanded,
          child: Container(
            decoration: BoxDecoration(
              // Debug visualization - makes the clickable area visible
              border: Border.all(
                color: Colors.yellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.textColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomColorPicker(BuildContext context) {
    _log('Showing custom color picker dialog for: ${widget.label}');
    _log('Context is valid: ${context != null}');
    _log('MediaQuery can be accessed: ${MediaQuery.of(context) != null}');
    // Use StatefulBuilder to rebuild dialog contents when color changes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _log('Dialog builder called for: ${widget.label}');
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Custom Color',
                style: TextStyle(color: widget.textColor),
              ),
              content: SingleChildScrollView(
                child: CustomColorPickerContent(
                  initialColor: widget.currentColor,
                  onColorChanged: (color) {
                    // Update parent without closing dialog
                    widget.onColorChanged(color);
                    _log('Custom color updated: ${_colorToString(color)}');
                  },
                  textColor: widget.textColor,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Done',
                    style: TextStyle(color: widget.textColor),
                  ),
                  onPressed: () {
                    _log('Custom color picker closed');
                    Navigator.of(context).pop();
                  },
                ),
              ],
              backgroundColor: Colors.black.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomColorPickerContent extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;
  final Color textColor;

  const CustomColorPickerContent({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
    required this.textColor,
  }) : super(key: key);

  @override
  State<CustomColorPickerContent> createState() =>
      _CustomColorPickerContentState();
}

class _CustomColorPickerContentState extends State<CustomColorPickerContent> {
  late double _red;
  late double _green;
  late double _blue;
  late double _opacity;
  final String _logTag = 'CustomColorPicker';

  // Custom log function
  void _log(String message) {
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  void initState() {
    super.initState();
    _red = widget.initialColor.red.toDouble();
    _green = widget.initialColor.green.toDouble();
    _blue = widget.initialColor.blue.toDouble();
    _opacity = widget.initialColor.opacity;

    _log(
      'CustomColorPicker initialized with color: ${_colorToString(widget.initialColor)}',
    );
  }

  String _colorToString(Color color) {
    return 'Color(0x${color.value.toRadixString(16).padLeft(8, '0')})';
  }

  Color get _currentColor =>
      Color.fromRGBO(_red.toInt(), _green.toInt(), _blue.toInt(), _opacity);

  // Update color and notify parent but don't close dialog
  void _updateColor() {
    widget.onColorChanged(_currentColor);
    _log('Color updated to: ${_colorToString(_currentColor)}');
  }

  @override
  Widget build(BuildContext context) {
    _log(
      'Building custom color picker with current color: ${_colorToString(_currentColor)}',
    );

    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.textColor.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 16),

          // RGB Sliders
          _buildColorSlider(
            label: 'R',
            value: _red,
            color: Colors.red,
            max: 255,
            onChange: (value) {
              setState(() => _red = value);
              _log('Red value changed to: ${value.toInt()}');
              _updateColor();
            },
          ),
          _buildColorSlider(
            label: 'G',
            value: _green,
            color: Colors.green,
            max: 255,
            onChange: (value) {
              setState(() => _green = value);
              _log('Green value changed to: ${value.toInt()}');
              _updateColor();
            },
          ),
          _buildColorSlider(
            label: 'B',
            value: _blue,
            color: Colors.blue,
            max: 255,
            onChange: (value) {
              setState(() => _blue = value);
              _log('Blue value changed to: ${value.toInt()}');
              _updateColor();
            },
          ),
          _buildColorSlider(
            label: 'A',
            value: _opacity,
            color: Colors.white,
            max: 1.0,
            onChange: (value) {
              setState(() => _opacity = value);
              _log('Alpha value changed to: ${value.toStringAsFixed(2)}');
              _updateColor();
            },
          ),

          // Hex input
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text("Hex: ", style: TextStyle(color: widget.textColor)),
                Text(
                  "#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}",
                  style: TextStyle(
                    color: widget.textColor,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSlider({
    required String label,
    required double value,
    required Color color,
    required double max,
    required Function(double) onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              label,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: max > 1 ? 255 : 100,
              activeColor: color,
              inactiveColor: color.withOpacity(0.3),
              onChanged: onChange,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              max > 1 ? value.toInt().toString() : value.toStringAsFixed(2),
              style: TextStyle(color: widget.textColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
