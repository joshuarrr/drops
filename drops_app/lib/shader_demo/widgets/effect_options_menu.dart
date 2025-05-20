import 'package:flutter/material.dart';
import '../models/shader_effect.dart';

/// A reusable options menu for shader effect panels that provides
/// consistent UI across all effect types. This includes preset management
/// options and targeting options (apply to image/text).
class EffectOptionsMenu extends StatelessWidget {
  /// The effect aspect this menu is for
  final ShaderAspect aspect;

  /// Color for text and icons in the menu
  final Color textColor;

  /// Callback when a preset should be saved
  final Function(ShaderAspect, String) onSavePreset;

  /// Callback when the effect should be reset
  final VoidCallback onReset;

  /// Whether this effect is applied to images
  final bool applyToImage;

  /// Whether this effect is applied to text
  final bool applyToText;

  /// Callback when the apply to image setting changes
  final Function(bool) onApplyToImageChanged;

  /// Callback when the apply to text setting changes
  final Function(bool) onApplyToTextChanged;

  const EffectOptionsMenu({
    Key? key,
    required this.aspect,
    required this.textColor,
    required this.onSavePreset,
    required this.onReset,
    required this.applyToImage,
    required this.applyToText,
    required this.onApplyToImageChanged,
    required this.onApplyToTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which targeting options to show
    final bool showApplyToImage = aspect != ShaderAspect.image;
    final bool showApplyToText =
        aspect != ShaderAspect.text &&
        aspect != ShaderAspect.textfx &&
        aspect != ShaderAspect.image; // Also hide for image aspect
    final bool showDivider = showApplyToImage || showApplyToText;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: textColor, size: 20),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // Add Apply to Image option if needed
        if (showApplyToImage) {
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  Text('Apply to Image', style: TextStyle(color: textColor)),
                  const Spacer(),
                  Checkbox(
                    value: applyToImage,
                    activeColor: textColor,
                    onChanged: (value) {
                      if (value != null) {
                        onApplyToImageChanged(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }

        // Add Apply to Text option if needed
        if (showApplyToText) {
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  Text('Apply to Text', style: TextStyle(color: textColor)),
                  const Spacer(),
                  Checkbox(
                    value: applyToText,
                    activeColor: textColor,
                    onChanged: (value) {
                      if (value != null) {
                        onApplyToTextChanged(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }

        // Add divider if any targeting options are shown
        if (showDivider) {
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              height: 1,
              padding: EdgeInsets.zero,
              child: Divider(color: textColor.withOpacity(0.3)),
            ),
          );
        }

        // Always add preset and reset options
        items.add(
          PopupMenuItem<String>(
            value: 'save_preset',
            child: Row(
              children: [
                Icon(Icons.save, color: textColor, size: 18),
                const SizedBox(width: 8),
                Text('Save preset', style: TextStyle(color: textColor)),
              ],
            ),
          ),
        );

        items.add(
          PopupMenuItem<String>(
            value: 'reset',
            child: Row(
              children: [
                Icon(Icons.restore, color: textColor, size: 18),
                const SizedBox(width: 8),
                Text('Reset', style: TextStyle(color: textColor)),
              ],
            ),
          ),
        );

        return items;
      },
      onSelected: (value) {
        switch (value) {
          case 'save_preset':
            // Show dialog to input preset name
            showDialog(
              context: context,
              builder: (context) => _buildSavePresetDialog(context),
            );
            break;
          case 'reset':
            onReset();
            break;
        }
      },
    );
  }

  Widget _buildSavePresetDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: Text('Save ${aspect.label} Preset'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Preset Name',
          hintText: 'Enter a name for this preset',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              onSavePreset(aspect, name);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
