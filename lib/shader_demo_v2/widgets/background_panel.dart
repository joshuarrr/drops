import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../controllers/effect_controls_bridge.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../models/background_settings.dart';
import '../controllers/effect_controller.dart';
import 'color_picker.dart';
import 'enhanced_panel_header.dart';
import '../views/effect_controls.dart';

class BackgroundPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const BackgroundPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<BackgroundPanel> createState() => _BackgroundPanelState();
}

class _BackgroundPanelState extends State<BackgroundPanel> {
  // For logging
  final String _logTag = 'BackgroundPanel';
  int _refreshCounter = 0;

  // Track last color to avoid redundant logs
  Color? _lastColor;



  // Apply a preset to the background settings
  void _applyPreset(Map<String, dynamic> preset) {
    // _log('Applying background preset', level: LogLevel.debug);

    final updatedSettings = widget.settings;

    // Create background settings from the preset
    final backgroundSettings = BackgroundSettings.fromMap(
      Map<String, dynamic>.from(preset),
    );

    // Update the background settings
    updatedSettings.backgroundEnabled = backgroundSettings.backgroundEnabled;
    updatedSettings.backgroundSettings.backgroundColor =
        backgroundSettings.backgroundColor;
    updatedSettings.backgroundAnimated = backgroundSettings.backgroundAnimated;

    // Make sure the background is enabled
    updatedSettings.backgroundEnabled = true;

    // Notify parent of changes
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset background to default values
  void _resetBackground() {
    // _log('Resetting background settings', level: LogLevel.debug);

    final updatedSettings = widget.settings;

    // Reset to default values
    updatedSettings.backgroundEnabled = false;
    updatedSettings.backgroundSettings.backgroundColor = Colors.black;
    updatedSettings.backgroundAnimated = false;

    // Notify parent of changes
    widget.onSettingsChanged(updatedSettings);
  }

  // Save current background settings as a preset
  void _savePresetForAspect(ShaderAspect aspect, String name) async {
    // _log('Saving background preset: $name', level: LogLevel.info);

    // Get current background settings
    final presetData = widget.settings.backgroundSettings.toMap();

    // Save the preset
    final success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // _log('Successfully saved background preset: $name');
      _refreshPresets();
    } else {
      // _log('Failed to save background preset: $name', level: LogLevel.warning);
    }
  }

  // Load presets for the background aspect
  Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    final presets = await EffectControls.loadPresetsForAspect(aspect);
    return {'presets': presets};
  }

  // Delete a preset
  Future<bool> _deletePresetAndUpdate(ShaderAspect aspect, String name) async {
    return await EffectControls.deletePresetAndUpdate(aspect, name);
  }

  // Force a refresh of presets
  void _refreshPresets() {
    setState(() {
      _refreshCounter++;
    });
    EffectControls.refreshPresets();
  }

  @override
  Widget build(BuildContext context) {
    // Get current background color
    final Color currentColor =
        widget.settings.backgroundSettings.backgroundColor;

    // Check if color has changed significantly to log
    final bool hasColorChanged =
        _lastColor == null || _lastColor != currentColor;

    if (hasColorChanged) {
      // _log(
        'Background color: 0x${currentColor.value.toRadixString(16).padLeft(8, '0')}',
        level: LogLevel.debug,
      );
      _lastColor = currentColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.background,
          onPresetSelected: _applyPreset,
          onReset: _resetBackground,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: true,
          applyToText: true,
          onApplyToImageChanged: (_) {}, // Not used for background
          onApplyToTextChanged: (_) {}, // Not used for background
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Background Color',
            style: TextStyle(
              color: widget.sliderColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ColorPicker(
            label: 'Background Color',
            currentColor: currentColor,
            onColorChanged: (newColor) {
              // _log(
                'Background color changed to: 0x${newColor.value.toRadixString(16).padLeft(8, '0')}',
                level: LogLevel.info,
              );

              // Update the background color
              final updatedSettings = widget.settings;
              updatedSettings.backgroundSettings.backgroundColor = newColor;

              // Make sure background is enabled when changing colors
              updatedSettings.backgroundEnabled = true;
              // _log(
                'Background enabled: ${updatedSettings.backgroundEnabled}',
                level: LogLevel.info,
              );

              // Notify parent of changes
              widget.onSettingsChanged(updatedSettings);

              // Save the new color to avoid redundant logs
              _lastColor = newColor;
            },
            textColor: widget.sliderColor,
          ),
        ),
        const SizedBox(height: 16),
        // Add animation toggle if needed in the future
      ],
    );
  }
}
