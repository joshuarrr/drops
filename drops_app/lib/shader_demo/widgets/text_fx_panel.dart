import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
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

  // Track whether animation is enabled
  bool _animationEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _animationEnabled = widget.settings.textfxSettings.textfxAnimated;
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
              final updatedSettings = widget.settings;
              updatedSettings.textfxSettings.applyShaderEffectsToText = value;
              widget.onSettingsChanged(updatedSettings);
              if (mounted) setState(() {});
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
                  print(
                    'Shadow color picker callback triggered with color: ${color.value.toRadixString(16)}',
                  );
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textShadowColor = color;
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
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlowColor = color;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

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
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textOutlineColor = color;
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
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textMetalBaseColor = color;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 8),

              // Shine color picker
              _buildColorPicker(
                'Shine Color',
                widget.settings.textfxSettings.textMetalShineColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textMetalShineColor = color;
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
        final updatedSettings = widget.settings;
        updatedSettings.textfxSettings.textMetalBaseColor = baseColor;
        updatedSettings.textfxSettings.textMetalShineColor = shineColor;
        updatedSettings.textfxSettings.textMetalShine =
            0.7; // Good default for presets
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
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlassColor = color;
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
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textNeonColor = color;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 8),

              // Outer glow color picker
              _buildColorPicker(
                'Outer Glow',
                widget.settings.textfxSettings.textNeonOuterColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textNeonOuterColor = color;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper widgets to simplify the code

  Widget _buildLabeledSlider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    String displayValue,
    Function(double) onChanged,
  ) {
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
          onChanged: onChanged,
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

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onColorChanged,
  ) {
    // Create a unique key for each color picker to ensure proper rebuilding
    print(
      'Building ColorPicker: $label with color: ${color.value.toRadixString(16)}',
    );
    final uniqueKey = ValueKey('${label}_${color.value}');
    print('ColorPicker key: $uniqueKey');

    return ColorPicker(
      key: uniqueKey,
      label: label,
      currentColor: color,
      onColorChanged: (newColor) {
        print(
          'Color changed: $label from ${color.value.toRadixString(16)} to ${newColor.value.toRadixString(16)}',
        );
        // Apply color change to the settings
        onColorChanged(newColor);

        // Force UI refresh using setState
        setState(() {
          print('Refreshing TextFxPanel state after color change for: $label');
        });
      },
      textColor: widget.sliderColor,
    );
  }
}
