import 'package:flutter/material.dart';

import '../models/effect_settings.dart';
import '../models/chromatic_settings.dart';
import 'labeled_slider.dart';
import 'labeled_switch.dart';
import 'animation_controls.dart';
import 'panel_header.dart';

class ChromaticPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;

  const ChromaticPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
  }) : super(key: key);

  @override
  State<ChromaticPanel> createState() => _ChromaticPanelState();
}

class _ChromaticPanelState extends State<ChromaticPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PanelHeader(
          title: 'Chromatic',
          showAnimToggle: true,
          animationEnabled: widget.settings.chromaticAnimated,
          onAnimationToggled: (enabled) {
            final updatedSettings = widget.settings;
            updatedSettings.chromaticAnimated = enabled;
            widget.onSettingsChanged(updatedSettings);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Enable/disable switch
              LabeledSwitch(
                label: 'Enable Chromatic Aberration',
                value: widget.settings.chromaticEnabled,
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticEnabled = value;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),
              SizedBox(height: 8),
              LabeledSlider(
                label: 'Amount',
                value: widget.settings.chromaticSettings.amount,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.chromaticSettings.amount
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.amount = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Angle',
                value: widget.settings.chromaticSettings.angle,
                min: 0.0,
                max: 360.0,
                divisions: 36,
                displayValue:
                    '${widget.settings.chromaticSettings.angle.toInt()}°',
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.angle = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Spread',
                value: widget.settings.chromaticSettings.spread,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.chromaticSettings.spread
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.spread = value;
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
              ),
              LabeledSlider(
                label: 'Intensity',
                value: widget.settings.chromaticSettings.intensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.chromaticSettings.intensity
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.intensity = value;
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
