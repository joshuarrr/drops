import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../services/preset_service.dart';

class AspectPanelHeader extends StatelessWidget {
  final ShaderAspect aspect;
  final Function(Map<String, dynamic>) onPresetSelected;
  final VoidCallback onReset;
  final Function(ShaderAspect, String) onSavePreset;
  final Color sliderColor;
  final Future<Map<String, dynamic>> Function(ShaderAspect) loadPresets;
  final Future<bool> Function(ShaderAspect, String) deletePreset;
  final VoidCallback refreshPresets;
  final int refreshCounter;

  const AspectPanelHeader({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row with title and menu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${aspect.label} Settings',
              style: TextStyle(
                color: sliderColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: sliderColor, size: 20),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'save_preset',
                  child: Row(
                    children: [
                      Icon(Icons.save, color: sliderColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Save preset', style: TextStyle(color: sliderColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.restore, color: sliderColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Reset', style: TextStyle(color: sliderColor)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'reset') {
                  onReset();
                } else if (value == 'save_preset') {
                  // Generate automatic name first, then show dialog
                  final autoName =
                      await PresetService.generateAutomaticPresetName();
                  final TextEditingController nameController =
                      TextEditingController(text: autoName);

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Save Preset',
                        style: TextStyle(color: sliderColor),
                      ),
                      content: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter preset name',
                          hintStyle: TextStyle(
                            color: sliderColor.withOpacity(0.6),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: sliderColor.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: sliderColor),
                          ),
                        ),
                        style: TextStyle(color: sliderColor),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: sliderColor),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        FilledButton(
                          child: const Text('Save'),
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              onSavePreset(aspect, nameController.text);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                      backgroundColor: sliderColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
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
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Delete Preset',
                                  style: TextStyle(color: sliderColor),
                                ),
                                content: Text(
                                  'Are you sure you want to delete the preset "${entry.key}"?',
                                  style: TextStyle(color: sliderColor),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: sliderColor),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () async {
                                      await deletePreset(aspect, entry.key);
                                      refreshPresets();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                                backgroundColor: sliderColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
