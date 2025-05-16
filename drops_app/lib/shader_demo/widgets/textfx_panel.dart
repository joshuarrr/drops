import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import 'color_picker.dart';
import 'labeled_slider.dart';
import 'labeled_switch.dart';
import 'panel_header.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
        PanelHeader(
          title: 'Text Effects',
          showAnimToggle: false,
          animationEnabled: _animationEnabled,
          onAnimationToggled: (value) {
            setState(() {
              _animationEnabled = value;

              // Create a new settings object with the updated animation flag
              final updatedSettings = widget.settings;
              updatedSettings.textfxSettings.textfxAnimated = value;

              // Notify parent of the change
              widget.onSettingsChanged(updatedSettings);
            });
          },
        ),

        // Tabs for different effect types
        TabBar(
          controller: _tabController,
          labelColor: widget.sliderColor,
          unselectedLabelColor: widget.sliderColor.withOpacity(0.5),
          indicatorColor: widget.sliderColor,
          tabs: const [
            Tab(text: 'Shadow'),
            Tab(text: 'Glow'),
            Tab(text: 'Outline'),
          ],
        ),

        // Tab content
        SizedBox(
          height: 250, // Fixed height for the tab content
          child: TabBarView(
            controller: _tabController,
            children: [_buildShadowTab(), _buildGlowTab(), _buildOutlineTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildShadowTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Shadow toggle
          LabeledSwitch(
            label: 'Enable Shadow',
            value: widget.settings.textfxSettings.textShadowEnabled,
            onChanged: (value) {
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
            LabeledSlider(
              label: 'Blur',
              value: widget.settings.textfxSettings.textShadowBlur,
              min: 0.0,
              max: 20.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textfxSettings.textShadowBlur.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textShadowBlur = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // X offset
            LabeledSlider(
              label: 'X Offset',
              value: widget.settings.textfxSettings.textShadowOffsetX,
              min: -10.0,
              max: 10.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textfxSettings.textShadowOffsetX.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textShadowOffsetX = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Y offset
            LabeledSlider(
              label: 'Y Offset',
              value: widget.settings.textfxSettings.textShadowOffsetY,
              min: -10.0,
              max: 10.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textfxSettings.textShadowOffsetY.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textShadowOffsetY = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Opacity
            LabeledSlider(
              label: 'Opacity',
              value: widget.settings.textfxSettings.textShadowOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              displayValue:
                  '${(widget.settings.textfxSettings.textShadowOpacity * 100).round()}%',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textShadowOpacity = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Color picker
            Row(
              children: [
                Text(
                  'Shadow Color',
                  style: TextStyle(color: widget.sliderColor),
                ),
                const Spacer(),
                ColorPickerButton(
                  color: widget.settings.textfxSettings.textShadowColor,
                  onColorChanged: (color) {
                    final updatedSettings = widget.settings;
                    updatedSettings.textfxSettings.textShadowColor = color;
                    widget.onSettingsChanged(updatedSettings);
                  },
                ),
              ],
            ),
          ],
        ],
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
            LabeledSwitch(
              label: 'Enable Glow',
              value: widget.settings.textfxSettings.textGlowEnabled,
              onChanged: (value) {
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
              LabeledSlider(
                label: 'Glow Radius',
                value: widget.settings.textfxSettings.textGlowBlur,
                min: 0.0,
                max: 50.0,
                divisions: 50,
                displayValue:
                    '${widget.settings.textfxSettings.textGlowBlur.toStringAsFixed(1)}',
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlowBlur = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),

              // Opacity
              LabeledSlider(
                label: 'Opacity',
                value: widget.settings.textfxSettings.textGlowOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                displayValue:
                    '${(widget.settings.textfxSettings.textGlowOpacity * 100).round()}%',
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.textfxSettings.textGlowOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),

              // Color picker
              Row(
                children: [
                  Text(
                    'Glow Color',
                    style: TextStyle(color: widget.sliderColor),
                  ),
                  const Spacer(),
                  ColorPickerButton(
                    color: widget.settings.textfxSettings.textGlowColor,
                    onColorChanged: (color) {
                      final updatedSettings = widget.settings;
                      updatedSettings.textfxSettings.textGlowColor = color;
                      widget.onSettingsChanged(updatedSettings);
                    },
                  ),
                ],
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
      child: Column(
        children: [
          // Outline toggle
          LabeledSwitch(
            label: 'Enable Outline',
            value: widget.settings.textfxSettings.textOutlineEnabled,
            onChanged: (value) {
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
            LabeledSlider(
              label: 'Width',
              value: widget.settings.textfxSettings.textOutlineWidth,
              min: 0.5,
              max: 15.0,
              divisions: 29,
              displayValue:
                  '${widget.settings.textfxSettings.textOutlineWidth.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.textOutlineWidth = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Color picker
            Row(
              children: [
                Text(
                  'Outline Color',
                  style: TextStyle(color: widget.sliderColor),
                ),
                const Spacer(),
                ColorPickerButton(
                  color: widget.settings.textfxSettings.textOutlineColor,
                  onColorChanged: (color) {
                    final updatedSettings = widget.settings;
                    updatedSettings.textfxSettings.textOutlineColor = color;
                    widget.onSettingsChanged(updatedSettings);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
