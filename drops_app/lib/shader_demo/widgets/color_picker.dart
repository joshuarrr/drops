import 'package:flutter/material.dart';

class ColorPickerButton extends StatelessWidget {
  final Color color;
  final Function(Color) onColorChanged;

  const ColorPickerButton({
    Key? key,
    required this.color,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showColorPicker(context);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPickerGrid(
              currentColor: color,
              onColorSelected: (selectedColor) {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ColorPickerGrid extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ColorPickerGrid({
    Key? key,
    required this.currentColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Predefined color options
    final List<List<Color>> colorOptions = [
      [Colors.black, Colors.white, Colors.grey, Colors.brown],
      [Colors.red, Colors.pink, Colors.purple, Colors.deepPurple],
      [Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan],
      [Colors.teal, Colors.green, Colors.lightGreen, Colors.lime],
      [Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var colorRow in colorOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var color in colorRow)
                  GestureDetector(
                    onTap: () => onColorSelected(color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color == currentColor
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
