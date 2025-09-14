import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../services/preset_refresh_service.dart';
import 'effect_options_menu.dart';

/// An enhanced version of AspectPanelHeader that includes the new options menu
/// with Apply to Image and Apply to Text checkboxes.
class EnhancedPanelHeader extends StatefulWidget {
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
  final bool applyToBackground;
  final Function(bool) onApplyToImageChanged;
  final Function(bool) onApplyToTextChanged;
  final Function(bool) onApplyToBackgroundChanged;

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
    this.applyToBackground = false,
    required this.onApplyToImageChanged,
    required this.onApplyToTextChanged,
    this.onApplyToBackgroundChanged = _defaultBoolCallback,
  }) : super(key: key);

  // Default callback for optional function parameters
  static void _defaultBoolCallback(bool value) {}

  @override
  State<EnhancedPanelHeader> createState() => _EnhancedPanelHeaderState();
}

class _EnhancedPanelHeaderState extends State<EnhancedPanelHeader> {
  late PresetRefreshService _refreshService;

  @override
  void initState() {
    super.initState();
    _refreshService = PresetRefreshService();
    _refreshService.addListener(_onRefresh);
  }

  @override
  void dispose() {
    _refreshService.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when presets are refreshed
      });
    }
  }

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
                '${widget.aspect.label} Settings',
                style: TextStyle(
                  color: widget.sliderColor,
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
                aspect: widget.aspect,
                textColor: widget.sliderColor,
                onSavePreset: widget.onSavePreset,
                onReset: widget.onReset,
                applyToImage: widget.applyToImage,
                applyToText: widget.applyToText,
                applyToBackground: widget.applyToBackground,
                onApplyToImageChanged: widget.onApplyToImageChanged,
                onApplyToTextChanged: widget.onApplyToTextChanged,
                onApplyToBackgroundChanged: widget.onApplyToBackgroundChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Preset chips
        FutureBuilder<Map<String, dynamic>>(
          key: ValueKey(
            'presets_${widget.aspect.toString()}_${_refreshService.getRefreshCounter(widget.aspect)}',
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
                                        final success = await widget
                                            .deletePreset(
                                              widget.aspect,
                                              entry.key,
                                            );
                                        if (success) {
                                          widget.refreshPresets();
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
