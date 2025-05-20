import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import '../models/presets_manager.dart';
import '../controllers/effect_controller.dart';
import 'color_picker.dart';
import 'enhanced_panel_header.dart';

class TextFxPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const TextFxPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<TextFxPanel> createState() => _TextFxPanelState();
}

class _TextFxPanelState extends State<TextFxPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _logTag = 'TextFxPanel';

  // Track whether animation is enabled
  bool _animationEnabled = false;

  // Add static fields for presets
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  // Custom log function that uses both dart:developer and debugPrint for visibility
  void _log(String message, {LogLevel level = LogLevel.info}) {
    // Skip debug logs if we're running at a higher log level
    if (level == LogLevel.debug &&
        EffectLogger.currentLevel.index > LogLevel.debug.index) {
      return;
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
    _tabController = TabController(length: 6, vsync: this);
    _animationEnabled = widget.settings.textfxSettings.textfxAnimated;
    _log(
      'TextFxPanel initialized - TextFx enabled: ${widget.settings.textfxSettings.textfxEnabled}',
      level: LogLevel.debug,
    );
  }

  @override
  void didUpdateWidget(TextFxPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation state when settings change
    if (oldWidget.settings.textfxSettings.textfxAnimated !=
        widget.settings.textfxSettings.textfxAnimated) {
      setState(() {
        _animationEnabled = widget.settings.textfxSettings.textfxAnimated;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log('Building TextFxPanel', level: LogLevel.debug);

    return Column(
      children: [
        // Panel header with animation toggle, presets, and options
        EnhancedPanelHeader(
          aspect: ShaderAspect.textfx,
          onPresetSelected: _applyPreset,
          onReset: _resetTextFx,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          // TextFX only applies to text, so use the applyToText flag for consistent behavior
          applyToImage: false,
          applyToText: widget.settings.textfxSettings.applyToText,
          onApplyToImageChanged: (_) {}, // Not used
          onApplyToTextChanged: (value) {
            widget.settings.textfxSettings.applyToText = value;
            // Also enable/disable textfxEnabled for backward compatibility
            widget.settings.textfxSettings.textfxEnabled = value;
            widget.onSettingsChanged(widget.settings);
          },
        ),

        // Tabs for different effect types
        TabBar(
          controller: _tabController,
          labelColor: widget.sliderColor,
          unselectedLabelColor: widget.sliderColor.withOpacity(0.5),
          indicatorColor: widget.sliderColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Shadow'),
            Tab(text: 'Glow'),
            Tab(text: 'Outline'),
            Tab(text: 'Metal'),
            Tab(text: 'Glass'),
            Tab(text: 'Neon'),
          ],
        ),

        // Tab content
        SizedBox(
          height: 500, // Increased height to match other panels
          child: TabBarView(
            key: ValueKey(widget.settings.hashCode),
            controller: _tabController,
            children: [
              _buildShadowTab(),
              _buildGlowTab(),
              _buildOutlineTab(),
              _buildMetalTab(),
              _buildGlassTab(),
              _buildNeonTab(),
            ],
          ),
        ),
      ],
    );
  }

  // Add preset methods
  void _resetTextFx() {
    widget.settings.textfxSettings.textfxEnabled = false;
    widget.settings.textfxSettings.textShadowEnabled = false;
    widget.settings.textfxSettings.textGlowEnabled = false;
    widget.settings.textfxSettings.textOutlineEnabled = false;
    widget.settings.textfxSettings.textMetalEnabled = false;
    widget.settings.textfxSettings.textGlassEnabled = false;
    widget.settings.textfxSettings.textNeonEnabled = false;
    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    if (presetData.containsKey('textfxEnabled')) {
      widget.settings.textfxSettings.textfxEnabled =
          presetData['textfxEnabled'];
    }

    // Shadow settings
    if (presetData.containsKey('textShadowEnabled')) {
      widget.settings.textfxSettings.textShadowEnabled =
          presetData['textShadowEnabled'];
    }
    if (presetData.containsKey('textShadowBlur')) {
      widget.settings.textfxSettings.textShadowBlur =
          presetData['textShadowBlur'];
    }
    if (presetData.containsKey('textShadowOffsetX')) {
      widget.settings.textfxSettings.textShadowOffsetX =
          presetData['textShadowOffsetX'];
    }
    if (presetData.containsKey('textShadowOffsetY')) {
      widget.settings.textfxSettings.textShadowOffsetY =
          presetData['textShadowOffsetY'];
    }
    if (presetData.containsKey('textShadowOpacity')) {
      widget.settings.textfxSettings.textShadowOpacity =
          presetData['textShadowOpacity'];
    }
    if (presetData.containsKey('textShadowColor')) {
      widget.settings.textfxSettings.textShadowColor = Color(
        presetData['textShadowColor'],
      );
    }

    // Glow settings
    if (presetData.containsKey('textGlowEnabled')) {
      widget.settings.textfxSettings.textGlowEnabled =
          presetData['textGlowEnabled'];
    }
    if (presetData.containsKey('textGlowBlur')) {
      widget.settings.textfxSettings.textGlowBlur = presetData['textGlowBlur'];
    }
    if (presetData.containsKey('textGlowOpacity')) {
      widget.settings.textfxSettings.textGlowOpacity =
          presetData['textGlowOpacity'];
    }
    if (presetData.containsKey('textGlowColor')) {
      widget.settings.textfxSettings.textGlowColor = Color(
        presetData['textGlowColor'],
      );
    }

    // Outline settings
    if (presetData.containsKey('textOutlineEnabled')) {
      widget.settings.textfxSettings.textOutlineEnabled =
          presetData['textOutlineEnabled'];
    }
    if (presetData.containsKey('textOutlineWidth')) {
      widget.settings.textfxSettings.textOutlineWidth =
          presetData['textOutlineWidth'];
    }
    if (presetData.containsKey('textOutlineColor')) {
      widget.settings.textfxSettings.textOutlineColor = Color(
        presetData['textOutlineColor'],
      );
    }

    // Metal settings
    if (presetData.containsKey('textMetalEnabled')) {
      widget.settings.textfxSettings.textMetalEnabled =
          presetData['textMetalEnabled'];
    }
    if (presetData.containsKey('textMetalShine')) {
      widget.settings.textfxSettings.textMetalShine =
          presetData['textMetalShine'];
    }
    if (presetData.containsKey('textMetalBaseColor')) {
      widget.settings.textfxSettings.textMetalBaseColor = Color(
        presetData['textMetalBaseColor'],
      );
    }
    if (presetData.containsKey('textMetalShineColor')) {
      widget.settings.textfxSettings.textMetalShineColor = Color(
        presetData['textMetalShineColor'],
      );
    }

    // Glass settings
    if (presetData.containsKey('textGlassEnabled')) {
      widget.settings.textfxSettings.textGlassEnabled =
          presetData['textGlassEnabled'];
    }
    if (presetData.containsKey('textGlassOpacity')) {
      widget.settings.textfxSettings.textGlassOpacity =
          presetData['textGlassOpacity'];
    }
    if (presetData.containsKey('textGlassBlur')) {
      widget.settings.textfxSettings.textGlassBlur =
          presetData['textGlassBlur'];
    }
    if (presetData.containsKey('textGlassRefraction')) {
      widget.settings.textfxSettings.textGlassRefraction =
          presetData['textGlassRefraction'];
    }
    if (presetData.containsKey('textGlassColor')) {
      widget.settings.textfxSettings.textGlassColor = Color(
        presetData['textGlassColor'],
      );
    }

    // Neon settings
    if (presetData.containsKey('textNeonEnabled')) {
      widget.settings.textfxSettings.textNeonEnabled =
          presetData['textNeonEnabled'];
    }
    if (presetData.containsKey('textNeonIntensity')) {
      widget.settings.textfxSettings.textNeonIntensity =
          presetData['textNeonIntensity'];
    }
    if (presetData.containsKey('textNeonWidth')) {
      widget.settings.textfxSettings.textNeonWidth =
          presetData['textNeonWidth'];
    }
    if (presetData.containsKey('textNeonColor')) {
      widget.settings.textfxSettings.textNeonColor = Color(
        presetData['textNeonColor'],
      );
    }
    if (presetData.containsKey('textNeonOuterColor')) {
      widget.settings.textfxSettings.textNeonOuterColor = Color(
        presetData['textNeonOuterColor'],
      );
    }

    // Update the UI with the new settings
    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'textfxEnabled': widget.settings.textfxSettings.textfxEnabled,

      // Shadow settings
      'textShadowEnabled': widget.settings.textfxSettings.textShadowEnabled,
      'textShadowBlur': widget.settings.textfxSettings.textShadowBlur,
      'textShadowOffsetX': widget.settings.textfxSettings.textShadowOffsetX,
      'textShadowOffsetY': widget.settings.textfxSettings.textShadowOffsetY,
      'textShadowOpacity': widget.settings.textfxSettings.textShadowOpacity,
      'textShadowColor': widget.settings.textfxSettings.textShadowColor.value,

      // Glow settings
      'textGlowEnabled': widget.settings.textfxSettings.textGlowEnabled,
      'textGlowBlur': widget.settings.textfxSettings.textGlowBlur,
      'textGlowOpacity': widget.settings.textfxSettings.textGlowOpacity,
      'textGlowColor': widget.settings.textfxSettings.textGlowColor.value,

      // Outline settings
      'textOutlineEnabled': widget.settings.textfxSettings.textOutlineEnabled,
      'textOutlineWidth': widget.settings.textfxSettings.textOutlineWidth,
      'textOutlineColor': widget.settings.textfxSettings.textOutlineColor.value,

      // Metal settings
      'textMetalEnabled': widget.settings.textfxSettings.textMetalEnabled,
      'textMetalShine': widget.settings.textfxSettings.textMetalShine,
      'textMetalBaseColor':
          widget.settings.textfxSettings.textMetalBaseColor.value,
      'textMetalShineColor':
          widget.settings.textfxSettings.textMetalShineColor.value,

      // Glass settings
      'textGlassEnabled': widget.settings.textfxSettings.textGlassEnabled,
      'textGlassOpacity': widget.settings.textfxSettings.textGlassOpacity,
      'textGlassBlur': widget.settings.textfxSettings.textGlassBlur,
      'textGlassRefraction': widget.settings.textfxSettings.textGlassRefraction,
      'textGlassColor': widget.settings.textfxSettings.textGlassColor.value,

      // Neon settings
      'textNeonEnabled': widget.settings.textfxSettings.textNeonEnabled,
      'textNeonIntensity': widget.settings.textfxSettings.textNeonIntensity,
      'textNeonWidth': widget.settings.textfxSettings.textNeonWidth,
      'textNeonColor': widget.settings.textfxSettings.textNeonColor.value,
      'textNeonOuterColor':
          widget.settings.textfxSettings.textNeonOuterColor.value,
    };

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
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

  Widget _buildShadowTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shadow toggle
            _buildLabeledSwitch(
              'Enable Shadow',
              widget.settings.textfxSettings.textShadowEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textShadowEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
                _log('Shadow effect toggled: $value');
              },
            ),
            const SizedBox(height: 16),

            // Shadow properties (only visible when enabled)
            if (widget.settings.textfxSettings.textShadowEnabled) ...[
              // Shadow blur
              _buildLabeledSlider(
                'Blur',
                widget.settings.textfxSettings.textShadowBlur,
                0.0,
                20.0,
                20,
                '${widget.settings.textfxSettings.textShadowBlur.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textShadowBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // X offset
              _buildLabeledSlider(
                'X Offset',
                widget.settings.textfxSettings.textShadowOffsetX,
                -10.0,
                10.0,
                20,
                '${widget.settings.textfxSettings.textShadowOffsetX.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textShadowOffsetX = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Y offset
              _buildLabeledSlider(
                'Y Offset',
                widget.settings.textfxSettings.textShadowOffsetY,
                -10.0,
                10.0,
                20,
                '${widget.settings.textfxSettings.textShadowOffsetY.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textShadowOffsetY = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Opacity
              _buildLabeledSlider(
                'Opacity',
                widget.settings.textfxSettings.textShadowOpacity,
                0.0,
                1.0,
                10,
                '${(widget.settings.textfxSettings.textShadowOpacity * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textShadowOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Add extra space to accommodate the color picker expansion
              _buildColorPicker(
                'Shadow Color',
                widget.settings.textfxSettings.textShadowColor,
                (color) {
                  _log('Shadow color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textShadowColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGlowTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glow toggle
            _buildLabeledSwitch(
              'Enable Glow',
              widget.settings.textfxSettings.textGlowEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textGlowEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
                _log('Glow effect toggled: $value');
              },
            ),
            const SizedBox(height: 16),

            // Glow properties (only visible when enabled)
            if (widget.settings.textfxSettings.textGlowEnabled) ...[
              // Glow blur
              _buildLabeledSlider(
                'Glow Radius',
                widget.settings.textfxSettings.textGlowBlur,
                0.0,
                20.0,
                20,
                '${widget.settings.textfxSettings.textGlowBlur.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlowBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Opacity
              _buildLabeledSlider(
                'Opacity',
                widget.settings.textfxSettings.textGlowOpacity,
                0.0,
                1.0,
                10,
                '${(widget.settings.textfxSettings.textGlowOpacity * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlowOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Color picker
              _buildColorPicker(
                'Glow Color',
                widget.settings.textfxSettings.textGlowColor,
                (color) {
                  _log('Glow color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlowColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Cache for tracking slider value changes to reduce logs
  final Map<String, double> _sliderValues = {};

  Widget _buildLabeledSlider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    String displayValue,
    Function(double) onChanged,
  ) {
    // Generate a unique key for this slider
    final String sliderKey = '$label-${widget.settings.hashCode}';

    // Only log significant changes
    final logChange = (double newValue) {
      final hasChanged =
          !_sliderValues.containsKey(sliderKey) ||
          (_sliderValues[sliderKey]! - newValue).abs() > 0.05;

      if (hasChanged) {
        _log(
          '$label slider changed to: ${newValue.toStringAsFixed(2)}',
          level: LogLevel.debug,
        );
        _sliderValues[sliderKey] = newValue;
      }

      onChanged(newValue);
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(color: widget.sliderColor)),
            const Spacer(),
            Text(displayValue, style: TextStyle(color: widget.sliderColor)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: widget.sliderColor,
          onChanged: logChange,
        ),
      ],
    );
  }

  Widget _buildLabeledSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: widget.sliderColor)),
        const Spacer(),
        Switch(
          value: value,
          activeColor: widget.sliderColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Keep track of last color for each color picker to reduce logs
  final Map<String, Color> _lastColors = {};

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onColorChanged,
  ) {
    // Create a unique key for each color picker to ensure proper rebuilding
    final uniqueKey = ValueKey('${label}_${color.value}');

    // Check if color has significantly changed to log
    final bool isNewColor =
        !_lastColors.containsKey(label) || _lastColors[label] != color;
    if (isNewColor) {
      _log(
        '$label color: 0x${color.value.toRadixString(16).padLeft(8, '0')}',
        level: LogLevel.debug,
      );
      _lastColors[label] = color;
    }

    return ColorPicker(
      key: uniqueKey,
      label: label,
      currentColor: color,
      onColorChanged: (newColor) {
        _log('$label color changed', level: LogLevel.debug);

        // Apply color change to the settings
        onColorChanged(newColor);

        // Save the new color to avoid redundant logs
        _lastColors[label] = newColor;
      },
      textColor: widget.sliderColor,
    );
  }

  // Helper to ensure text FX changes don't inadvertently affect color overlay
  void _ensureTextFxChangesOnly(ShaderSettings settings) {
    // When using color pickers in TextFx panel, make sure we don't accidentally
    // enable the color overlay effect. We check if color settings were previously
    // disabled, and preserve that state to avoid unintended overlay effects.
    if (!settings.colorEnabled) {
      // If color effect was disabled, ensure it stays that way
      settings.colorEnabled = false;
      _log('Keeping color effects disabled', level: LogLevel.debug);
    } else {
      // If color was enabled, we need to make sure the overlay settings don't
      // get inadvertently triggered by color changes in text effects

      // Store the current state of overlay settings
      final bool wasOverlayActive =
          settings.colorSettings.overlayOpacity > 0 &&
          settings.colorSettings.overlayIntensity > 0;

      // If overlay wasn't already active, ensure it stays inactive
      if (!wasOverlayActive) {
        _log('Preserving inactive overlay state', level: LogLevel.debug);
        // Set overlay intensity/opacity to 0 to prevent inadvertent overlay effects
        // This is especially important when switching between tabs
        settings.colorSettings.overlayOpacity = 0.0;
        settings.colorSettings.overlayIntensity = 0.0;
      } else {
        _log(
          'Overlay was already active, leaving settings as is',
          level: LogLevel.debug,
        );
      }
    }
  }

  // The rest of the tab building methods (outlineTab, metalTab, glassTab, neonTab)
  // follow the same pattern and should be changed similarly.
  // For brevity, I'm only showing the shadow and glow tabs as examples.

  Widget _buildOutlineTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outline toggle
            _buildLabeledSwitch(
              'Enable Outline',
              widget.settings.textfxSettings.textOutlineEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textOutlineEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
                _log('Outline effect toggled: $value');
              },
            ),
            const SizedBox(height: 16),

            // Outline properties (only visible when enabled)
            if (widget.settings.textfxSettings.textOutlineEnabled) ...[
              // Outline width
              _buildLabeledSlider(
                'Width',
                widget.settings.textfxSettings.textOutlineWidth,
                0.5,
                5.0,
                9,
                '${widget.settings.textfxSettings.textOutlineWidth.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textOutlineWidth = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Color picker
              _buildColorPicker(
                'Outline Color',
                widget.settings.textfxSettings.textOutlineColor,
                (color) {
                  _log('Outline color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textOutlineColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metal toggle
            _buildLabeledSwitch(
              'Enable Metal Effect',
              widget.settings.textfxSettings.textMetalEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textMetalEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
                _log('Metal effect toggled: $value');
              },
            ),
            const SizedBox(height: 16),

            // Metal properties (only visible when enabled)
            if (widget.settings.textfxSettings.textMetalEnabled) ...[
              // Shine intensity slider
              _buildLabeledSlider(
                'Shine Intensity',
                widget.settings.textfxSettings.textMetalShine,
                0.0,
                1.0,
                10,
                '${(widget.settings.textfxSettings.textMetalShine * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textMetalShine = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Preset buttons for common metal types
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetalPresetButton(
                      'Gold',
                      Colors.amber[700]!,
                      Colors.yellow[300]!,
                    ),
                    _buildMetalPresetButton(
                      'Silver',
                      Colors.grey[400]!,
                      Colors.white,
                    ),
                    _buildMetalPresetButton(
                      'Bronze',
                      Color(0xFFA97142),
                      Color(0xFFE3A857),
                    ),
                    _buildMetalPresetButton(
                      'Chrome',
                      Colors.grey[300]!,
                      Colors.white,
                    ),
                  ],
                ),
              ),

              // Base color picker
              _buildColorPicker(
                'Base Color',
                widget.settings.textfxSettings.textMetalBaseColor,
                (color) {
                  _log('Metal base color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textMetalBaseColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 8),

              // Shine color picker
              _buildColorPicker(
                'Shine Color',
                widget.settings.textfxSettings.textMetalShineColor,
                (color) {
                  _log('Metal shine color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textMetalShineColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetalPresetButton(
    String label,
    Color baseColor,
    Color shineColor,
  ) {
    return InkWell(
      onTap: () {
        _log('Metal preset selected: $label', level: LogLevel.debug);
        final updatedSettings = widget.settings;
        updatedSettings.textfxSettings.textMetalBaseColor = baseColor;
        updatedSettings.textfxSettings.textMetalShineColor = shineColor;
        updatedSettings.textfxSettings.textMetalShine =
            0.7; // Good default for presets
        // Ensure this change only affects text effects, not color overlay
        _ensureTextFxChangesOnly(updatedSettings);
        widget.onSettingsChanged(updatedSettings);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withOpacity(0.7),
              shineColor.withOpacity(0.9),
              baseColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glass toggle
            _buildLabeledSwitch(
              'Enable Glass Effect',
              widget.settings.textfxSettings.textGlassEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textGlassEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
                _log('Glass effect toggled: $value');
              },
            ),
            const SizedBox(height: 16),

            // Glass properties (only visible when enabled)
            if (widget.settings.textfxSettings.textGlassEnabled) ...[
              // Opacity slider
              _buildLabeledSlider(
                'Opacity',
                widget.settings.textfxSettings.textGlassOpacity,
                0.0,
                1.0,
                10,
                '${(widget.settings.textfxSettings.textGlassOpacity * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlassOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Blur slider
              _buildLabeledSlider(
                'Blur Amount',
                widget.settings.textfxSettings.textGlassBlur,
                0.0,
                20.0,
                20,
                '${widget.settings.textfxSettings.textGlassBlur.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlassBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Refraction slider
              _buildLabeledSlider(
                'Refraction',
                widget.settings.textfxSettings.textGlassRefraction,
                0.0,
                2.0,
                20,
                '${widget.settings.textfxSettings.textGlassRefraction.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlassRefraction = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Glass color picker
              _buildColorPicker(
                'Tint Color',
                widget.settings.textfxSettings.textGlassColor,
                (color) {
                  _log('Glass tint color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlassColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNeonTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Neon toggle
            _buildLabeledSwitch(
              'Enable Neon Effect',
              widget.settings.textfxSettings.textNeonEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textNeonEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
                _log('Neon effect toggled: $value');
              },
            ),
            const SizedBox(height: 16),

            // Neon properties (only visible when enabled)
            if (widget.settings.textfxSettings.textNeonEnabled) ...[
              // Intensity slider
              _buildLabeledSlider(
                'Intensity',
                widget.settings.textfxSettings.textNeonIntensity,
                0.1,
                2.0,
                19,
                '${widget.settings.textfxSettings.textNeonIntensity.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textNeonIntensity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Width slider
              _buildLabeledSlider(
                'Tube Width',
                widget.settings.textfxSettings.textNeonWidth,
                0.005,
                0.05,
                9,
                '${(widget.settings.textfxSettings.textNeonWidth * 100).toStringAsFixed(1)}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textNeonWidth = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Neon color picker
              _buildColorPicker(
                'Neon Color',
                widget.settings.textfxSettings.textNeonColor,
                (color) {
                  _log('Neon color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textNeonColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 8),

              // Outer glow color picker
              _buildColorPicker(
                'Outer Glow',
                widget.settings.textfxSettings.textNeonOuterColor,
                (color) {
                  _log('Neon outer glow color changed', level: LogLevel.debug);
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textNeonOuterColor = color;
                  // Ensure this change only affects text effects, not color overlay
                  _ensureTextFxChangesOnly(updatedSettings);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
