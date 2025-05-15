import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import 'aspect_panel_header.dart';
import '../views/effect_controls.dart';

class ImagePanel extends StatelessWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const ImagePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectPanelHeader(
          aspect: ShaderAspect.image,
          onPresetSelected: _applyPreset,
          onReset: _resetImage,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        RadioListTile<bool>(
          value: false,
          groupValue: settings.fillScreen,
          onChanged: (value) {
            if (value != null) {
              settings.fillScreen = value;
              onSettingsChanged(settings);
            }
          },
          title: Text(
            'Fit to Screen',
            style: TextStyle(color: sliderColor, fontSize: 14),
          ),
          activeColor: sliderColor,
        ),
        RadioListTile<bool>(
          value: true,
          groupValue: settings.fillScreen,
          onChanged: (value) {
            if (value != null) {
              settings.fillScreen = value;
              onSettingsChanged(settings);
            }
          },
          title: Text(
            'Fill Screen',
            style: TextStyle(color: sliderColor, fontSize: 14),
          ),
          activeColor: sliderColor,
        ),
      ],
    );
  }

  void _resetImage() {
    settings.fillScreen = false;
    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.fillScreen = presetData['fillScreen'] ?? settings.fillScreen;
    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {'fillScreen': settings.fillScreen};

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  // These will need to be connected to EffectControls static methods
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    // Delegate to EffectControls
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
    // Call the central refresh method for immediate UI update
    EffectControls.refreshPresets();
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return success;
  }
}
