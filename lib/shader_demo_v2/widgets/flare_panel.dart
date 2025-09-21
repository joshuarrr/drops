import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../services/preset_refresh_service.dart';
// Removed single-value slider after range migration
import 'enhanced_panel_header.dart';
import 'animation_controls.dart';
import 'range_lockable_slider.dart';
import '../controllers/animation_state_manager.dart';

class FlarePanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const FlarePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<FlarePanel> createState() => _FlarePanelState();
}

class _FlarePanelState extends State<FlarePanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.flareEnabled) {
        final updated = widget.settings;
        updated.flareEnabled = true;
        widget.onSettingsChanged(updated);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings.flareSettings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.flare,
          onPresetSelected: _applyPreset,
          onReset: _reset,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: widget.settings.flareSettings.applyToImage,
          applyToText: widget.settings.flareSettings.applyToText,
          onApplyToImageChanged: (v) {
            widget.settings.flareSettings.applyToImage = v;
            widget.onSettingsChanged(widget.settings);
          },
          onApplyToTextChanged: (v) {
            widget.settings.flareSettings.applyToText = v;
            widget.onSettingsChanged(widget.settings);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              RangeLockableSlider(
                label: 'Distortion',
                range: s.distortionRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults: ShaderSettings.defaults.flareSettings.distortionRange,
                parameterId: ParameterIds.flareDistortion,
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setDistortionRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              const SizedBox(height: 12),

              RangeLockableSlider(
                label: 'Swirl',
                range: s.swirlRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults: ShaderSettings.defaults.flareSettings.swirlRange,
                parameterId: ParameterIds.flareSwirl,
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setSwirlRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 12),

              RangeLockableSlider(
                label: 'Offset X',
                range: s.offsetXRange,
                min: -1.0,
                max: 1.0,
                divisions: 200,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults: ShaderSettings.defaults.flareSettings.offsetXRange,
                parameterId: ParameterIds.flareOffsetX,
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setOffsetXRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              const SizedBox(height: 12),

              RangeLockableSlider(
                label: 'Offset Y',
                range: s.offsetYRange,
                min: -1.0,
                max: 1.0,
                divisions: 200,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults: ShaderSettings.defaults.flareSettings.offsetYRange,
                parameterId: ParameterIds.flareOffsetY,
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setOffsetYRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              const SizedBox(height: 12),

              RangeLockableSlider(
                label: 'Scale',
                range: s.scaleRange,
                min: 0.01,
                max: 4.0,
                divisions: 399,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults: ShaderSettings.defaults.flareSettings.scaleRange,
                parameterId: ParameterIds.flareScale,
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setScaleRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              const SizedBox(height: 12),

              // Opacity (range-ready per upgrade doc)
              RangeLockableSlider(
                label: 'Opacity',
                range: s.opacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.flareSettings.opacityRange,
                parameterId: 'flare.opacity',
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setOpacityRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              RangeLockableSlider(
                label: 'Rotation',
                range: s.rotationRange,
                min: 0.0,
                max: 360.0,
                divisions: 360,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.toStringAsFixed(0)}°',
                defaults: ShaderSettings.defaults.flareSettings.rotationRange,
                parameterId: ParameterIds.flareRotation,
                animationEnabled: widget.settings.flareSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updated = widget.settings;
                  updated.flareSettings.setRotationRange(range);
                  widget.onSettingsChanged(updated);
                },
              ),

              const SizedBox(height: 16),

              // Animation toggle (pattern matches other panels)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Animate Effect',
                    style: TextStyle(color: widget.sliderColor, fontSize: 14),
                  ),
                  Switch(
                    value: widget.settings.flareSettings.effectAnimated,
                    activeColor: widget.sliderColor,
                    onChanged: (value) {
                      final updated = widget.settings;
                      updated.flareSettings.effectAnimated = value;
                      updated.flareEnabled = true;
                      widget.onSettingsChanged(updated);
                    },
                  ),
                ],
              ),

              // Show standard animation controls when enabled
              if (widget.settings.flareSettings.effectAnimated)
                AnimationControls(
                  animationSpeed:
                      widget.settings.flareSettings.animOptions.speed,
                  onSpeedChanged: (v) {
                    final updated = widget.settings;
                    updated.flareSettings.animOptions = updated
                        .flareSettings
                        .animOptions
                        .copyWith(speed: v);
                    updated.flareEnabled = true;
                    widget.onSettingsChanged(updated);
                  },
                  animationMode: widget.settings.flareSettings.animOptions.mode,
                  onModeChanged: (m) {
                    final updated = widget.settings;
                    updated.flareSettings.animOptions = updated
                        .flareSettings
                        .animOptions
                        .copyWith(mode: m);
                    updated.flareEnabled = true;
                    widget.onSettingsChanged(updated);
                  },
                  animationEasing:
                      widget.settings.flareSettings.animOptions.easing,
                  onEasingChanged: (e) {
                    final updated = widget.settings;
                    updated.flareSettings.animOptions = updated
                        .flareSettings
                        .animOptions
                        .copyWith(easing: e);
                    updated.flareEnabled = true;
                    widget.onSettingsChanged(updated);
                  },
                  sliderColor: widget.sliderColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // No single-value update helpers; all controls use range updates above

  void _reset() {
    final updated = widget.settings;
    updated.flareSettings.reset();
    updated.flareEnabled = true;
    widget.onSettingsChanged(updated);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    final updated = widget.settings;
    updated.flareEnabled = presetData['effectEnabled'] ?? true;
    updated.flareSettings.distortion = (presetData['distortion'] ?? 0.8)
        .toDouble();
    updated.flareSettings.swirl = (presetData['swirl'] ?? 0.1).toDouble();
    updated.flareSettings.grainMixer = (presetData['grainMixer'] ?? 0.0)
        .toDouble();
    updated.flareSettings.grainOverlay = (presetData['grainOverlay'] ?? 0.0)
        .toDouble();
    updated.flareSettings.offsetX = (presetData['offsetX'] ?? 0.0).toDouble();
    updated.flareSettings.offsetY = (presetData['offsetY'] ?? 0.0).toDouble();
    updated.flareSettings.scale = (presetData['scale'] ?? 1.0).toDouble();
    updated.flareSettings.rotation = (presetData['rotation'] ?? 0.0).toDouble();
    updated.flareSettings.speed = (presetData['speed'] ?? 1.0).toDouble();
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
    final s = widget.settings.flareSettings;
    final presetData = {
      'effectEnabled': true,
      'distortion': s.distortion,
      'swirl': s.swirl,
      'grainMixer': s.grainMixer,
      'grainOverlay': s.grainOverlay,
      'offsetX': s.offsetX,
      'offsetY': s.offsetY,
      'scale': s.scale,
      'rotation': s.rotation,
      'speed': s.speed,
      'applyToImage': s.applyToImage,
      'applyToText': s.applyToText,
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
