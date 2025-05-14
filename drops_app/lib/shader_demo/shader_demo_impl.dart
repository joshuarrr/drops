import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'controllers/effect_controller.dart';
import 'views/effect_controls.dart';
import 'views/panel_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ImageCategory { covers, artists }

// Two animation behaviours for the shader demo
enum AnimationMode { pulse, randomixed }

// Easing curves for animation timing
enum AnimationEasing { linear, easeIn, easeOut, easeInOut }

class ShaderDemoImpl extends StatefulWidget {
  const ShaderDemoImpl({super.key});

  @override
  State<ShaderDemoImpl> createState() => _ShaderDemoImplState();
}

class _ShaderDemoImplState extends State<ShaderDemoImpl>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  late AnimationController _controller;

  // Currently selected aspect for editing (does not affect which effects are applied)
  ShaderAspect _selectedAspect = ShaderAspect.color;

  // Track whether aspect sliders are visible
  bool _showAspectSliders = false;

  // Unified settings object for all shader aspects
  late ShaderSettings _shaderSettings;

  // Image lists populated from AssetManifest
  List<String> _coverImages = [];
  List<String> _artistImages = [];

  // Currently selected category and image
  ImageCategory _imageCategory = ImageCategory.covers;
  String _selectedImage = '';

  // Currently selected animation behaviour
  AnimationMode _animationMode = AnimationMode.pulse;

  // Random generator for the "randomixed" animation
  final Random _rand = Random();

  // Selected easing curve
  AnimationEasing _animationEasing = AnimationEasing.linear;

  // Animation duration bounds
  static const int _minDurationMs = 30000; // 30 s
  static const int _maxDurationMs = 300; // 0.3 s

  // Normalized speed slider value in [0,1] (0 = slowest, 1 = fastest)
  double _animationSpeed = 0.5; // start mid-range

  // Persistent storage key
  static const String _kShaderSettingsKey = 'shader_demo_settings';

  // Hashing utility for deterministic pseudo-random per segment
  double _hash(double x) {
    // Based on https://stackoverflow.com/a/17479300 (simple hash)
    return (sin(x * 12.9898) * 43758.5453).abs() % 1;
  }

  // Returns a smoothly varying random value in \[0,1) given normalized time t (0-1)
  double _smoothRandom(double t, {int segments = 8}) {
    final double scaled = t * segments;
    final double idx0 = scaled.floorToDouble();
    final double idx1 = idx0 + 1.0;
    final double frac = scaled - idx0;

    final double r0 = _hash(idx0);
    final double r1 = _hash(idx1);

    // Smooth interpolation using easeInOut for softer transitions
    final double eased = Curves.easeInOut.transform(frac);
    return ui.lerpDouble(r0, r1, eased)!;
  }

  // Apply selected easing curve to normalized time value
  double _applyEasing(double t) {
    switch (_animationEasing) {
      case AnimationEasing.easeIn:
        return Curves.easeIn.transform(t);
      case AnimationEasing.easeOut:
        return Curves.easeOut.transform(t);
      case AnimationEasing.easeInOut:
        return Curves.easeInOut.transform(t);
      case AnimationEasing.linear:
      default:
        return t;
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize unified settings object
    _shaderSettings = ShaderSettings();

    // Load persisted settings (if any) before building UI
    _loadShaderSettings();

    // Create animation controller for shader effects
    _controller = AnimationController(
      duration: Duration(
        milliseconds: ((_minDurationMs + _maxDurationMs) ~/ 2),
      ),
      vsync: this,
    )..repeat();

    _loadImageAssets();

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
    final theme = Theme.of(context);
    final bool isDarkTheme = theme.brightness == Brightness.dark;

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
              _showAspectSliders = false;
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated shader effect with all enabled aspects
            _buildShaderEffect(),

            // Controls overlay that can be toggled
            if (_showControls)
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Builder(
                  builder: (context) {
                    final double topInset = MediaQuery.of(context).padding.top;
                    const double toolbarHeight = kToolbarHeight; // 56
                    return Container(
                      // Add extra bottom padding so the gradient extends
                      // further down the screen without moving the toggle bar.
                      padding: EdgeInsets.fromLTRB(
                        16,
                        topInset + 8, // below system inset
                        16,
                        kToolbarHeight, // extend ~56 px further
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // Fade starts roughly halfway down the app-bar title.
                          stops: const [0.0, 0.5, 1.0],
                          colors: [
                            theme.colorScheme.surface.withOpacity(0.7),
                            theme.colorScheme.surface.withOpacity(0.0),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          EffectControls.buildAspectToggleBar(
                            settings: _shaderSettings,
                            isCurrentImageDark: isDarkTheme,
                            onAspectToggled: (aspect, enabled) {
                              setState(() {
                                // Toggle the enabled state of the selected aspect
                                switch (aspect) {
                                  case ShaderAspect.color:
                                    _shaderSettings.colorEnabled = enabled;
                                    break;
                                  case ShaderAspect.blur:
                                    _shaderSettings.blurEnabled = enabled;
                                    break;
                                  case ShaderAspect.image:
                                    // No enable/disable for image aspect
                                    break;
                                }
                              });
                              _saveShaderSettings();
                            },
                            onAspectSelected: (aspect) {
                              setState(() {
                                // Check if user is selecting a new aspect or tapping the existing one
                                final bool selectingNewAspect =
                                    _selectedAspect != aspect;
                                _selectedAspect = aspect;

                                // If selecting a new aspect, always show sliders
                                if (selectingNewAspect) {
                                  _showAspectSliders = true;
                                } else {
                                  // If tapping the same aspect, toggle sliders
                                  _showAspectSliders = !_showAspectSliders;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Aspect parameter sliders for the selected aspect
            if (_showControls && _showAspectSliders)
              _buildAspectParameterSliders(),
          ],
        ),
      ),
    );
  }

  Widget _buildShaderEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Determine the value fed into shader effects based on selected mode
        final double easedTime = _applyEasing(_controller.value);
        final double animationValue = _animationMode == AnimationMode.pulse
            ? easedTime
            : _smoothRandom(easedTime);

        // Apply all enabled effects using the computed animation value
        Widget effectsWidget = EffectController.applyEffects(
          child: _buildCenteredImage(),
          settings: _shaderSettings,
          animationValue: animationValue,
        );

        // Ensure the effect widget maintains the full screen size
        return SizedBox.expand(child: effectsWidget);
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
          alignment: Alignment.center,
          child: _selectedImage.isEmpty
              ? const SizedBox.shrink()
              : Image.asset(
                  _selectedImage,
                  alignment: Alignment.center,
                  fit: _shaderSettings.fillScreen
                      ? BoxFit.cover
                      : BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
        );
      },
    );
  }

  // Build parameter sliders for the selected aspect
  Widget _buildAspectParameterSliders() {
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final Color sliderColor = theme.colorScheme.onSurface;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.8,
        child: PanelContainer(
          isDark: theme.brightness == Brightness.dark,
          margin: const EdgeInsets.only(top: 100),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedAspect == ShaderAspect.image) ...[
                  _buildImageCategorySelector(theme),
                  const SizedBox(height: 12),
                  _buildImageThumbnails(theme),
                  const SizedBox(height: 16),
                ],
                ...EffectControls.buildSlidersForAspect(
                  aspect: _selectedAspect,
                  settings: _shaderSettings,
                  onSettingsChanged: (settings) {
                    setState(() {
                      _shaderSettings = settings;
                    });
                    _saveShaderSettings();
                  },
                  sliderColor: sliderColor,
                ),
                // Animation speed & type selectors (visible only when animate enabled)
                if (_selectedAspect == ShaderAspect.blur &&
                    _shaderSettings.blurAnimated)
                  _buildAnimationSelector(sliderColor),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadImageAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final dynamic manifestJson = json.decode(manifestContent);

      // Support both the legacy and the v2 manifest structure introduced in recent Flutter versions.
      // In the legacy format `manifestJson` is a Map<String, dynamic> whose keys are the asset paths.
      // In the new format it looks like {"version": ..., "assets": { <path>: { ... } }}.
      Iterable<String> assetKeys = [];
      if (manifestJson is Map<String, dynamic>) {
        if (manifestJson.containsKey('assets') &&
            manifestJson['assets'] is Map<String, dynamic>) {
          assetKeys = (manifestJson['assets'] as Map<String, dynamic>).keys;
        } else {
          assetKeys = manifestJson.keys;
        }
      }

      final covers =
          assetKeys
              .where((path) => path.startsWith('assets/img/covers/'))
              .toList()
            ..sort();

      final artists =
          assetKeys
              .where((path) => path.startsWith('assets/img/artists/'))
              .toList()
            ..sort();

      setState(() {
        _coverImages = covers;
        _artistImages = artists;

        // Determine whether current persisted image is valid
        bool isPersistedValid =
            _selectedImage.isNotEmpty &&
            (covers.contains(_selectedImage) ||
                artists.contains(_selectedImage));

        if (!isPersistedValid) {
          // No valid persisted image → choose default
          if (covers.isNotEmpty) {
            _imageCategory = ImageCategory.covers;
            _selectedImage = covers.first;
          } else if (artists.isNotEmpty) {
            _imageCategory = ImageCategory.artists;
            _selectedImage = artists.first;
          } else {
            _selectedImage = '';
          }
        } else {
          // Update category to match persisted image
          _imageCategory = covers.contains(_selectedImage)
              ? ImageCategory.covers
              : ImageCategory.artists;
        }
      });
    } catch (e, stack) {
      debugPrint('Failed to load asset manifest: $e\n$stack');
    }
  }

  // Build radio selector for image category
  Widget _buildImageCategorySelector(ThemeData theme) {
    Color textColor = theme.colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryRadio(ImageCategory.covers, 'Covers', textColor),
        const SizedBox(width: 24),
        _buildCategoryRadio(ImageCategory.artists, 'Artists', textColor),
      ],
    );
  }

  Widget _buildCategoryRadio(
    ImageCategory category,
    String label,
    Color textColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<ImageCategory>(
          value: category,
          groupValue: _imageCategory,
          onChanged: (ImageCategory? value) {
            if (value != null) {
              setState(() {
                _imageCategory = value;

                // Ensure selected image belongs to category
                final images = _getCurrentImages();
                if (!images.contains(_selectedImage) && images.isNotEmpty) {
                  _selectedImage = images.first;
                }
              });
              _saveShaderSettings();
            }
          },
          activeColor: textColor,
        ),
        Text(label, style: TextStyle(color: textColor)),
      ],
    );
  }

  // Build thumbnails for current category
  Widget _buildImageThumbnails(ThemeData theme) {
    final images = _getCurrentImages();
    if (images.isEmpty) {
      return Text(
        'No images',
        style: TextStyle(color: theme.colorScheme.onSurface),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images.map((path) {
        final bool isSelected = path == _selectedImage;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedImage = path;
            });
            _saveShaderSettings();
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 1,
              ),
            ),
            child: Image.asset(path, fit: BoxFit.cover),
          ),
        );
      }).toList(),
    );
  }

  List<String> _getCurrentImages() {
    return _imageCategory == ImageCategory.covers
        ? _coverImages
        : _artistImages;
  }

  // Control to pick the current animation behaviour
  Widget _buildAnimationSelector(Color sliderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Speed', style: TextStyle(color: sliderColor, fontSize: 14)),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withOpacity(0.3),
            thumbColor: sliderColor,
          ),
          child: Slider(
            value: _animationSpeed,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _animationSpeed = value;
                final int newMillis = ui
                    .lerpDouble(
                      _minDurationMs.toDouble(),
                      _maxDurationMs.toDouble(),
                      value,
                    )!
                    .round();
                _controller.duration = Duration(milliseconds: newMillis);
                _controller
                  ..stop()
                  ..repeat();
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Animation Type',
          style: TextStyle(color: sliderColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Column(
          children: AnimationMode.values.map((mode) {
            final String label = mode == AnimationMode.pulse
                ? 'Pulse'
                : 'Randomixed';
            return RadioListTile<AnimationMode>(
              value: mode,
              groupValue: _animationMode,
              activeColor: sliderColor,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: TextStyle(color: sliderColor)),
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (AnimationMode? value) {
                if (value != null) {
                  setState(() {
                    _animationMode = value;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text('Easing', style: TextStyle(color: sliderColor, fontSize: 14)),
        const SizedBox(height: 8),
        Column(
          children: AnimationEasing.values.map((ease) {
            final String label;
            switch (ease) {
              case AnimationEasing.linear:
                label = 'Linear';
                break;
              case AnimationEasing.easeIn:
                label = 'Ease In';
                break;
              case AnimationEasing.easeOut:
                label = 'Ease Out';
                break;
              case AnimationEasing.easeInOut:
                label = 'Ease In Out';
                break;
            }
            return RadioListTile<AnimationEasing>(
              value: ease,
              groupValue: _animationEasing,
              activeColor: sliderColor,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: TextStyle(color: sliderColor)),
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (AnimationEasing? value) {
                if (value != null) {
                  setState(() {
                    _animationEasing = value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------------------
  Future<void> _loadShaderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kShaderSettingsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);

        // Support legacy format where only settings map was stored
        if (map.containsKey('settings')) {
          _shaderSettings = ShaderSettings.fromMap(
            Map<String, dynamic>.from(map['settings'] as Map),
          );
          _selectedImage = map['selectedImage'] as String? ?? _selectedImage;
          _imageCategory = ImageCategory
              .values[(map['imageCategory'] as int?) ?? _imageCategory.index];
        } else {
          // Legacy: map is the settings itself
          _shaderSettings = ShaderSettings.fromMap(map);
        }
        setState(() {});
      }
    } catch (e, stack) {
      debugPrint('ShaderDemoImpl: Failed to load settings → $e\n$stack');
    }
  }

  Future<void> _saveShaderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'settings': _shaderSettings.toMap(),
        'selectedImage': _selectedImage,
        'imageCategory': _imageCategory.index,
      };
      await prefs.setString(_kShaderSettingsKey, jsonEncode(payload));
    } catch (e, stack) {
      debugPrint('ShaderDemoImpl: Failed to save settings → $e\n$stack');
    }
  }
}
