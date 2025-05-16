import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

  @override
  void initState() {
    super.initState();
    print('ColorPicker initialized: ${widget.label} with key: ${widget.key}');
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleExpanded() {
    print('ColorPicker tapped: ${widget.label}');
    if (_isExpanded) {
      _removeOverlay();
      setState(() {
        _isExpanded = false;
        print(
          'ColorPicker state changed: ${widget.label}, isExpanded: $_isExpanded',
        );
      });
    } else {
      setState(() {
        _isExpanded = true;
        print(
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
                  print(
                    'Color selected: ${widget.label} - ${color.toString()}',
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
                print('Custom color picker tapped: ${widget.label}');
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

  @override
  Widget build(BuildContext context) {
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
    print('Showing custom color picker dialog for: ${widget.label}');
    print('Context is valid: ${context != null}');
    print('MediaQuery can be accessed: ${MediaQuery.of(context) != null}');
    // Use StatefulBuilder to rebuild dialog contents when color changes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print('Dialog builder called for: ${widget.label}');
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

  @override
  void initState() {
    super.initState();
    _red = widget.initialColor.red.toDouble();
    _green = widget.initialColor.green.toDouble();
    _blue = widget.initialColor.blue.toDouble();
    _opacity = widget.initialColor.opacity;
  }

  Color get _currentColor =>
      Color.fromRGBO(_red.toInt(), _green.toInt(), _blue.toInt(), _opacity);

  // Update color and notify parent but don't close dialog
  void _updateColor() {
    widget.onColorChanged(_currentColor);
  }

  @override
  Widget build(BuildContext context) {
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
