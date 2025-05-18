import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../models/image_category.dart';
import 'aspect_panel_header.dart';
import '../views/effect_controls.dart';
import 'image_selector.dart';

class ImagePanel extends StatelessWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  // Parameters for image selection
  final List<String> coverImages;
  final List<String> artistImages;
  final String selectedImage;
  final ImageCategory imageCategory;
  final Function(String) onImageSelected;
  final Function(ImageCategory) onCategoryChanged;

  const ImagePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
    required this.coverImages,
    required this.artistImages,
    required this.selectedImage,
    required this.imageCategory,
    required this.onImageSelected,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header at the top
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

        const SizedBox(height: 16),

        // Apply Shaders to Image toggle directly below header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Apply Shaders to Image',
              style: TextStyle(color: sliderColor, fontSize: 14),
            ),
            Switch(
              value: settings.textLayoutSettings.applyShaderEffectsToImage,
              activeColor: sliderColor,
              onChanged: (value) {
                settings.textLayoutSettings.applyShaderEffectsToImage = value;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),

        const SizedBox(height: 16),
        Divider(color: sliderColor.withOpacity(0.3)),
        const SizedBox(height: 16),

        // Image selector
        ImageSelector(
          category: imageCategory,
          coverImages: coverImages,
          artistImages: artistImages,
          selectedImage: selectedImage,
          onCategoryChanged: onCategoryChanged,
          onImageSelected: onImageSelected,
        ),

        const SizedBox(height: 16),
        Divider(color: sliderColor.withOpacity(0.3)),
        const SizedBox(height: 16),

        // Radio buttons for display mode
        Text(
          'Display Mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: sliderColor,
          ),
        ),
        const SizedBox(height: 8),
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
          contentPadding: EdgeInsets.zero,
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
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _resetImage() {
    settings.fillScreen = false;
    settings.textLayoutSettings.applyShaderEffectsToImage = false;
    settings.textLayoutSettings.fitScreenMargin = 30.0;
    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.fillScreen = presetData['fillScreen'] ?? settings.fillScreen;
    settings.textLayoutSettings.applyShaderEffectsToImage =
        presetData['applyShaderEffectsToImage'] ??
        settings.textLayoutSettings.applyShaderEffectsToImage;
    settings.textLayoutSettings.fitScreenMargin =
        presetData['fitScreenMargin'] ?? 30.0;
    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'fillScreen': settings.fillScreen,
      'applyShaderEffectsToImage':
          settings.textLayoutSettings.applyShaderEffectsToImage,
      'fitScreenMargin': settings.textLayoutSettings.fitScreenMargin,
    };

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
