import 'package:flutter/material.dart';
import '../models/shader_effect.dart';

class EffectControls {
  static Widget buildEffectSelector({
    required ShaderEffect selectedEffect,
    required bool isCurrentImageDark,
    required Function(ShaderEffect) onEffectSelected,
    required Function() onEffectButtonPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEffectButton(
          effect: ShaderEffect.none,
          icon: Icons.panorama,
          label: 'None',
          selectedEffect: selectedEffect,
          isCurrentImageDark: isCurrentImageDark,
          onEffectSelected: onEffectSelected,
          onEffectButtonPressed: onEffectButtonPressed,
        ),
        _buildEffectButton(
          effect: ShaderEffect.color,
          icon: Icons.color_lens,
          label: 'Color',
          selectedEffect: selectedEffect,
          isCurrentImageDark: isCurrentImageDark,
          onEffectSelected: onEffectSelected,
          onEffectButtonPressed: onEffectButtonPressed,
        ),
        _buildEffectButton(
          effect: ShaderEffect.wave,
          icon: Icons.waves,
          label: 'Wave',
          selectedEffect: selectedEffect,
          isCurrentImageDark: isCurrentImageDark,
          onEffectSelected: onEffectSelected,
          onEffectButtonPressed: onEffectButtonPressed,
        ),
        _buildEffectButton(
          effect: ShaderEffect.pixelate,
          icon: Icons.grain,
          label: 'Blur',
          selectedEffect: selectedEffect,
          isCurrentImageDark: isCurrentImageDark,
          onEffectSelected: onEffectSelected,
          onEffectButtonPressed: onEffectButtonPressed,
        ),
      ],
    );
  }

  static Widget _buildEffectButton({
    required ShaderEffect effect,
    required IconData icon,
    required String label,
    required ShaderEffect selectedEffect,
    required bool isCurrentImageDark,
    required Function(ShaderEffect) onEffectSelected,
    required Function() onEffectButtonPressed,
  }) {
    final isSelected = selectedEffect == effect;

    // Apply transparent black for light images, transparent white for dark images
    final Color buttonBgColor = isCurrentImageDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.15);

    // For selected state, use white outline for dark images and black for light
    final Color selectedBorderColor = isCurrentImageDark
        ? Colors.white
        : Colors.black;

    final Color borderColor = isSelected
        ? selectedBorderColor
        : (isCurrentImageDark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5));

    // For selected state, use white text for dark images and black for light
    final Color selectedTextColor = isCurrentImageDark
        ? Colors.white
        : Colors.black;

    final Color iconAndTextColor = isSelected
        ? selectedTextColor
        : (isCurrentImageDark ? Colors.white : Colors.black);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Always call onEffectSelected to select or reselect the effect
          onEffectSelected(effect);

          // If the same effect is being tapped again, toggle the controls
          if (isSelected) {
            onEffectButtonPressed();
          }
        },
        splashColor: isCurrentImageDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isCurrentImageDark
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.25))
                : buttonBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconAndTextColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: iconAndTextColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            fontSize: 16,
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
