import 'package:flutter/material.dart';

import '../models/effect_settings.dart';
import '../models/ripple_settings.dart';
import 'labeled_slider.dart';
import 'labeled_switch.dart';
import 'animation_controls.dart';
import 'panel_header.dart';

class RipplePanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const RipplePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<RipplePanel> createState() => _RipplePanelState();
}

class _RipplePanelState extends State<RipplePanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PanelHeader(
          title: 'Ripple',
          showAnimToggle: true,
          animationEnabled: widget.settings.rippleAnimated,
          onAnimationToggled: (enabled) {
            final updatedSettings = widget.settings;
            updatedSettings.rippleAnimated = enabled;
            widget.onSettingsChanged(updatedSettings);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Enable/disable switch
              LabeledSwitch(
                label: 'Enable Ripple Effect',
                value: widget.settings.rippleEnabled,
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleEnabled = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
              SizedBox(height: 8),

              // Number of drops with randomize button
              Row(
                children: [
                  Expanded(
                    child: LabeledSlider(
                      label: 'Number of Drops',
                      value: widget.settings.rippleSettings.rippleDropCount
                          .toDouble(),
                      min: 1.0,
                      max: 30.0,
                      divisions: 29,
                      displayValue: widget
                          .settings
                          .rippleSettings
                          .rippleDropCount
                          .toString(),
                      onChanged: (value) {
                        final updatedSettings = widget.settings;
                        updatedSettings.rippleSettings.rippleDropCount = value
                            .round();
                        widget.onSettingsChanged(updatedSettings);
                      },
                      activeColor: widget.sliderColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shuffle, color: widget.sliderColor),
                    tooltip: 'Randomize drop positions',
                    onPressed: () {
                      final updatedSettings = widget.settings;
                      updatedSettings.rippleSettings.randomizeDropPositions();
                      widget.onSettingsChanged(updatedSettings);
                    },
                  ),
                ],
              ),

              LabeledSlider(
                label: 'Ovalness',
                value: widget.settings.rippleSettings.rippleOvalness,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleOvalness
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleOvalness = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),

              LabeledSlider(
                label: 'Rotation',
                value: widget.settings.rippleSettings.rippleRotation,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleRotation
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleRotation = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),

              LabeledSlider(
                label: 'Intensity',
                value: widget.settings.rippleSettings.rippleIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleIntensity
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleIntensity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Size',
                value: widget.settings.rippleSettings.rippleSize,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleSize
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleSize = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Speed',
                value: widget.settings.rippleSettings.rippleSpeed,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleSpeed
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleSpeed = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Opacity',
                value: widget.settings.rippleSettings.rippleOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleOpacity
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleOpacity = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Color',
                value: widget.settings.rippleSettings.rippleColor,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.rippleSettings.rippleColor
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.rippleColor = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
