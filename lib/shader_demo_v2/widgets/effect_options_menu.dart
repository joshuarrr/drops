import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/presets_manager.dart';
import '../services/preset_service.dart';

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

  /// Whether this effect is applied to background (for cymatics)
  final bool applyToBackground;

  /// Callback when the apply to image setting changes
  final Function(bool) onApplyToImageChanged;

  /// Callback when the apply to text setting changes
  final Function(bool) onApplyToTextChanged;

  /// Callback when the apply to background setting changes
  final Function(bool) onApplyToBackgroundChanged;

  // Default callback for optional function parameters
  static void _defaultBoolCallback(bool value) {}

  const EffectOptionsMenu({
    Key? key,
    required this.aspect,
    required this.textColor,
    required this.onSavePreset,
    required this.onReset,
    required this.applyToImage,
    required this.applyToText,
    this.applyToBackground = false,
    required this.onApplyToImageChanged,
    required this.onApplyToTextChanged,
    this.onApplyToBackgroundChanged = _defaultBoolCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which targeting options to show
    final bool showApplyToImage =
        aspect != ShaderAspect.image &&
        aspect != ShaderAspect.textfx &&
        aspect != ShaderAspect.background &&
        aspect != ShaderAspect.text;
    final bool showApplyToText =
        aspect != ShaderAspect.text &&
        aspect != ShaderAspect.image &&
        aspect != ShaderAspect.background &&
        aspect != ShaderAspect.textfx;
    final bool showApplyToBackground = aspect == ShaderAspect.cymatics;
    final bool showDivider =
        showApplyToImage || showApplyToText || showApplyToBackground;

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
              enabled: false, // Keep disabled to prevent menu auto-closing
              height: 40,
              padding:
                  EdgeInsets.zero, // Remove padding for the gesture detector
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Toggle the value when tapped
                    onApplyToImageChanged(!applyToImage);
                    debugPrint(
                      "[EffectOptionsMenu] Apply to Image toggled to: ${!applyToImage}",
                    );
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Apply to Image',
                          style: TextStyle(color: textColor),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: applyToImage,
                          activeColor: textColor,
                          onChanged:
                              null, // Disable checkbox interaction, use inkwell instead
                        ),
                      ],
                    ),
                  ),
                ),
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
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onApplyToTextChanged(!applyToText);
                    debugPrint(
                      "[EffectOptionsMenu] Apply to Text toggled to: ${!applyToText}",
                    );
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Apply to Text',
                          style: TextStyle(color: textColor),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: applyToText,
                          activeColor: textColor,
                          onChanged: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Add Apply to Background option for cymatics
        if (showApplyToBackground) {
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              height: 40,
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onApplyToBackgroundChanged(!applyToBackground);
                    debugPrint(
                      "[EffectOptionsMenu] Apply to Background toggled to: ${!applyToBackground}",
                    );
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Apply to Background',
                          style: TextStyle(color: textColor),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: applyToBackground,
                          activeColor: textColor,
                          onChanged: null,
                        ),
                      ],
                    ),
                  ),
                ),
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
            // Generate automatic name first, then show dialog
            _showSavePresetDialog(context);
            break;
          case 'reset':
            onReset();
            break;
        }
      },
    );
  }

  Future<void> _showSavePresetDialog(BuildContext context) async {
    // Generate automatic name first
    final autoName = await PresetService.generateAutomaticPresetName();
    final TextEditingController controller = TextEditingController(
      text: autoName,
    );
    String? selectedPreset;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save ${aspect.label} Preset'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: PresetsManager.getPresetsForAspect(aspect),
          builder: (context, snapshot) {
            final presets = snapshot.data ?? {};
            final presetNames = presets.keys.toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Preset Name',
                    hintText: 'Enter a name for this preset',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                if (presetNames.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Or update existing preset:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select a preset to update'),
                    value: selectedPreset,
                    items: presetNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedPreset = value;
                      if (value != null) {
                        controller.text = value;
                      }
                    },
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                onSavePreset(aspect, name);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: PresetsManager.getPresetsForAspect(aspect),
            builder: (context, snapshot) {
              final presets = snapshot.data ?? {};
              if (snapshot.hasData &&
                  controller.text.isNotEmpty &&
                  presets.containsKey(controller.text)) {
                return FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      onSavePreset(aspect, name);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Update'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
