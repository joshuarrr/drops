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
        PanelHeader(
          title: 'Text Effects',
          showAnimToggle: true,
          animationEnabled: _animationEnabled,
          onAnimationToggled: (value) {
            setState(() {
              _animationEnabled = value;

              // Create a new settings object with the updated animation flag
              final updatedSettings = widget.settings;
              updatedSettings.textfxAnimated = value;

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
            value: widget.settings.textShadowEnabled,
            onChanged: (value) {
              final updatedSettings = widget.settings;
              updatedSettings.textShadowEnabled = value;
              widget.onSettingsChanged(updatedSettings);
            },
          ),
          const SizedBox(height: 16),

          // Shadow properties (only visible when enabled)
          if (widget.settings.textShadowEnabled) ...[
            // Shadow blur
            LabeledSlider(
              label: 'Blur',
              value: widget.settings.textShadowBlur,
              min: 0.0,
              max: 20.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textShadowBlur.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textShadowBlur = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // X offset
            LabeledSlider(
              label: 'X Offset',
              value: widget.settings.textShadowOffsetX,
              min: -10.0,
              max: 10.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textShadowOffsetX.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textShadowOffsetX = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Y offset
            LabeledSlider(
              label: 'Y Offset',
              value: widget.settings.textShadowOffsetY,
              min: -10.0,
              max: 10.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textShadowOffsetY.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textShadowOffsetY = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Opacity
            LabeledSlider(
              label: 'Opacity',
              value: widget.settings.textShadowOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              displayValue:
                  '${(widget.settings.textShadowOpacity * 100).round()}%',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textShadowOpacity = value;
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
                  color: widget.settings.textShadowColor,
                  onColorChanged: (color) {
                    final updatedSettings = widget.settings;
                    updatedSettings.textShadowColor = color;
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
      child: Column(
        children: [
          // Glow toggle
          LabeledSwitch(
            label: 'Enable Glow',
            value: widget.settings.textGlowEnabled,
            onChanged: (value) {
              final updatedSettings = widget.settings;
              updatedSettings.textGlowEnabled = value;
              widget.onSettingsChanged(updatedSettings);
            },
          ),
          const SizedBox(height: 16),

          // Glow properties (only visible when enabled)
          if (widget.settings.textGlowEnabled) ...[
            // Glow blur
            LabeledSlider(
              label: 'Glow Radius',
              value: widget.settings.textGlowBlur,
              min: 0.0,
              max: 20.0,
              divisions: 20,
              displayValue:
                  '${widget.settings.textGlowBlur.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textGlowBlur = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Opacity
            LabeledSlider(
              label: 'Opacity',
              value: widget.settings.textGlowOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              displayValue:
                  '${(widget.settings.textGlowOpacity * 100).round()}%',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textGlowOpacity = value;
                widget.onSettingsChanged(updatedSettings);
              },
              activeColor: widget.sliderColor,
            ),

            // Color picker
            Row(
              children: [
                Text('Glow Color', style: TextStyle(color: widget.sliderColor)),
                const Spacer(),
                ColorPickerButton(
                  color: widget.settings.textGlowColor,
                  onColorChanged: (color) {
                    final updatedSettings = widget.settings;
                    updatedSettings.textGlowColor = color;
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

  Widget _buildOutlineTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Outline toggle
          LabeledSwitch(
            label: 'Enable Outline',
            value: widget.settings.textOutlineEnabled,
            onChanged: (value) {
              final updatedSettings = widget.settings;
              updatedSettings.textOutlineEnabled = value;
              widget.onSettingsChanged(updatedSettings);
            },
          ),
          const SizedBox(height: 16),

          // Outline properties (only visible when enabled)
          if (widget.settings.textOutlineEnabled) ...[
            // Outline width
            LabeledSlider(
              label: 'Width',
              value: widget.settings.textOutlineWidth,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              displayValue:
                  '${widget.settings.textOutlineWidth.toStringAsFixed(1)}',
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textOutlineWidth = value;
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
                  color: widget.settings.textOutlineColor,
                  onColorChanged: (color) {
                    final updatedSettings = widget.settings;
                    updatedSettings.textOutlineColor = color;
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
