import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math';

class ShaderDemo2 extends StatefulWidget {
  const ShaderDemo2({super.key});

  @override
  State<ShaderDemo2> createState() => _ShaderDemo2State();
}

enum ShaderEffect { none, wave, color, pixelate }

// Class to store wave effect settings
class WaveSettings {
  double intensity;
  double speed;

  WaveSettings({this.intensity = 0.5, this.speed = 0.5});
}

// Class to store color effect settings
class ColorSettings {
  double hue;
  double saturation;
  double lightness;
  double overlayHue;
  double overlayIntensity;
  double overlayOpacity;

  ColorSettings({
    this.hue = 0.0,
    this.saturation = 0.0,
    this.lightness = 0.0,
    this.overlayHue = 0.0,
    this.overlayIntensity = 0.0,
    this.overlayOpacity = 0.0,
  });
}

// Class to store pixelate/blur effect settings
class PixelateSettings {
  double blurAmount;
  double blurQuality;

  PixelateSettings({this.blurAmount = 0.5, this.blurQuality = 0.5});
}

class _ShaderDemo2State extends State<ShaderDemo2>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  late AnimationController _controller;

  // Currently selected shader effect
  ShaderEffect _selectedEffect = ShaderEffect.wave;

  // Track whether effect sliders are visible
  bool _showEffectSliders = false;

  // Effect settings objects for each effect type
  late WaveSettings _waveSettings;
  late ColorSettings _colorSettings;
  late PixelateSettings _pixelateSettings;

  // List of available images
  final List<String> _availableImages = [
    'assets/img/abbey.png',
    'assets/img/darkside.png',
    'assets/img/bollocks.png',
    'assets/img/ill.png',
    'assets/img/londoncalling.png',
  ];

  // Map to identify which images are dark (true) vs light (false)
  final Map<String, bool> _darkImages = {
    'assets/img/abbey.png': false,
    'assets/img/darkside.png': true,
    'assets/img/bollocks.png': false,
    'assets/img/ill.png': true,
    'assets/img/londoncalling.png': false,
  };

  // Currently selected image
  String _selectedImage = 'assets/img/darkside.png';

  // Helper to determine if current image is dark
  bool get _isCurrentImageDark => _darkImages[_selectedImage] ?? false;

  @override
  void initState() {
    super.initState();

    // Initialize settings objects with default values
    _waveSettings = WaveSettings();
    _colorSettings = ColorSettings();
    _pixelateSettings = PixelateSettings();

    // Create animation controller for simple shader effect
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Delay full immersive mode until after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up system UI to be fully immersive
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    // Restore system UI when we leave this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: GestureDetector(
        onTap: () {
          setState(() {
            // Tap on screen hides both top controls and effect sliders
            _showControls = !_showControls;
            if (!_showControls) {
              _showEffectSliders = false;
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated shader effect
            _buildShaderEffect(),

            // Controls overlay that can be toggled
            if (_showControls)
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    8,
                  ), // Reduce top padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _isCurrentImageDark
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedImage.split('/').last.split('.').first,
                              style: TextStyle(
                                color: _isCurrentImageDark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildImageSelector(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildEffectSelector(),
                    ],
                  ),
                ),
              ),

            // Effect parameter sliders
            if (_showControls &&
                _showEffectSliders &&
                _selectedEffect != ShaderEffect.none)
              _buildEffectParameterSliders(),
          ],
        ),
      ),
    );
  }

  Widget _buildShaderEffect() {
    // Start with the base image
    Widget result = _buildCenteredImage();

    // For None effect, just return the image
    if (_selectedEffect == ShaderEffect.none) {
      return result;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Start with the base image
        Widget effectsApplied = _buildCenteredImage();

        // Apply color adjustments if any color settings are non-default
        if (_colorSettings.hue != 0.0 ||
            _colorSettings.saturation != 0.0 ||
            _colorSettings.lightness != 0.0 ||
            _colorSettings.overlayOpacity > 0.0) {
          effectsApplied = _applyColorEffect(effectsApplied);
        }

        // Apply wave effect if intensity > 0
        if (_waveSettings.intensity > 0.0 && _waveSettings.speed > 0.0) {
          effectsApplied = _applyWaveEffect(effectsApplied);
        }

        // Apply blur effect if amount > 0
        if (_pixelateSettings.blurAmount > 0.0) {
          effectsApplied = _applyPixelateEffect(effectsApplied);
        }

        return effectsApplied;
      },
    );
  }

  // Helper method to build a centered image that fills the screen
  Widget _buildCenteredImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the screen dimensions
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight,
          child: Center(
            child: Image.asset(
              _selectedImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
    );
  }

  // Helper method to apply wave effect to any widget
  Widget _applyWaveEffect(Widget child) {
    final effectValue =
        _waveSettings.intensity * _controller.value * _waveSettings.speed * 2;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return ui.Gradient.linear(
          Offset(bounds.width * effectValue, 0),
          Offset(bounds.width * (effectValue + 0.2), bounds.height),
          [
            Colors.white.withOpacity(1.0),
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
          [0.0, 0.5, 1.0],
          TileMode.mirror,
        );
      },
      child: child,
    );
  }

  // Helper method to apply color effect to any widget
  Widget _applyColorEffect(Widget child) {
    // Base image color adjustments from the color settings object
    final double baseHueCos = cos(2 * pi * _colorSettings.hue);
    final double baseHueSin = sin(2 * pi * _colorSettings.hue);

    // First apply the base image adjustments
    Widget adjustedImage = ColorFiltered(
      colorFilter: ColorFilter.matrix([
        // Red channel
        1.0 + _colorSettings.saturation * (baseHueCos - 1.0),
        _colorSettings.saturation *
            sin(2 * pi * (_colorSettings.hue + 1 / 3)) *
            0.5,
        _colorSettings.saturation *
            sin(2 * pi * (_colorSettings.hue + 2 / 3)) *
            0.5,
        0,
        _colorSettings.lightness * 0.3,

        // Green channel
        _colorSettings.saturation * sin(2 * pi * _colorSettings.hue) * 0.5,
        1.0 +
            _colorSettings.saturation *
                (cos(2 * pi * (_colorSettings.hue + 1 / 3)) - 1.0),
        _colorSettings.saturation *
            sin(2 * pi * (_colorSettings.hue + 2 / 3)) *
            0.5,
        0,
        _colorSettings.lightness * 0.3,

        // Blue channel
        _colorSettings.saturation * sin(2 * pi * _colorSettings.hue) * 0.5,
        _colorSettings.saturation *
            sin(2 * pi * (_colorSettings.hue + 1 / 3)) *
            0.5,
        1.0 +
            _colorSettings.saturation *
                (cos(2 * pi * (_colorSettings.hue + 2 / 3)) - 1.0),
        0,
        _colorSettings.lightness * 0.3,

        // Alpha channel
        0,
        0,
        0,
        1.0,
        0,
      ]),
      child: child,
    );

    // Then apply color overlay if opacity > 0
    if (_colorSettings.overlayOpacity > 0) {
      return Stack(
        fit: StackFit.expand,
        children: [
          adjustedImage,
          Opacity(
            opacity:
                _colorSettings.overlayOpacity * _colorSettings.overlayIntensity,
            child: Container(
              color: HSLColor.fromAHSL(
                1.0,
                _colorSettings.overlayHue * 360,
                1.0,
                0.5,
              ).toColor(),
            ),
          ),
        ],
      );
    }

    return adjustedImage;
  }

  // Helper method to apply pixelate/blur effect to any widget
  Widget _applyPixelateEffect(Widget child) {
    // Use blur parameters from the pixelate settings object
    final blurValue = 0.5 + 1.5 * _pixelateSettings.blurAmount;
    final qualityFactor = 1.0 + _pixelateSettings.blurQuality * 2.0;

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurValue * qualityFactor,
        sigmaY: blurValue * qualityFactor,
      ),
      child: child,
    );
  }

  Widget _buildImageSelector() {
    final Color textColor = _isCurrentImageDark ? Colors.white : Colors.black;

    return DropdownButton<String>(
      dropdownColor: _isCurrentImageDark
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      value: _selectedImage,
      icon: Icon(Icons.arrow_downward, color: textColor),
      elevation: 16,
      style: TextStyle(color: textColor),
      underline: Container(height: 2, color: textColor),
      onChanged: (String? value) {
        if (value != null && value != _selectedImage) {
          setState(() {
            _selectedImage = value;
          });
        }
      },
      items: _availableImages.map<DropdownMenuItem<String>>((String value) {
        final filename = value.split('/').last.split('.').first;
        return DropdownMenuItem<String>(value: value, child: Text(filename));
      }).toList(),
    );
  }

  Widget _buildEffectSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEffectButton(ShaderEffect.none, Icons.panorama, 'None'),
        _buildEffectButton(ShaderEffect.color, Icons.color_lens, 'Color'),
        _buildEffectButton(ShaderEffect.wave, Icons.waves, 'Wave'),
        _buildEffectButton(ShaderEffect.pixelate, Icons.grain, 'Blur'),
      ],
    );
  }

  Widget _buildEffectButton(ShaderEffect effect, IconData icon, String label) {
    final isSelected = _selectedEffect == effect;

    // Apply transparent black for light images, transparent white for dark images
    final Color buttonBgColor = _isCurrentImageDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.15);

    // For selected state, use white outline for dark images and black for light
    final Color selectedBorderColor = _isCurrentImageDark
        ? Colors.white
        : Colors.black;

    final Color borderColor = isSelected
        ? selectedBorderColor
        : (_isCurrentImageDark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5));

    // For selected state, use white text for dark images and black for light
    final Color selectedTextColor = _isCurrentImageDark
        ? Colors.white
        : Colors.black;

    final Color iconAndTextColor = isSelected
        ? selectedTextColor
        : (_isCurrentImageDark ? Colors.white : Colors.black);

    return InkWell(
      onTap: () {
        setState(() {
          // Always set the selected effect first
          _selectedEffect = effect;

          // For non-none effects, always show sliders when selecting them
          if (effect != ShaderEffect.none) {
            _showEffectSliders = true;
          } else {
            _showEffectSliders = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (_isCurrentImageDark
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
    );
  }

  // Build parameter sliders for the selected effect
  Widget _buildEffectParameterSliders() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(
          top: 100,
        ), // Increase top margin significantly
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildSlidersForCurrentEffect(),
        ),
      ),
    );
  }

  List<Widget> _buildSlidersForCurrentEffect() {
    final Color sliderColor = _isCurrentImageDark ? Colors.white : Colors.black;

    switch (_selectedEffect) {
      case ShaderEffect.wave:
        return [
          _buildSlider(
            label: 'Intensity',
            value: _waveSettings.intensity,
            onChanged: (value) {
              setState(() {
                _waveSettings.intensity = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.5,
          ),
          _buildSlider(
            label: 'Speed',
            value: _waveSettings.speed,
            onChanged: (value) {
              setState(() {
                _waveSettings.speed = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.5,
          ),
        ];

      case ShaderEffect.color:
        return [
          _buildSlider(
            label: 'Hue',
            value: _colorSettings.hue,
            onChanged: (value) {
              setState(() {
                _colorSettings.hue = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          _buildSlider(
            label: 'Saturation',
            value: _colorSettings.saturation,
            onChanged: (value) {
              setState(() {
                _colorSettings.saturation = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          _buildSlider(
            label: 'Lightness',
            value: _colorSettings.lightness,
            onChanged: (value) {
              setState(() {
                _colorSettings.lightness = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Overlay Hue',
            value: _colorSettings.overlayHue,
            onChanged: (value) {
              setState(() {
                _colorSettings.overlayHue = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          _buildSlider(
            label: 'Overlay Intensity',
            value: _colorSettings.overlayIntensity,
            onChanged: (value) {
              setState(() {
                _colorSettings.overlayIntensity = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          _buildSlider(
            label: 'Overlay Opacity',
            value: _colorSettings.overlayOpacity,
            onChanged: (value) {
              setState(() {
                _colorSettings.overlayOpacity = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
        ];

      case ShaderEffect.pixelate:
        return [
          _buildSlider(
            label: 'Blur Amount',
            value: _pixelateSettings.blurAmount,
            onChanged: (value) {
              setState(() {
                _pixelateSettings.blurAmount = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.5,
          ),
          _buildSlider(
            label: 'Quality',
            value: _pixelateSettings.blurQuality,
            onChanged: (value) {
              setState(() {
                _pixelateSettings.blurQuality = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.5,
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color sliderColor,
    double defaultValue = 0.0,
  }) {
    // Check if the current value is different from the default value
    final bool valueChanged = value != defaultValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _isCurrentImageDark ? Colors.white : Colors.black,
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
                  color: _isCurrentImageDark ? Colors.white : Colors.black,
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
