import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../models/image_category.dart';
import '../services/preset_refresh_service.dart';
// TODO: Replace with V2 state management
// import '../state/shader_demo_state.dart';
import 'enhanced_panel_header.dart';
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
    return GestureDetector(
      // Explicitly prevent taps on this panel from being handled by parent widgets
      onTap: () {
        // Capture tap events to prevent them from bubbling up
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header at the top
          EnhancedPanelHeader(
            aspect: ShaderAspect.image,
            onPresetSelected: _applyPreset,
            onReset: _resetImage,
            onSavePreset: _savePresetForAspect,
            sliderColor: sliderColor,
            loadPresets: _loadPresetsForAspect,
            deletePreset: _deletePresetAndUpdate,
            refreshPresets: _refreshPresets,
            refreshCounter: _refreshCounter,
            // For the image panel, only apply to image makes sense
            // "Apply to Text" option will be hidden in the menu
            applyToImage: true,
            applyToText: true,
            onApplyToImageChanged: (_) {},
            onApplyToTextChanged: (_) {},
          ),

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
                // Create a deep copy to avoid mutation issues
                final updatedSettings = ShaderSettings.fromMap(
                  settings.toMap(),
                );
                updatedSettings.fillScreen = value;
                onSettingsChanged(updatedSettings);
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
                // Create a deep copy to avoid mutation issues
                final updatedSettings = ShaderSettings.fromMap(
                  settings.toMap(),
                );
                updatedSettings.fillScreen = value;
                onSettingsChanged(updatedSettings);
              }
            },
            title: Text(
              'Fill Screen',
              style: TextStyle(color: sliderColor, fontSize: 14),
            ),
            activeColor: sliderColor,
            contentPadding: EdgeInsets.zero,
          ),

          // Show margin slider only when in Fit to Screen mode
          if (!settings.fillScreen) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Margin: ',
                  style: TextStyle(color: sliderColor, fontSize: 14),
                ),
                Text(
                  '${settings.textLayoutSettings.fitScreenMargin.toStringAsFixed(1)}',
                  style: TextStyle(color: sliderColor, fontSize: 14),
                ),
              ],
            ),
            Slider(
              value: settings.textLayoutSettings.fitScreenMargin,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              activeColor: sliderColor,
              inactiveColor: sliderColor.withOpacity(0.3),
              onChanged: (value) {
                // Create a deep copy to avoid mutation issues
                final updatedSettings = ShaderSettings.fromMap(
                  settings.toMap(),
                );
                updatedSettings.textLayoutSettings.fitScreenMargin = value;
                onSettingsChanged(updatedSettings);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _resetImage() {
    // Create a deep copy of the settings to ensure changes are properly tracked
    final updatedSettings = ShaderSettings.fromMap(settings.toMap());

    // Use default values (extracted from V1 ShaderDemoState)
    updatedSettings.fillScreen = false; // defaultFillScreen
    updatedSettings.textLayoutSettings.fitScreenMargin = 50.0; // defaultMargin

    // Reset all effect targeting flags to default values (true)
    updatedSettings.colorSettings.applyToImage = true;
    updatedSettings.blurSettings.applyToImage = true;
    updatedSettings.noiseSettings.applyToImage = true;
    updatedSettings.rainSettings.applyToImage = true;
    updatedSettings.chromaticSettings.applyToImage = true;
    updatedSettings.rippleSettings.applyToImage = true;

    onSettingsChanged(updatedSettings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    // Debug print to see what's in the preset data
    debugPrint('APPLYING PRESET:');
    debugPrint('  Keys: ${presetData.keys.join(', ')}');

    // Print all values in presetData for debugging
    presetData.forEach((key, value) {
      debugPrint('  $key: $value');
    });

    // Create a deep copy of the settings to ensure changes are properly tracked
    final updatedSettings = ShaderSettings.fromMap(settings.toMap());

    // Store current values for debugging
    final originalFillScreen = updatedSettings.fillScreen;
    final originalMargin = updatedSettings.textLayoutSettings.fitScreenMargin;
    debugPrint(
      '  Original values - fillScreen: $originalFillScreen, margin: $originalMargin',
    );

    // Handle fillScreen setting - check direct presetData key
    if (presetData.containsKey('fillScreen')) {
      final bool fillScreenValue = presetData['fillScreen'] as bool;
      updatedSettings.fillScreen = fillScreenValue;
      debugPrint('  Applied fillScreen: $fillScreenValue');
    } else {
      debugPrint('  No fillScreen found in preset data!');
    }

    // Handle margin setting - check direct presetData key
    if (presetData.containsKey('fitScreenMargin')) {
      final double marginValue = (presetData['fitScreenMargin'] as num)
          .toDouble();
      updatedSettings.textLayoutSettings.fitScreenMargin = marginValue;
      debugPrint('  Applied margin: $marginValue');
    } else {
      debugPrint('  No fitScreenMargin found in preset data!');

      // Check if there's a settings object that might contain our margin
      if (presetData.containsKey('settings') &&
          presetData['settings'] is Map<String, dynamic>) {
        final settingsMap = presetData['settings'] as Map<String, dynamic>;
        debugPrint(
          '  Looking in nested settings: ${settingsMap.keys.join(', ')}',
        );

        if (settingsMap.containsKey('textLayoutSettings') &&
            settingsMap['textLayoutSettings'] is Map<String, dynamic>) {
          final textLayoutMap =
              settingsMap['textLayoutSettings'] as Map<String, dynamic>;
          debugPrint(
            '  Found textLayoutSettings: ${textLayoutMap.keys.join(', ')}',
          );

          if (textLayoutMap.containsKey('fitScreenMargin')) {
            final double nestedMargin =
                (textLayoutMap['fitScreenMargin'] as num).toDouble();
            debugPrint('  Found nested margin: $nestedMargin');
            updatedSettings.textLayoutSettings.fitScreenMargin = nestedMargin;
          }
        }
      }
    }

    onSettingsChanged(updatedSettings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    // Include all settings that need to be directly accessible when the preset is loaded
    Map<String, dynamic> presetData = {
      'fillScreen': settings.fillScreen,
      'fitScreenMargin': settings.textLayoutSettings.fitScreenMargin,
    };

    debugPrint(
      'Saving aspect preset with fillScreen: ${settings.fillScreen}, margin: ${settings.textLayoutSettings.fitScreenMargin}',
    );

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
    PresetRefreshService().refreshAspect(ShaderAspect.image);
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Trigger refresh after deletion
      PresetRefreshService().refreshAspect(aspect);
    }
    return success;
  }
}
