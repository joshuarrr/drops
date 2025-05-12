import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'controllers/effect_controller.dart';
import 'views/effect_controls.dart';

class ShaderDemo extends StatefulWidget {
  const ShaderDemo({super.key});

  @override
  State<ShaderDemo> createState() => _ShaderDemoState();
}

class _ShaderDemoState extends State<ShaderDemo>
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
    return AppScaffold(
      title: 'Shader Demo',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 1, // Demos tab
      extendBodyBehindAppBar: true,
      appBarBackgroundColor: Colors.transparent,
      appBarElevation: 0,
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                          EffectControls.buildImageSelector(
                            selectedImage: _selectedImage,
                            availableImages: _availableImages,
                            isCurrentImageDark: _isCurrentImageDark,
                            onImageSelected: (String? value) {
                              if (value != null && value != _selectedImage) {
                                setState(() {
                                  _selectedImage = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      EffectControls.buildEffectSelector(
                        selectedEffect: _selectedEffect,
                        isCurrentImageDark: _isCurrentImageDark,
                        onEffectSelected: (ShaderEffect effect) {
                          setState(() {
                            // Check if user is selecting a new effect or tapping the existing one
                            final bool selectingNewEffect =
                                _selectedEffect != effect;
                            _selectedEffect = effect;

                            // If selecting a new effect that's not 'none', show the sliders
                            if (selectingNewEffect) {
                              if (effect != ShaderEffect.none) {
                                _showEffectSliders = true;
                              } else {
                                _showEffectSliders = false;
                              }
                            }
                          });
                        },
                        onEffectButtonPressed: () {
                          setState(() {
                            // Toggle sliders for non-none effects
                            if (_selectedEffect != ShaderEffect.none) {
                              _showEffectSliders = !_showEffectSliders;
                            }
                          });
                        },
                      ),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Apply the selected effect
        return EffectController.applyEffect(
          child: _buildCenteredImage(),
          selectedEffect: _selectedEffect,
          waveSettings: _waveSettings,
          colorSettings: _colorSettings,
          pixelateSettings: _pixelateSettings,
          animationValue: _controller.value,
        );
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

  // Build parameter sliders for the selected effect
  Widget _buildEffectParameterSliders() {
    final Color sliderColor = _isCurrentImageDark ? Colors.white : Colors.black;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildSlidersForCurrentEffect(sliderColor),
        ),
      ),
    );
  }

  List<Widget> _buildSlidersForCurrentEffect(Color sliderColor) {
    switch (_selectedEffect) {
      case ShaderEffect.wave:
        return [
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
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
          EffectControls.buildSlider(
            label: 'Blur Amount',
            value: _pixelateSettings.blurAmount,
            onChanged: (value) {
              setState(() {
                _pixelateSettings.blurAmount = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          EffectControls.buildSlider(
            label: 'Quality',
            value: _pixelateSettings.blurQuality,
            onChanged: (value) {
              setState(() {
                _pixelateSettings.blurQuality = value;
              });
            },
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
        ];

      default:
        return [];
    }
  }
}
