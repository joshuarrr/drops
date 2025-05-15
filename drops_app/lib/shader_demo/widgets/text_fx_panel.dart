import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../models/shader_effect.dart';

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
    _animationEnabled = widget.settings.textfxAnimated;
  }

  @override
  void didUpdateWidget(TextFxPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation state when settings change
    if (oldWidget.settings.textfxAnimated != widget.settings.textfxAnimated) {
      setState(() {
        _animationEnabled = widget.settings.textfxAnimated;
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
          height: 250, // Fixed height for the tab content
          child: TabBarView(
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
      child: Row(
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
          Row(
            children: [
              Text(
                'Animate',
                style: TextStyle(fontSize: 14, color: widget.sliderColor),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _animationEnabled,
                activeColor: widget.sliderColor,
                onChanged: (value) {
                  setState(() {
                    _animationEnabled = value;

                    // Update settings
                    final updatedSettings = widget.settings;
                    updatedSettings.textfxAnimated = value;

                    // Notify parent
                    widget.onSettingsChanged(updatedSettings);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShadowTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Shadow toggle
            _buildLabeledSwitch(
              'Enable Shadow',
              widget.settings.textShadowEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textShadowEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxEnabled) {
                  updatedSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
              },
            ),
            const SizedBox(height: 16),

            // Shadow properties (only visible when enabled)
            if (widget.settings.textShadowEnabled) ...[
              // Shadow blur
              _buildLabeledSlider(
                'Blur',
                widget.settings.textShadowBlur,
                0.0,
                20.0,
                20,
                '${widget.settings.textShadowBlur.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textShadowBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // X offset
              _buildLabeledSlider(
                'X Offset',
                widget.settings.textShadowOffsetX,
                -10.0,
                10.0,
                20,
                '${widget.settings.textShadowOffsetX.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textShadowOffsetX = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Y offset
              _buildLabeledSlider(
                'Y Offset',
                widget.settings.textShadowOffsetY,
                -10.0,
                10.0,
                20,
                '${widget.settings.textShadowOffsetY.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textShadowOffsetY = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Opacity
              _buildLabeledSlider(
                'Opacity',
                widget.settings.textShadowOpacity,
                0.0,
                1.0,
                10,
                '${(widget.settings.textShadowOpacity * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textShadowOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Color picker
              _buildColorPicker(
                'Shadow Color',
                widget.settings.textShadowColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textShadowColor = color;
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
        child: Column(
          children: [
            // Glow toggle
            _buildLabeledSwitch('Enable Glow', widget.settings.textGlowEnabled, (
              value,
            ) {
              final updatedSettings = widget.settings;
              updatedSettings.textGlowEnabled = value;
              // Make sure text effects are enabled when enabling a specific effect
              if (value && !updatedSettings.textfxEnabled) {
                updatedSettings.textfxEnabled = true;
              }
              widget.onSettingsChanged(updatedSettings);
            }),
            const SizedBox(height: 16),

            // Glow properties (only visible when enabled)
            if (widget.settings.textGlowEnabled) ...[
              // Glow blur
              _buildLabeledSlider(
                'Glow Radius',
                widget.settings.textGlowBlur,
                0.0,
                20.0,
                20,
                '${widget.settings.textGlowBlur.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textGlowBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Opacity
              _buildLabeledSlider(
                'Opacity',
                widget.settings.textGlowOpacity,
                0.0,
                1.0,
                10,
                '${(widget.settings.textGlowOpacity * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textGlowOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Color picker
              _buildColorPicker('Glow Color', widget.settings.textGlowColor, (
                color,
              ) {
                final updatedSettings = widget.settings;
                updatedSettings.textGlowColor = color;
                widget.onSettingsChanged(updatedSettings);
              }),
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
        child: Column(
          children: [
            // Outline toggle
            _buildLabeledSwitch(
              'Enable Outline',
              widget.settings.textOutlineEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textOutlineEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxEnabled) {
                  updatedSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
              },
            ),
            const SizedBox(height: 16),

            // Outline properties (only visible when enabled)
            if (widget.settings.textOutlineEnabled) ...[
              // Outline width
              _buildLabeledSlider(
                'Width',
                widget.settings.textOutlineWidth,
                0.5,
                5.0,
                9,
                '${widget.settings.textOutlineWidth.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textOutlineWidth = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Color picker
              _buildColorPicker(
                'Outline Color',
                widget.settings.textOutlineColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textOutlineColor = color;
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
        child: Column(
          children: [
            // Metal toggle
            _buildLabeledSwitch(
              'Enable Metal Effect',
              widget.settings.textMetalEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textMetalEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxEnabled) {
                  updatedSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
              },
            ),
            const SizedBox(height: 16),

            // Metal properties (only visible when enabled)
            if (widget.settings.textMetalEnabled) ...[
              // Shine intensity slider
              _buildLabeledSlider(
                'Shine Intensity',
                widget.settings.textMetalShine,
                0.0,
                1.0,
                10,
                '${(widget.settings.textMetalShine * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textMetalShine = value;
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
                widget.settings.textMetalBaseColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textMetalBaseColor = color;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 8),

              // Shine color picker
              _buildColorPicker(
                'Shine Color',
                widget.settings.textMetalShineColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textMetalShineColor = color;
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
        updatedSettings.textMetalBaseColor = baseColor;
        updatedSettings.textMetalShineColor = shineColor;
        updatedSettings.textMetalShine = 0.7; // Good default for presets
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
        child: Column(
          children: [
            // Glass toggle
            _buildLabeledSwitch(
              'Enable Glass Effect',
              widget.settings.textGlassEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textGlassEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxEnabled) {
                  updatedSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
              },
            ),
            const SizedBox(height: 16),

            // Glass properties (only visible when enabled)
            if (widget.settings.textGlassEnabled) ...[
              // Opacity slider
              _buildLabeledSlider(
                'Opacity',
                widget.settings.textGlassOpacity,
                0.0,
                1.0,
                10,
                '${(widget.settings.textGlassOpacity * 100).round()}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textGlassOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Blur slider
              _buildLabeledSlider(
                'Blur Amount',
                widget.settings.textGlassBlur,
                0.0,
                20.0,
                20,
                '${widget.settings.textGlassBlur.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textGlassBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Refraction slider
              _buildLabeledSlider(
                'Refraction',
                widget.settings.textGlassRefraction,
                0.0,
                2.0,
                20,
                '${widget.settings.textGlassRefraction.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textGlassRefraction = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Glass color picker
              _buildColorPicker('Tint Color', widget.settings.textGlassColor, (
                color,
              ) {
                final updatedSettings = widget.settings;
                updatedSettings.textGlassColor = color;
                widget.onSettingsChanged(updatedSettings);
              }),
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
        child: Column(
          children: [
            // Neon toggle
            _buildLabeledSwitch(
              'Enable Neon Effect',
              widget.settings.textNeonEnabled,
              (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textNeonEnabled = value;
                // Make sure text effects are enabled when enabling a specific effect
                if (value && !updatedSettings.textfxEnabled) {
                  updatedSettings.textfxEnabled = true;
                }
                widget.onSettingsChanged(updatedSettings);
              },
            ),
            const SizedBox(height: 16),

            // Neon properties (only visible when enabled)
            if (widget.settings.textNeonEnabled) ...[
              // Intensity slider
              _buildLabeledSlider(
                'Intensity',
                widget.settings.textNeonIntensity,
                0.1,
                2.0,
                19,
                '${widget.settings.textNeonIntensity.toStringAsFixed(1)}',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textNeonIntensity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Width slider
              _buildLabeledSlider(
                'Tube Width',
                widget.settings.textNeonWidth,
                0.005,
                0.05,
                9,
                '${(widget.settings.textNeonWidth * 100).toStringAsFixed(1)}%',
                (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textNeonWidth = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              // Neon color picker
              _buildColorPicker('Neon Color', widget.settings.textNeonColor, (
                color,
              ) {
                final updatedSettings = widget.settings;
                updatedSettings.textNeonColor = color;
                widget.onSettingsChanged(updatedSettings);
              }),

              const SizedBox(height: 8),

              // Outer glow color picker
              _buildColorPicker(
                'Outer Glow',
                widget.settings.textNeonOuterColor,
                (color) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textNeonOuterColor = color;
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
    return Row(
      children: [
        Text(label, style: TextStyle(color: widget.sliderColor)),
        const Spacer(),
        InkWell(
          onTap: () {
            _showColorPicker(color, onColorChanged);
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(Color initialColor, Function(Color) onColorSelected) {
    // This is a stub - in a real implementation, you would display a color picker dialog
    // Since we don't have the actual color picker implementation here, we'll simulate it
    // by just cycling through some preset colors
    final List<Color> presetColors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];

    int currentIndex = presetColors.indexOf(initialColor);
    if (currentIndex == -1) currentIndex = 0;

    // Just move to the next color in the list for demo purposes
    int nextIndex = (currentIndex + 1) % presetColors.length;
    onColorSelected(presetColors[nextIndex]);
  }
}
