import 'package:flutter/material.dart';
import '../models/shader_effect.dart';

/// Widget that displays a horizontal list of saved presets for a specific shader aspect
class PresetsBar extends StatefulWidget {
  final ShaderAspect aspect;
  final Function(Map<String, dynamic>) onPresetSelected;
  final Color sliderColor;
  final Future<Map<String, dynamic>> Function(ShaderAspect) loadPresets;
  final Future<bool> Function(ShaderAspect, String) deletePreset;
  final VoidCallback refreshPresets;
  final int refreshCounter;

  const PresetsBar({
    Key? key,
    required this.aspect,
    required this.onPresetSelected,
    required this.sliderColor,
    required this.loadPresets,
    required this.deletePreset,
    required this.refreshPresets,
    required this.refreshCounter,
  }) : super(key: key);

  @override
  State<PresetsBar> createState() => _PresetsBarState();
}

class _PresetsBarState extends State<PresetsBar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      // Add refresh counter to key to force rebuild
      key: ValueKey(
        'presets_${widget.aspect.toString()}_${widget.refreshCounter}',
      ),
      future: widget.loadPresets(widget.aspect),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final presets = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Text(
                    'Presets',
                    style: TextStyle(
                      color: widget.sliderColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: presets.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () => widget.onPresetSelected(entry.value),
                      onLongPress: () {
                        // Show delete confirmation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Delete Preset',
                              style: TextStyle(color: widget.sliderColor),
                            ),
                            content: Text(
                              'Are you sure you want to delete the preset "${entry.key}"?',
                              style: TextStyle(color: widget.sliderColor),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: widget.sliderColor),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  await widget.deletePreset(
                                    widget.aspect,
                                    entry.key,
                                  );
                                  // Force refresh
                                  widget.refreshPresets();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                            backgroundColor: widget.sliderColor.withOpacity(
                              0.1,
                            ),
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
                          color: widget.sliderColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.sliderColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: widget.sliderColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
