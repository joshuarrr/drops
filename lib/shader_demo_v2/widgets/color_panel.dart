import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/color_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import '../controllers/effect_controller.dart';
import '../controllers/animation_state_manager.dart';
import '../models/parameter_range.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class ColorPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const ColorPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<ColorPanel> createState() => _ColorPanelState();
}

class _ColorPanelState extends State<ColorPanel> {
  bool _showColorControls = true;
  bool _showOverlayControls = true;
  final String _logTag = 'ColorPanel';

  // Custom log function that uses both dart:developer and debugPrint
  void _log(String message, {LogLevel level = LogLevel.info}) {
    // Use the shared logger with our tag
    if (level == LogLevel.debug &&
        EffectLogger.currentLevel.index > LogLevel.debug.index) {
      return; // Skip debug logs based on current level
    }

    developer.log(message, name: _logTag);

    // Only print to console for info level and above
    if (level.index >= LogLevel.info.index) {
      debugPrint('[$_logTag] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _log('ColorPanel initialized', level: LogLevel.debug);
  }

  @override
  Widget build(BuildContext context) {
    // Only log builds at debug level
    _log('Building ColorPanel', level: LogLevel.debug);

    final colorSettings = widget.settings.colorSettings;
    final colorDefaults = ShaderSettings.defaults.colorSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.color,
          onPresetSelected: _applyPreset,
          onReset: _resetColor,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: widget.settings.colorSettings.applyToImage,
          applyToText: widget.settings.colorSettings.applyToText,
          onApplyToImageChanged: (value) {
            widget.settings.colorSettings.applyToImage = value;
            widget.onSettingsChanged(widget.settings);
          },
          onApplyToTextChanged: (value) {
            widget.settings.colorSettings.applyToText = value;
            widget.onSettingsChanged(widget.settings);
          },
        ),
        // Main color controls section with collapsible header
        _buildSectionHeader(
          'Color Adjustments',
          _showColorControls,
          () => setState(() {
            _showColorControls = !_showColorControls;
            _log(
              'Color adjustments section ${_showColorControls ? 'expanded' : 'collapsed'}',
              level: LogLevel.debug,
            );
          }),
        ),
        if (_showColorControls) ...[
          ..._buildColorRangeSliders(colorSettings, colorDefaults),
          // Toggle animation for HSL adjustments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate HSL',
                style: TextStyle(color: widget.sliderColor, fontSize: 14),
              ),
              Switch(
                value: widget.settings.colorSettings.colorAnimated,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? widget.sliderColor
                      : null,
                ),
                onChanged: (value) {
                  widget.settings.colorSettings.colorAnimated = value;
                  if (!widget.settings.colorEnabled)
                    widget.settings.colorEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                  _log('HSL animation toggled: ${value ? 'ON' : 'OFF'}');
                },
              ),
            ],
          ),
          if (widget.settings.colorSettings.colorAnimated)
            AnimationControls(
              animationSpeed:
                  widget.settings.colorSettings.colorAnimOptions.speed,
              onSpeedChanged: (v) {
                widget.settings.colorSettings.colorAnimOptions = widget
                    .settings
                    .colorSettings
                    .colorAnimOptions
                    .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
                _log('HSL animation speed changed: $v', level: LogLevel.debug);
              },
              animationMode:
                  widget.settings.colorSettings.colorAnimOptions.mode,
              onModeChanged: (m) {
                widget.settings.colorSettings.colorAnimOptions = widget
                    .settings
                    .colorSettings
                    .colorAnimOptions
                    .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
                _log(
                  'HSL animation mode changed: ${m.toString()}',
                  level: LogLevel.debug,
                );
              },
              animationEasing:
                  widget.settings.colorSettings.colorAnimOptions.easing,
              onEasingChanged: (e) {
                widget.settings.colorSettings.colorAnimOptions = widget
                    .settings
                    .colorSettings
                    .colorAnimOptions
                    .copyWith(easing: e);
                widget.onSettingsChanged(widget.settings);
                _log(
                  'HSL animation easing changed: ${e.toString()}',
                  level: LogLevel.debug,
                );
              },
              sliderColor: widget.sliderColor,
            ),
        ],

        const SizedBox(height: 16),

        // Overlay section with collapsible header
        _buildSectionHeader(
          'Overlay Controls',
          _showOverlayControls,
          () => setState(() {
            _showOverlayControls = !_showOverlayControls;
            _log(
              'Overlay controls section ${_showOverlayControls ? 'expanded' : 'collapsed'}',
              level: LogLevel.debug,
            );
          }),
        ),
        if (_showOverlayControls) ...[
          ..._buildOverlayRangeSliders(colorSettings, colorDefaults),
          // Toggle animation for overlay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate Overlay',
                style: TextStyle(color: widget.sliderColor, fontSize: 14),
              ),
              Switch(
                value: widget.settings.colorSettings.overlayAnimated,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? widget.sliderColor
                      : null,
                ),
                onChanged: (value) {
                  widget.settings.colorSettings.overlayAnimated = value;
                  if (!widget.settings.colorEnabled)
                    widget.settings.colorEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                  _log('Overlay animation toggled: ${value ? 'ON' : 'OFF'}');
                },
              ),
            ],
          ),
          if (widget.settings.colorSettings.overlayAnimated)
            AnimationControls(
              animationSpeed:
                  widget.settings.colorSettings.overlayAnimOptions.speed,
              onSpeedChanged: (v) {
                widget.settings.colorSettings.overlayAnimOptions = widget
                    .settings
                    .colorSettings
                    .overlayAnimOptions
                    .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
                _log(
                  'Overlay animation speed changed: $v',
                  level: LogLevel.debug,
                );
              },
              animationMode:
                  widget.settings.colorSettings.overlayAnimOptions.mode,
              onModeChanged: (m) {
                widget.settings.colorSettings.overlayAnimOptions = widget
                    .settings
                    .colorSettings
                    .overlayAnimOptions
                    .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
                _log(
                  'Overlay animation mode changed: ${m.toString()}',
                  level: LogLevel.debug,
                );
              },
              animationEasing:
                  widget.settings.colorSettings.overlayAnimOptions.easing,
              onEasingChanged: (e) {
                widget.settings.colorSettings.overlayAnimOptions = widget
                    .settings
                    .colorSettings
                    .overlayAnimOptions
                    .copyWith(easing: e);
                widget.onSettingsChanged(widget.settings);
                _log(
                  'Overlay animation easing changed: ${e.toString()}',
                  level: LogLevel.debug,
                );
              },
              sliderColor: widget.sliderColor,
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: widget.sliderColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.sliderColor.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Cache previous slider values to avoid redundant logs
  final Map<String, double> _lastSliderValues = {};

  List<Widget> _buildColorRangeSliders(
    ColorSettings colorSettings,
    ColorSettings colorDefaults,
  ) {
    String formatPercent(double value) => '${(value * 100).round()}%';

    return [
      RangeLockableSlider(
        label: 'Hue',
        range: colorSettings.hueRange,
        min: -1.0,
        max: 1.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatPercent,
        defaults: colorDefaults.hueRange,
        parameterId: ParameterIds.colorHue,
        animationEnabled: colorSettings.colorAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (settings, updated) => settings.setHueRange(updated),
          propertyName: 'Hue',
        ),
      ),
      RangeLockableSlider(
        label: 'Saturation',
        range: colorSettings.saturationRange,
        min: -1.0,
        max: 1.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatPercent,
        defaults: colorDefaults.saturationRange,
        parameterId: ParameterIds.colorSaturation,
        animationEnabled: colorSettings.colorAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (settings, updated) => settings.setSaturationRange(updated),
          propertyName: 'Saturation',
        ),
      ),
      RangeLockableSlider(
        label: 'Lightness',
        range: colorSettings.lightnessRange,
        min: -1.0,
        max: 1.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatPercent,
        defaults: colorDefaults.lightnessRange,
        parameterId: ParameterIds.colorLightness,
        animationEnabled: colorSettings.colorAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (settings, updated) => settings.setLightnessRange(updated),
          propertyName: 'Lightness',
        ),
      ),
    ];
  }

  List<Widget> _buildOverlayRangeSliders(
    ColorSettings colorSettings,
    ColorSettings colorDefaults,
  ) {
    String formatPercent(double value) => '${(value * 100).round()}%';

    return [
      RangeLockableSlider(
        label: 'Overlay Hue',
        range: colorSettings.overlayHueRange,
        min: -1.0,
        max: 1.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatPercent,
        defaults: colorDefaults.overlayHueRange,
        parameterId: ParameterIds.overlayHue,
        animationEnabled: colorSettings.overlayAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (settings, updated) => settings.setOverlayHueRange(updated),
          propertyName: 'Overlay Hue',
          isOverlay: true,
        ),
      ),
      RangeLockableSlider(
        label: 'Overlay Intensity',
        range: colorSettings.overlayIntensityRange,
        min: -1.0,
        max: 1.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatPercent,
        defaults: colorDefaults.overlayIntensityRange,
        parameterId: ParameterIds.overlayIntensity,
        animationEnabled: colorSettings.overlayAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (settings, updated) => settings.setOverlayIntensityRange(updated),
          propertyName: 'Overlay Intensity',
          isOverlay: true,
        ),
      ),
      RangeLockableSlider(
        label: 'Overlay Opacity',
        range: colorSettings.overlayOpacityRange,
        min: -1.0,
        max: 1.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatPercent,
        defaults: colorDefaults.overlayOpacityRange,
        parameterId: ParameterIds.overlayOpacity,
        animationEnabled: colorSettings.overlayAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (settings, updated) => settings.setOverlayOpacityRange(updated),
          propertyName: 'Overlay Opacity',
          isOverlay: true,
        ),
      ),
    ];
  }

  void _onSliderChanged(
    double value,
    Function(double) setter, {
    bool isOverlay = false,
    required String propertyName,
  }) {
    // Enable the corresponding effect if it's not already enabled
    if (!widget.settings.colorEnabled) widget.settings.colorEnabled = true;

    // Check if value has changed significantly enough to log
    final String cacheKey = propertyName;
    final bool shouldLog =
        !_lastSliderValues.containsKey(cacheKey) ||
        (_lastSliderValues[cacheKey]! - value).abs() > 0.05;

    // Update the setting value
    setter(value);

    // Log the change if significant
    if (shouldLog) {
      _log(
        '$propertyName changed to: ${value.toStringAsFixed(2)}',
        level: LogLevel.debug,
      );
      _lastSliderValues[cacheKey] = value;
    }

    // For overlay controls, make sure either both intensity and opacity are non-zero,
    // or both are zero to prevent unintended overlay effects
    if (isOverlay) {
      // If changing overlay hue but intensity or opacity is zero,
      // we don't enable overlay effect implicitly
      if (widget.settings.colorSettings.overlayIntensity <= 0.0 ||
          widget.settings.colorSettings.overlayOpacity <= 0.0) {
        _log(
          'Overlay effects might not be visible (Intensity: ${widget.settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, Opacity: ${widget.settings.colorSettings.overlayOpacity.toStringAsFixed(2)})',
          level: LogLevel.debug,
        );
      }
    } else {
      // For non-overlay controls, ensure we don't unintentionally set overlay values
      // This ensures that changing color settings doesn't create an overlay effect
      if (widget.settings.colorSettings.overlayIntensity > 0.0 &&
          widget.settings.colorSettings.overlayOpacity > 0.0 &&
          widget.settings.colorEnabled) {
        // Only if we're in a color section but not an overlay section
        // No need to reset overlay values here - they should only be changed
        // when explicitly adjusted in the overlay controls
        _log(
          'Color adjustment with active overlay (Intensity: ${widget.settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, Opacity: ${widget.settings.colorSettings.overlayOpacity.toStringAsFixed(2)})',
          level: LogLevel.debug,
        );
      }
    }

    // Notify the parent widget
    widget.onSettingsChanged(widget.settings);
  }

  void _onRangeChanged(
    ParameterRange range,
    void Function(ColorSettings, ParameterRange) setter, {
    required String propertyName,
    bool isOverlay = false,
  }) {
    if (!widget.settings.colorEnabled) widget.settings.colorEnabled = true;

    setter(widget.settings.colorSettings, range);

    final double valueForLog = range.userMax;
    final bool shouldLog =
        !_lastSliderValues.containsKey(propertyName) ||
        (_lastSliderValues[propertyName]! - valueForLog).abs() > 0.05;

    if (shouldLog) {
      _log(
        '$propertyName range -> ${range.userMin.toStringAsFixed(2)} to ${range.userMax.toStringAsFixed(2)}',
        level: LogLevel.debug,
      );
      _lastSliderValues[propertyName] = valueForLog;
    }

    final overlayIntensity =
        widget.settings.colorSettings.overlayIntensityRange.userMax;
    final overlayOpacity =
        widget.settings.colorSettings.overlayOpacityRange.userMax;

    if (isOverlay) {
      if (overlayIntensity <= 0.0 || overlayOpacity <= 0.0) {
        _log(
          'Overlay effects might not be visible (Intensity: ${overlayIntensity.toStringAsFixed(2)}, Opacity: ${overlayOpacity.toStringAsFixed(2)})',
          level: LogLevel.debug,
        );
      }
    } else if (overlayIntensity > 0.0 && overlayOpacity > 0.0) {
      _log(
        'Color adjustment with active overlay (Intensity: ${overlayIntensity.toStringAsFixed(2)}, Opacity: ${overlayOpacity.toStringAsFixed(2)})',
        level: LogLevel.debug,
      );
    }

    widget.onSettingsChanged(widget.settings);
  }

  ParameterRange _rangeFromPreset(
    Map<String, dynamic> presetData, {
    required String rangeKey,
    required String valueKey,
    required String minKey,
    required String maxKey,
    required String currentKey,
  }) {
    const double hardMin = -1.0;
    const double hardMax = 1.0;

    final double fallback = _readDouble(
      presetData[valueKey],
      0.0,
    ).clamp(hardMin, hardMax)
        .toDouble();

    final dynamic payload = presetData[rangeKey];
    if (payload is Map<String, dynamic>) {
      return ParameterRange.fromMap(
        Map<String, dynamic>.from(payload),
        hardMin: hardMin,
        hardMax: hardMax,
        fallbackValue: fallback,
      );
    }

    final double userMin = _readDouble(
      presetData[minKey],
      0.0,
    ).clamp(hardMin, hardMax)
        .toDouble();
    final double userMax = _readDouble(
      presetData[maxKey],
      fallback,
    ).clamp(hardMin, hardMax)
        .toDouble();
    final double current = _readDouble(
      presetData[currentKey],
      fallback,
    ).clamp(hardMin, hardMax)
        .toDouble();

    return ParameterRange(
      hardMin: hardMin,
      hardMax: hardMax,
      initialValue: current,
      userMin: userMin,
      userMax: userMax,
    );
  }

  double _readDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  void _resetColor() {
    final defaults = ShaderSettings.defaults;
    widget.settings.colorEnabled = false;
    widget.settings.colorSettings.setHueRange(
      defaults.colorSettings.hueRange,
    );
    widget.settings.colorSettings.setSaturationRange(
      defaults.colorSettings.saturationRange,
    );
    widget.settings.colorSettings.setLightnessRange(
      defaults.colorSettings.lightnessRange,
    );
    widget.settings.colorSettings.setOverlayHueRange(
      defaults.colorSettings.overlayHueRange,
    );
    widget.settings.colorSettings.setOverlayIntensityRange(
      defaults.colorSettings.overlayIntensityRange,
    );
    widget.settings.colorSettings.setOverlayOpacityRange(
      defaults.colorSettings.overlayOpacityRange,
    );
    widget.settings.colorSettings.colorAnimated = false;
    widget.settings.colorSettings.overlayAnimated = false;
    widget.settings.colorSettings.colorAnimOptions = AnimationOptions();
    widget.settings.colorSettings.overlayAnimOptions = AnimationOptions();

    _log('Color settings reset to defaults');
    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    _log('Applying color preset', level: LogLevel.debug);

    widget.settings.colorEnabled =
        presetData['colorEnabled'] ?? widget.settings.colorEnabled;
    widget.settings.colorSettings.setHueRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'hueRange',
        valueKey: 'hue',
        minKey: 'hueMin',
        maxKey: 'hueMax',
        currentKey: 'hueCurrent',
      ),
    );
    widget.settings.colorSettings.setSaturationRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'saturationRange',
        valueKey: 'saturation',
        minKey: 'saturationMin',
        maxKey: 'saturationMax',
        currentKey: 'saturationCurrent',
      ),
    );
    widget.settings.colorSettings.setLightnessRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'lightnessRange',
        valueKey: 'lightness',
        minKey: 'lightnessMin',
        maxKey: 'lightnessMax',
        currentKey: 'lightnessCurrent',
      ),
    );
    widget.settings.colorSettings.setOverlayHueRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'overlayHueRange',
        valueKey: 'overlayHue',
        minKey: 'overlayHueMin',
        maxKey: 'overlayHueMax',
        currentKey: 'overlayHueCurrent',
      ),
    );
    widget.settings.colorSettings.setOverlayIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'overlayIntensityRange',
        valueKey: 'overlayIntensity',
        minKey: 'overlayIntensityMin',
        maxKey: 'overlayIntensityMax',
        currentKey: 'overlayIntensityCurrent',
      ),
    );
    widget.settings.colorSettings.setOverlayOpacityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'overlayOpacityRange',
        valueKey: 'overlayOpacity',
        minKey: 'overlayOpacityMin',
        maxKey: 'overlayOpacityMax',
        currentKey: 'overlayOpacityCurrent',
      ),
    );
    widget.settings.colorSettings.colorAnimated =
        presetData['colorAnimated'] ??
        widget.settings.colorSettings.colorAnimated;
    widget.settings.colorSettings.overlayAnimated =
        presetData['overlayAnimated'] ??
        widget.settings.colorSettings.overlayAnimated;

    if (presetData['colorAnimOptions'] != null) {
      widget.settings.colorSettings.colorAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['colorAnimOptions']),
      );
    }

    if (presetData['overlayAnimOptions'] != null) {
      widget.settings.colorSettings.overlayAnimOptions =
          AnimationOptions.fromMap(
            Map<String, dynamic>.from(presetData['overlayAnimOptions']),
          );
    }

    _log('Color preset applied successfully');
    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    _log('Saving color preset: $name');

    final hueRange = widget.settings.colorSettings.hueRange;
    final saturationRange = widget.settings.colorSettings.saturationRange;
    final lightnessRange = widget.settings.colorSettings.lightnessRange;
    final overlayHueRange = widget.settings.colorSettings.overlayHueRange;
    final overlayIntensityRange =
        widget.settings.colorSettings.overlayIntensityRange;
    final overlayOpacityRange =
        widget.settings.colorSettings.overlayOpacityRange;

    Map<String, dynamic> presetData = {
      'colorEnabled': widget.settings.colorEnabled,
      'hue': hueRange.userMax,
      'hueMin': hueRange.userMin,
      'hueMax': hueRange.userMax,
      'hueCurrent': hueRange.current,
      'hueRange': hueRange.toMap(),
      'saturation': saturationRange.userMax,
      'saturationMin': saturationRange.userMin,
      'saturationMax': saturationRange.userMax,
      'saturationCurrent': saturationRange.current,
      'saturationRange': saturationRange.toMap(),
      'lightness': lightnessRange.userMax,
      'lightnessMin': lightnessRange.userMin,
      'lightnessMax': lightnessRange.userMax,
      'lightnessCurrent': lightnessRange.current,
      'lightnessRange': lightnessRange.toMap(),
      'overlayHue': overlayHueRange.userMax,
      'overlayHueMin': overlayHueRange.userMin,
      'overlayHueMax': overlayHueRange.userMax,
      'overlayHueCurrent': overlayHueRange.current,
      'overlayHueRange': overlayHueRange.toMap(),
      'overlayIntensity': overlayIntensityRange.userMax,
      'overlayIntensityMin': overlayIntensityRange.userMin,
      'overlayIntensityMax': overlayIntensityRange.userMax,
      'overlayIntensityCurrent': overlayIntensityRange.current,
      'overlayIntensityRange': overlayIntensityRange.toMap(),
      'overlayOpacity': overlayOpacityRange.userMax,
      'overlayOpacityMin': overlayOpacityRange.userMin,
      'overlayOpacityMax': overlayOpacityRange.userMax,
      'overlayOpacityCurrent': overlayOpacityRange.current,
      'overlayOpacityRange': overlayOpacityRange.toMap(),
      'colorAnimated': widget.settings.colorSettings.colorAnimated,
      'overlayAnimated': widget.settings.colorSettings.overlayAnimated,
      'colorAnimOptions': widget.settings.colorSettings.colorAnimOptions
          .toMap(),
      'overlayAnimOptions': widget.settings.colorSettings.overlayAnimOptions
          .toMap(),
    };

    // These methods need to be implemented to work with the global preset system
    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      _log('Color preset saved successfully: $name');
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    } else {
      _log('Failed to save color preset: $name', level: LogLevel.warning);
    }
  }

  // These will need to be connected to EffectControls static methods
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    debugPrint('[ColorPanel] Loading presets for aspect: $aspect');
    // Delegate to EffectControls
    // This will need to be implemented to connect with the global preset system
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      debugPrint(
        '[ColorPanel] Loaded ${_cachedPresets[aspect]?.length ?? 0} presets for $aspect',
      );
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
    debugPrint('[ColorPanel] Refreshing presets, counter: $_refreshCounter');
    // Call the central refresh method for immediate UI update
    PresetRefreshService().refreshAspect(ShaderAspect.color);
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    debugPrint('[ColorPanel] Deleting preset: $name for aspect $aspect');
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      debugPrint('[ColorPanel] Successfully deleted preset: $name');
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Trigger refresh after deletion
      PresetRefreshService().refreshAspect(aspect);
    } else {
      debugPrint('[ColorPanel] Failed to delete preset: $name');
    }
    return success;
  }
}
