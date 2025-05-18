import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import '../controllers/effect_controller.dart';
import 'color_picker.dart';

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

    // Log important changes that might affect the overlay
    if (oldWidget.settings.textfxSettings.applyShaderEffectsToText !=
        widget.settings.textfxSettings.applyShaderEffectsToText) {
      _log(
        'Apply Shaders to Text changed from ${oldWidget.settings.textfxSettings.applyShaderEffectsToText} to ${widget.settings.textfxSettings.applyShaderEffectsToText}',
      );
    }

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
        // Panel header with animation toggle
        _buildPanelHeader(),

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

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Text Effects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.sliderColor,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          // Add toggle for applying shaders to text as the first control
          _buildLabeledSwitch(
            'Apply Shaders to Text',
            widget.settings.textfxSettings.applyShaderEffectsToText,
            (value) {
              _log('Apply Shaders to Text toggle changed to: $value');

              final updatedSettings = widget.settings;
              updatedSettings.textfxSettings.applyShaderEffectsToText = value;

              // DIAGNOSTIC: Check if color settings are inadvertently modified when this toggle changes
              // We'll create a snapshot of the settings before the callback
              final bool colorEnabledBefore = updatedSettings.colorEnabled;
              final double overlayIntensityBefore =
                  updatedSettings.colorSettings.overlayIntensity;
              final double overlayOpacityBefore =
                  updatedSettings.colorSettings.overlayOpacity;

              widget.onSettingsChanged(updatedSettings);

              // Check if color settings changed unexpectedly after the callback
              if (mounted) {
                setState(() {
                  // Check if settings changed unexpectedly
                  if (colorEnabledBefore != widget.settings.colorEnabled) {
                    _log(
                      'WARNING: Color enabled changed unexpectedly: $colorEnabledBefore -> ${widget.settings.colorEnabled}',
                      level: LogLevel.warning,
                    );
                  }
                  if (overlayIntensityBefore !=
                      widget.settings.colorSettings.overlayIntensity) {
                    _log(
                      'WARNING: Overlay intensity changed unexpectedly: $overlayIntensityBefore -> ${widget.settings.colorSettings.overlayIntensity}',
                      level: LogLevel.warning,
                    );
                  }
                  if (overlayOpacityBefore !=
                      widget.settings.colorSettings.overlayOpacity) {
                    _log(
                      'WARNING: Overlay opacity changed unexpectedly: $overlayOpacityBefore -> ${widget.settings.colorSettings.overlayOpacity}',
                      level: LogLevel.warning,
                    );
                  }
                });
              }
            },
          ),
          const SizedBox(height: 8),
          // Add a divider to separate from other controls
          Divider(color: widget.sliderColor.withOpacity(0.3)),
        ],
      ),
    );
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
