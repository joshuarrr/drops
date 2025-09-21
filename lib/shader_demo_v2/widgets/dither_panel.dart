import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../services/preset_refresh_service.dart';
import 'lockable_slider.dart';
import 'enhanced_panel_header.dart';

class DitherPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const DitherPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<DitherPanel> createState() => _DitherPanelState();
}

class _DitherPanelState extends State<DitherPanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.ditherEnabled) {
        final updated = widget.settings;
        updated.ditherEnabled = true;
        widget.onSettingsChanged(updated);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.dither,
          onPresetSelected: _applyPreset,
          onReset: _resetEffect,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: true,
          applyToText: false,
          onApplyToImageChanged: (v) {},
          onApplyToTextChanged: (v) {},
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Type slider (0..2)
              LockableSlider(
                label: 'Type',
                value: widget.settings.ditherSettings.type,
                min: 0.0,
                max: 2.0,
                divisions: 2,
                displayValue: _typeLabel(widget.settings.ditherSettings.type),
                onChanged: _onTypeChanged,
                activeColor: widget.sliderColor,
                parameterId: 'dither.type',
                animationEnabled: false,
                defaultValue: 0.0,
              ),

              const SizedBox(height: 16),

              // Pixel size slider (1..16 px)
              LockableSlider(
                label: 'Pixel Size',
                value: widget.settings.ditherSettings.pixelSize,
                min: 1.0,
                max: 16.0,
                divisions: 15,
                displayValue:
                    '${widget.settings.ditherSettings.pixelSize.round()}px',
                onChanged: _onPixelSizeChanged,
                activeColor: widget.sliderColor,
                parameterId: 'dither.pixelSize',
                animationEnabled: false,
                defaultValue: 3.0,
              ),

              const SizedBox(height: 16),

              // Color steps slider (2..16)
              LockableSlider(
                label: 'Color Steps',
                value: widget.settings.ditherSettings.colorSteps,
                min: 2.0,
                max: 16.0,
                divisions: 14,
                displayValue: widget.settings.ditherSettings.colorSteps
                    .round()
                    .toString(),
                onChanged: _onColorStepsChanged,
                activeColor: widget.sliderColor,
                parameterId: 'dither.colorSteps',
                animationEnabled: false,
                defaultValue: 4.0,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _typeLabel(double v) {
    final idx = v.round();
    switch (idx) {
      case 0:
        return 'Bayer';
      case 1:
        return 'Random';
      default:
        return 'Atkinson';
    }
  }

  void _onTypeChanged(double value) {
    final updated = widget.settings;
    updated.ditherSettings.type = value.roundToDouble();
    widget.onSettingsChanged(updated);
  }

  void _onPixelSizeChanged(double value) {
    final updated = widget.settings;
    updated.ditherSettings.pixelSize = value.clamp(1.0, 64.0);
    widget.onSettingsChanged(updated);
  }

  void _onColorStepsChanged(double value) {
    final updated = widget.settings;
    updated.ditherSettings.colorSteps = value.clamp(2.0, 32.0);
    widget.onSettingsChanged(updated);
  }

  void _resetEffect() {
    final updated = widget.settings;
    updated.ditherSettings.reset();
    widget.onSettingsChanged(updated);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    final updated = widget.settings;
    updated.ditherEnabled = presetData['effectEnabled'] ?? true;
    updated.ditherSettings.type = (presetData['type'] ?? 0.0).toDouble();
    updated.ditherSettings.pixelSize = (presetData['pixelSize'] ?? 3.0)
        .toDouble();
    updated.ditherSettings.colorSteps = (presetData['colorSteps'] ?? 4.0)
        .toDouble();
    widget.onSettingsChanged(updated);
  }

  Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (_cachedPresets.containsKey(aspect)) return _cachedPresets[aspect]!;
    _cachedPresets[aspect] = {};
    return _cachedPresets[aspect]!;
  }

  Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String presetName,
  ) async {
    _cachedPresets.remove(aspect);
    _refreshPresets();
    return true;
  }

  void _savePresetForAspect(ShaderAspect aspect, String presetName) {
    if (presetName.isEmpty) return;
    final presetData = {
      'effectEnabled': true,
      'type': widget.settings.ditherSettings.type,
      'pixelSize': widget.settings.ditherSettings.pixelSize,
      'colorSteps': widget.settings.ditherSettings.colorSteps,
    };
    _cachedPresets.putIfAbsent(aspect, () => {});
    _cachedPresets[aspect]![presetName] = presetData;
    final refreshService = PresetRefreshService();
    refreshService.refreshAspect(aspect);
    _refreshPresets();
  }

  void _refreshPresets() {
    setState(() {
      _refreshCounter++;
    });
  }
}
