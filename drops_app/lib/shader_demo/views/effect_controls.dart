import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';

class EffectControls {
  // Build controls for toggling and configuring shader aspects
  static Widget buildAspectToggleBar({
    required ShaderSettings settings,
    required Function(ShaderAspect, bool) onAspectToggled,
    required Function(ShaderAspect) onAspectSelected,
    required bool isCurrentImageDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAspectToggle(
          aspect: ShaderAspect.color,
          isEnabled: settings.colorEnabled,
          isCurrentImageDark: isCurrentImageDark,
          onToggled: onAspectToggled,
          onTap: onAspectSelected,
        ),
        _buildAspectToggle(
          aspect: ShaderAspect.blur,
          isEnabled: settings.blurEnabled,
          isCurrentImageDark: isCurrentImageDark,
          onToggled: onAspectToggled,
          onTap: onAspectSelected,
        ),
      ],
    );
  }

  // Build a toggleable button for each shader aspect
  static Widget _buildAspectToggle({
    required ShaderAspect aspect,
    required bool isEnabled,
    required bool isCurrentImageDark,
    required Function(ShaderAspect, bool) onToggled,
    required Function(ShaderAspect) onTap,
  }) {
    final Color textColor = isCurrentImageDark ? Colors.white : Colors.black;
    final Color backgroundColor = isCurrentImageDark
        ? Colors.white.withOpacity(isEnabled ? 0.25 : 0.15)
        : Colors.black.withOpacity(isEnabled ? 0.25 : 0.15);

    final Color borderColor = isEnabled
        ? textColor
        : textColor.withOpacity(0.5);

    return Tooltip(
      message: isEnabled
          ? "Long press to disable ${aspect.label}"
          : "Long press to enable ${aspect.label}",
      preferBelow: true,
      showDuration: const Duration(seconds: 1),
      verticalOffset: 20,
      textStyle: TextStyle(
        color: isCurrentImageDark ? Colors.black : Colors.white,
        fontSize: 12,
      ),
      decoration: BoxDecoration(
        color: isCurrentImageDark
            ? Colors.white.withOpacity(0.9)
            : Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        // Single tap to select the aspect and show sliders
        onTap: () => onTap(aspect),
        // Long press to toggle the effect on/off
        onLongPress: () => onToggled(aspect, !isEnabled),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isEnabled ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(aspect.icon, color: textColor, size: 24),
              const SizedBox(height: 4),
              Text(
                aspect.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEnabled ? Colors.green : textColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build sliders for a specific aspect with proper grouping
  static List<Widget> buildSlidersForAspect({
    required ShaderAspect aspect,
    required ShaderSettings settings,
    required Function(ShaderSettings) onSettingsChanged,
    required Color sliderColor,
  }) {
    // Helper function to enable the effect if needed when slider changes
    void onSliderChanged(double value, Function(double) setter) {
      // Enable the corresponding effect if it's not already enabled
      switch (aspect) {
        case ShaderAspect.color:
          if (!settings.colorEnabled) settings.colorEnabled = true;
          break;
        case ShaderAspect.blur:
          if (!settings.blurEnabled) settings.blurEnabled = true;
          break;
      }

      // Update the setting value
      setter(value);
      // Notify the parent widget
      onSettingsChanged(settings);
    }

    switch (aspect) {
      case ShaderAspect.color:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Color Settings",
              style: TextStyle(
                color: sliderColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          buildSlider(
            label: 'Hue',
            value: settings.hue,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.hue = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Saturation',
            value: settings.saturation,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.saturation = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Lightness',
            value: settings.lightness,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.lightness = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          const SizedBox(height: 16),
          buildSlider(
            label: 'Overlay Hue',
            value: settings.overlayHue,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayHue = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Overlay Intensity',
            value: settings.overlayIntensity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayIntensity = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Overlay Opacity',
            value: settings.overlayOpacity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayOpacity = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
        ];

      case ShaderAspect.blur:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Blur Settings",
              style: TextStyle(
                color: sliderColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          buildSlider(
            label: 'Blur Amount',
            value: settings.blurAmount,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.blurAmount = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Blur Radius',
            value:
                settings.blurRadius /
                30.0, // Scale down from max 30 to 0-1 range
            onChanged: (value) => onSliderChanged(
              value,
              (v) => settings.blurRadius = v * 30.0,
            ), // Scale up to 0-30 range
            sliderColor: sliderColor,
            defaultValue: 15.0 / 30.0, // Default is 15.0 scaled to 0-1 range
          ),
        ];
    }
  }

  // Utility method to build image selector dropdown
  static Widget buildImageSelector({
    required String selectedImage,
    required List<String> availableImages,
    required bool isCurrentImageDark,
    required Function(String?) onImageSelected,
  }) {
    final Color textColor = isCurrentImageDark ? Colors.white : Colors.black;

    return DropdownButton<String>(
      dropdownColor: isCurrentImageDark
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      value: selectedImage,
      icon: Icon(Icons.arrow_downward, color: textColor),
      elevation: 16,
      style: TextStyle(color: textColor),
      underline: Container(height: 2, color: textColor),
      onChanged: onImageSelected,
      items: availableImages.map<DropdownMenuItem<String>>((String value) {
        final filename = value.split('/').last.split('.').first;
        return DropdownMenuItem<String>(value: value, child: Text(filename));
      }).toList(),
    );
  }

  // Builds a single slider control
  static Widget buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color sliderColor,
    double defaultValue = 0.0,
  }) {
    // Check if the current value is different from the default value
    final bool valueChanged = value != defaultValue;
    final bool isCurrentImageDark = sliderColor == Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isCurrentImageDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: sliderColor,
                  inactiveTrackColor: sliderColor.withOpacity(0.3),
                  thumbColor: sliderColor,
                  overlayColor: sliderColor.withOpacity(0.1),
                ),
                child: Slider(value: value, onChanged: onChanged),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: isCurrentImageDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Reset button for this specific slider - disabled if value hasn't changed
            InkWell(
              onTap: valueChanged ? () => onChanged(defaultValue) : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: valueChanged
                      ? sliderColor.withOpacity(0.1)
                      : sliderColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.refresh,
                  color: valueChanged
                      ? sliderColor
                      : sliderColor.withOpacity(0.3),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
