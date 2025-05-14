import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'controllers/effect_controller.dart';
import 'views/effect_controls.dart';
import 'views/panel_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/animation_options.dart';

enum ImageCategory { covers, artists }

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

  // Animation duration bounds (shared baseline for internal timing)
  static const int _minDurationMs = 30000; // slowest
  static const int _maxDurationMs = 300; // fastest

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

  @override
  void initState() {
    super.initState();

    // Initialize unified settings object
    _shaderSettings = ShaderSettings();

    // Load persisted settings (if any) before building UI
    _loadShaderSettings();

    // Drive animations using the slowest duration (_minDurationMs). Individual
    // effects scale this base time based on the user-selected speed so the
    // "Min" position on the speed slider truly results in the slowest motion.
    _controller = AnimationController(
      duration: Duration(milliseconds: _minDurationMs),
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
      title: 'Shaders',
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
                                  case ShaderAspect.text:
                                    _shaderSettings.textEnabled = enabled;
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
                            hidden: _showAspectSliders,
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
        // Use the raw controller value as the base time; individual effects
        // now derive their own animation curves (speed/mode/easing).
        final double animationValue = _controller.value;

        // Apply all enabled effects using the shared base time
        Widget baseImage = _buildCenteredImage();
        Widget effectsWidget = EffectController.applyEffects(
          child: baseImage,
          settings: _shaderSettings,
          animationValue: animationValue,
        );

        // Compose text overlay if enabled
        List<Widget> stackChildren = [SizedBox.expand(child: effectsWidget)];

        if (_shaderSettings.textEnabled &&
            (_shaderSettings.textTitle.isNotEmpty ||
                _shaderSettings.textSubtitle.isNotEmpty ||
                _shaderSettings.textArtist.isNotEmpty)) {
          stackChildren.add(_buildTextOverlay());
        }

        return Stack(fit: StackFit.expand, children: stackChildren);
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
                // Blur animation controls are now integrated in EffectControls
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

  // Build positioned text overlay
  Widget _buildTextOverlay() {
    final Size screenSize = MediaQuery.of(context).size;

    List<Widget> positionedLines = [];

    void addLine({
      required String text,
      required String font,
      required double size,
      required double posX,
      required double posY,
    }) {
      if (text.isEmpty) return;
      // Compute appropriate text style for this line
      final double computedSize = size > 0
          ? size * screenSize.width
          : _shaderSettings.textSize * screenSize.width;

      final String family = font.isNotEmpty ? font : _shaderSettings.textFont;

      TextStyle baseStyle = TextStyle(
        color: Colors.white,
        fontSize: computedSize,
      );

      late TextStyle textStyle;
      if (family.isEmpty) {
        textStyle = baseStyle; // Default system font
      } else {
        try {
          textStyle = GoogleFonts.getFont(family, textStyle: baseStyle);
        } catch (_) {
          // Fallback to system/default font family
          textStyle = baseStyle.copyWith(fontFamily: family);
        }
      }

      positionedLines.add(
        Positioned(
          left: posX * screenSize.width,
          top: posY * screenSize.height,
          child: Text(text, style: textStyle),
        ),
      );
    }

    addLine(
      text: _shaderSettings.textTitle,
      font: _shaderSettings.titleFont,
      size: _shaderSettings.titleSize,
      posX: _shaderSettings.titlePosX,
      posY: _shaderSettings.titlePosY,
    );

    addLine(
      text: _shaderSettings.textSubtitle,
      font: _shaderSettings.subtitleFont,
      size: _shaderSettings.subtitleSize,
      posX: _shaderSettings.subtitlePosX,
      posY: _shaderSettings.subtitlePosY,
    );

    addLine(
      text: _shaderSettings.textArtist,
      font: _shaderSettings.artistFont,
      size: _shaderSettings.artistSize,
      posX: _shaderSettings.artistPosX,
      posY: _shaderSettings.artistPosY,
    );

    return Stack(children: positionedLines);
  }
}
