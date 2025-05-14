import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'controllers/effect_controller.dart';
import 'views/effect_controls.dart';
import 'views/panel_container.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize unified settings object
    _shaderSettings = ShaderSettings();

    // Create animation controller for shader effects
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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

            // Show active effects info in bottom left
            Positioned(
              left: 16,
              bottom: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_shaderSettings.colorEnabled ||
                      _shaderSettings.blurEnabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_shaderSettings.colorEnabled)
                            Text(
                              "Color: ON",
                              style:
                                  theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                            ),
                          if (_shaderSettings.blurEnabled)
                            Text(
                              "Shatter: ON",
                              style:
                                  theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShaderEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Apply all enabled effects using the controller
        Widget effectsWidget = EffectController.applyEffects(
          child: _buildCenteredImage(),
          settings: _shaderSettings,
          animationValue: _controller.value,
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
                },
                sliderColor: sliderColor,
              ),
            ],
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

        // Default selected image
        if (covers.isNotEmpty) {
          _selectedImage = covers.first;
        } else if (artists.isNotEmpty) {
          _imageCategory = ImageCategory.artists;
          _selectedImage = artists.first;
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
}
