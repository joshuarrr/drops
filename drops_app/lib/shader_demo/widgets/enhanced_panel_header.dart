import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import 'effect_options_menu.dart';

/// An enhanced version of AspectPanelHeader that includes the new options menu
/// with Apply to Image and Apply to Text checkboxes.
class EnhancedPanelHeader extends StatelessWidget {
  final ShaderAspect aspect;
  final Function(Map<String, dynamic>) onPresetSelected;
  final VoidCallback onReset;
  final Function(ShaderAspect, String) onSavePreset;
  final Color sliderColor;
  final Future<Map<String, dynamic>> Function(ShaderAspect) loadPresets;
  final Future<bool> Function(ShaderAspect, String) deletePreset;
  final VoidCallback refreshPresets;
  final int refreshCounter;

  // New parameters for apply to image/text
  final bool applyToImage;
  final bool applyToText;
  final Function(bool) onApplyToImageChanged;
  final Function(bool) onApplyToTextChanged;

  const EnhancedPanelHeader({
    Key? key,
    required this.aspect,
    required this.onPresetSelected,
    required this.onReset,
    required this.onSavePreset,
    required this.sliderColor,
    required this.loadPresets,
    required this.deletePreset,
    required this.refreshPresets,
    required this.refreshCounter,
    required this.applyToImage,
    required this.applyToText,
    required this.onApplyToImageChanged,
    required this.onApplyToTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row with title and menu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${aspect.label} Settings',
                style: TextStyle(
                  color: sliderColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              // Use the new options menu
              EffectOptionsMenu(
                aspect: aspect,
                textColor: sliderColor,
                onSavePreset: onSavePreset,
                onReset: onReset,
                applyToImage: applyToImage,
                applyToText: applyToText,
                onApplyToImageChanged: onApplyToImageChanged,
                onApplyToTextChanged: onApplyToTextChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Preset chips
        FutureBuilder<Map<String, dynamic>>(
          key: ValueKey('presets_${aspect.toString()}_$refreshCounter'),
          future: loadPresets(aspect),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final presets = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: presets.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () => onPresetSelected(entry.value),
                          onLongPress: () {
                            // Show delete confirmation
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Delete Preset'),
                                  content: Text(
                                    'Are you sure you want to delete the preset "${entry.key}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        final success = await deletePreset(
                                          aspect,
                                          entry.key,
                                        );
                                        if (success) {
                                          refreshPresets();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: sliderColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sliderColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: sliderColor,
                                fontSize: 12,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
