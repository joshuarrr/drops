import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as developer;

import 'utils/animation_utils.dart';
import 'controllers/effect_controller.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'models/shader_preset.dart';
import 'controllers/preset_controller.dart';
import 'views/effect_controls.dart';
import 'views/panel_container.dart';
import 'views/preset_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/image_panel.dart';
import 'models/image_category.dart';

// Set true to enable additional debug logging
bool _enableDebugLogging = true;

// Custom log function with more concise formatting and log deduplication
Map<String, String> _lastLogMessages = {};
Map<String, DateTime> _lastLoggedTimes = {};
const _throttleMs = 1000; // Throttle identical logs by 1 second

void _log(String message, {LogLevel level = LogLevel.info}) {
  if (!_enableDebugLogging || level.index < EffectLogger.currentLevel.index)
    return;

  // Generate a hash key for this message
  String messageKey = message.hashCode.toString();

  // Skip logging if we've already logged this exact message recently
  final now = DateTime.now();
  if (_lastLogMessages[messageKey] == message) {
    final lastTime = _lastLoggedTimes[messageKey];
    if (lastTime != null &&
        now.difference(lastTime).inMilliseconds < _throttleMs) {
      return; // Skip this log due to throttling
    }
  }

  // Update cache with this message
  _lastLogMessages[messageKey] = message;
  _lastLoggedTimes[messageKey] = now;

  // Keep cache size reasonable
  if (_lastLogMessages.length > 100) {
    // Remove oldest 20 entries
    final oldestKeys = _lastLogMessages.keys.take(20).toList();
    for (final key in oldestKeys) {
      _lastLogMessages.remove(key);
      _lastLoggedTimes.remove(key);
    }
  }

  // Format message with level prefix
  final prefix = level == LogLevel.debug
      ? "[DEBUG]"
      : level == LogLevel.warning
      ? "[WARN]"
      : level == LogLevel.error
      ? "[ERROR]"
      : "";

  final formattedMessage = prefix.isEmpty ? message : "$prefix $message";

  // Actually log the message
  final String tag = 'ShaderDemo';
  developer.log(formattedMessage, name: tag);

  // Only print debug logs to console if explicitly enabled
  if (level.index >= LogLevel.info.index) {
    debugPrint('[$tag] $formattedMessage');
  }
}

// Use ImageCategory from models instead of declaring it here
// enum ImageCategory { covers, artists }

class ShaderDemoImpl extends StatefulWidget {
  const ShaderDemoImpl({super.key});

  @override
  State<ShaderDemoImpl> createState() => _ShaderDemoImplState();
}

class _ShaderDemoImplState extends State<ShaderDemoImpl>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  late AnimationController _controller;

  // Track if this is the first time building the text overlay for logging purposes
  bool _firstTextOverlayBuild = true;

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

  // Key for capturing the shader effect for thumbnails
  final GlobalKey _previewKey = GlobalKey();

  // Animation duration bounds (from ShaderAnimationUtils)
  static const int _minDurationMs =
      ShaderAnimationUtils.minDurationMs; // slowest
  static const int _maxDurationMs =
      ShaderAnimationUtils.maxDurationMs; // fastest

  // Persistent storage key
  static const String _kShaderSettingsKey = 'shader_demo_settings';

  // Use the shared utilities in ShaderAnimationUtils for these functions
  double _hash(double x) {
    return ShaderAnimationUtils.hash(x);
  }

  // Returns a smoothly varying random value in \[0,1) given normalized time t (0-1)
  double _smoothRandom(double t, {int segments = 8}) {
    return ShaderAnimationUtils.smoothRandom(t, segments: segments);
  }

  // Add variables to track previous settings for logging
  String _lastLoggedColorSettings = '';
  String _lastLoggedTextShaderState = '';

  // Add memoization variables for the text overlay
  Widget? _cachedTextOverlay;
  ShaderSettings? _lastTextOverlaySettings;
  double? _lastTextOverlayAnimValue;
  final _textOverlayMemoKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Initialize unified settings object
    _shaderSettings = ShaderSettings();

    // Enable shaders for images by default
    _shaderSettings.textLayoutSettings.applyShaderEffectsToImage = true;

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
      appBarActions: [
        // Match back button styling for menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          offset: const Offset(0, 40),
          onSelected: (value) {
            if (value == 'save_preset') {
              _showSavePresetDialog();
            } else if (value == 'load_preset') {
              _showLoadPresetDialog();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'save_preset',
              child: Row(
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Save Preset'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'load_preset',
              child: Row(
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text('Load Preset'),
                ],
              ),
            ),
          ],
        ),
      ],
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
            // Wrap the effect in a RepaintBoundary for thumbnail capture
            RepaintBoundary(key: _previewKey, child: _buildShaderEffect()),

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
                                  case ShaderAspect.noise:
                                    _shaderSettings.noiseEnabled = enabled;
                                    break;
                                  case ShaderAspect.textfx:
                                    _shaderSettings.textfxEnabled = enabled;
                                    break;
                                  case ShaderAspect.rain:
                                    _shaderSettings.rainEnabled = enabled;
                                    break;
                                  case ShaderAspect.chromatic:
                                    _shaderSettings.chromaticEnabled = enabled;
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

                                  // Auto-enable text effects if selecting the TextFx aspect and text is enabled
                                  if (aspect == ShaderAspect.textfx &&
                                      _shaderSettings.textEnabled &&
                                      !_shaderSettings.textfxEnabled) {
                                    _shaderSettings.textfxEnabled = true;
                                  }
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
      // Use a child parameter to avoid rebuilding static parts of the tree
      child: _buildCenteredImage(),
      builder: (context, baseImage) {
        // Use the raw controller value as the base time; individual effects
        // now derive their own animation curves (speed/mode/easing).
        final double animationValue = _controller.value;

        // Apply all enabled effects using the shared base time
        // Wrap in RepaintBoundary to prevent excessive rebuilds
        Widget effectsWidget = RepaintBoundary(
          child: _shaderSettings.textLayoutSettings.applyShaderEffectsToImage
              ? EffectController.applyEffects(
                  child: baseImage!,
                  settings: _shaderSettings,
                  animationValue: animationValue,
                )
              : baseImage!, // Don't apply effects if disabled
        );

        // Compose text overlay if enabled
        List<Widget> stackChildren = [SizedBox.expand(child: effectsWidget)];

        if (_shaderSettings.textLayoutSettings.textEnabled &&
            (_shaderSettings.textLayoutSettings.textTitle.isNotEmpty ||
                _shaderSettings.textLayoutSettings.textSubtitle.isNotEmpty ||
                _shaderSettings.textLayoutSettings.textArtist.isNotEmpty)) {
          stackChildren.add(_buildTextOverlay());
        }

        // Use Container with explicit width and height to ensure full-screen capture
        return Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            // Add Center widget to ensure content is perfectly centered
            child: Stack(fit: StackFit.expand, children: stackChildren),
          ),
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
        final deviceAspectRatio = screenWidth / screenHeight;

        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight,
          alignment: Alignment.center,
          child: _selectedImage.isEmpty
              ? const SizedBox.shrink()
              : Center(
                  // Add Center widget to ensure proper alignment
                  child: Image.asset(
                    _selectedImage,
                    alignment: Alignment.center,
                    fit: _shaderSettings.textLayoutSettings.fillScreen
                        ? BoxFit.cover
                        : BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
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
                  // Use ImagePanel widget here instead of building controls directly
                  ImagePanel(
                    settings: _shaderSettings,
                    onSettingsChanged: (settings) {
                      setState(() {
                        _shaderSettings = settings;
                      });
                      _saveShaderSettings();
                    },
                    sliderColor: sliderColor,
                    context: context,
                    coverImages: _coverImages,
                    artistImages: _artistImages,
                    selectedImage: _selectedImage,
                    imageCategory: _imageCategory,
                    onImageSelected: (path) {
                      setState(() {
                        _selectedImage = path;
                      });
                      _saveShaderSettings();
                    },
                    onCategoryChanged: (category) {
                      setState(() {
                        _imageCategory = category;

                        // Ensure selected image belongs to category
                        final images = _getCurrentImages();
                        if (!images.contains(_selectedImage) &&
                            images.isNotEmpty) {
                          _selectedImage = images.first;
                        }
                      });
                      _saveShaderSettings();
                    },
                  ),
                ],
                if (_selectedAspect != ShaderAspect.image) ...[
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
                    context: context,
                  ),
                ],
                // Blur animation controls are now integrated in EffectControls
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show dialog to save a preset
  void _showSavePresetDialog() {
    // Store a reference to the scaffold context before showing the dialog
    final scaffoldContext = context;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SavePresetDialog(
        onSave: (name) async {
          try {
            final preset = await PresetController.savePreset(
              name: name,
              settings: _shaderSettings,
              imagePath: _selectedImage,
              previewKey: _previewKey,
            );

            // Use the stored scaffold context instead of the dialog context
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              SnackBar(
                content: Text('Preset "$name" saved successfully'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            debugPrint('Error saving preset: $e');
            // Use the stored scaffold context instead of the dialog context
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              SnackBar(
                content: Text('Error saving preset: ${e.toString()}'),
                backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }

  // Show dialog to load a preset
  void _showLoadPresetDialog() {
    // Store a reference to the scaffold context before showing the dialog
    final scaffoldContext = context;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PresetsDialog(
        onLoad: (preset) {
          // Force a rebuild with new settings
          setState(() {
            // Apply all settings from the preset
            _shaderSettings = preset.settings;
            _selectedImage = preset.imagePath;

            // Update image category based on the loaded image
            if (_selectedImage.contains('/covers/')) {
              _imageCategory = ImageCategory.covers;
            } else if (_selectedImage.contains('/artists/')) {
              _imageCategory = ImageCategory.artists;
            }

            // Trigger aspect controls to reflect loaded settings - first ensure controls are visible
            _showControls = true;

            // If aspect sliders are open, maintain current aspect but refresh its state
            if (_showAspectSliders) {
              // No change to _selectedAspect here, just keep what the user was looking at
            } else {
              // If no sliders were open, default to color aspect as that's most visually obvious
              _selectedAspect = ShaderAspect.color;
            }
          });

          // Force controller to restart animation to ensure effects are visible
          _controller.reset();
          _controller.repeat();

          // Save changes to persistent storage
          _saveShaderSettings();

          // Use the stored scaffold context instead of the dialog context
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text('Preset "${preset.name}" loaded'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
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

  // Add method to apply text effects to text styles
  TextStyle _applyTextEffects(TextStyle baseStyle) {
    if (!_shaderSettings.textfxSettings.textfxEnabled) {
      return baseStyle;
    }

    TextStyle style = baseStyle;
    List<Shadow> shadows = [];

    // Apply shadow if enabled
    if (_shaderSettings.textfxSettings.textShadowEnabled) {
      shadows.add(
        Shadow(
          blurRadius: _shaderSettings.textfxSettings.textShadowBlur,
          color: _shaderSettings.textfxSettings.textShadowColor.withOpacity(
            _shaderSettings.textfxSettings.textShadowOpacity,
          ),
          offset: Offset(
            _shaderSettings.textfxSettings.textShadowOffsetX,
            _shaderSettings.textfxSettings.textShadowOffsetY,
          ),
        ),
      );
    }

    // Apply glow if enabled (multiple shadows with decreasing opacity)
    if (_shaderSettings.textfxSettings.textGlowEnabled) {
      // Create a glow effect with multiple shadows
      final int steps = 5;
      for (int i = 0; i < steps; i++) {
        double intensity = 1.0 - (i / steps);
        shadows.add(
          Shadow(
            color: _shaderSettings.textfxSettings.textGlowColor.withOpacity(
              _shaderSettings.textfxSettings.textGlowOpacity * intensity,
            ),
            blurRadius:
                _shaderSettings.textfxSettings.textGlowBlur * (i + 1) / steps,
          ),
        );
      }
    }

    // Apply outline if enabled
    if (_shaderSettings.textfxSettings.textOutlineEnabled) {
      // Simulate outline with shadows in 8 directions
      final double offset = _shaderSettings.textfxSettings.textOutlineWidth;
      final Color outlineColor =
          _shaderSettings.textfxSettings.textOutlineColor;

      // Create outline using multiple shadows
      // First do the corners
      shadows.add(
        Shadow(color: outlineColor, offset: Offset(-offset, -offset)),
      );
      shadows.add(Shadow(color: outlineColor, offset: Offset(-offset, offset)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(offset, -offset)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(offset, offset)));

      // Then do the cardinal directions
      shadows.add(Shadow(color: outlineColor, offset: Offset(-offset, 0)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(0, -offset)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(offset, 0)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(0, offset)));
    }

    // Apply metal effect if enabled
    if (_shaderSettings.textfxSettings.textMetalEnabled) {
      // Create metallic effect with linear gradient foreground
      final baseColor = _shaderSettings.textfxSettings.textMetalBaseColor;
      final shineColor = _shaderSettings.textfxSettings.textMetalShineColor;
      final shine = _shaderSettings.textfxSettings.textMetalShine;

      // Helper function to darken a color
      Color darken(Color color, int percent) {
        assert(percent >= 0 && percent <= 100);
        final double factor = 1 - (percent / 100);
        return Color.fromARGB(
          color.alpha,
          (color.red * factor).round().clamp(0, 255),
          (color.green * factor).round().clamp(0, 255),
          (color.blue * factor).round().clamp(0, 255),
        );
      }

      // Helper function to brighten a color
      Color brighten(Color color, int percent) {
        assert(percent >= 0 && percent <= 100);
        final double factor = percent / 100;
        return Color.fromARGB(
          color.alpha,
          (color.red + (255 - color.red) * factor).round().clamp(0, 255),
          (color.green + (255 - color.green) * factor).round().clamp(0, 255),
          (color.blue + (255 - color.blue) * factor).round().clamp(0, 255),
        );
      }

      // More dynamic metal gradient with multiple reflection points
      final darkEdge = darken(baseColor, 60);
      final darkShadow = darken(baseColor, 40);
      final shadow = darken(baseColor, 20);
      final midtone = baseColor;
      final highlight = brighten(shineColor, 15);
      final brightHighlight = brighten(shineColor, 50);
      final superBright = brighten(shineColor, 90);

      // Create a dynamic bevel effect by rotating the gradient slightly
      final double angle = 0.7; // ~40 degrees
      final beginAlignment = Alignment(sin(angle) - 0.5, cos(angle) - 0.5);
      final endAlignment = Alignment(-sin(angle) + 0.5, -cos(angle) + 0.5);

      // For realistic polished metal, we need:
      // 1. Sharp contrasts between light and dark areas
      // 2. Multiple highlights to simulate reflections from different angles
      // 3. Beveled edges for 3D appearance
      style = style.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            begin: beginAlignment,
            end: endAlignment,
            // More color stops creates more realistic metal look with multiple reflection bands
            colors: [
              darkEdge, // Deep edge shadow for 3D effect
              darkShadow, // Dark edge
              shadow, // Shadow transitioning to metal
              midtone, // Base metal color
              highlight, // First light reflection
              brightHighlight, // Strong highlight
              superBright, // Intense specular highlight
              brightHighlight, // Back to strong highlight
              highlight, // Softer highlight
              midtone, // Return to base
              shadow, // Shadow
            ],
            // More carefully spaced stops for realistic metal banding
            stops: [
              0.0,
              0.1,
              0.2,
              0.35,
              0.45,
              0.48,
              0.5 +
                  (shine *
                      0.05), // Center highlight position affected by intensity
              0.52 + (shine * 0.05),
              0.55 + (shine * 0.1),
              0.7,
              1.0,
            ],
            // Create shader over the text area with slight scale to enhance highlight
          ).createShader(Rect.fromLTWH(0, 0, 500, 150)),
      );

      // Multiple shadows for better 3D effect and bevel appearance
      // Bottom shadow (main drop shadow)
      shadows.add(
        Shadow(
          color: Colors.black.withOpacity(0.7),
          offset: Offset(1.5, 1.5),
          blurRadius: 2,
        ),
      );

      // Inner darker shadow for depth along bottom/right edge
      shadows.add(
        Shadow(
          color: darkShadow.withOpacity(0.7),
          offset: Offset(0.8, 0.8),
          blurRadius: 0.8,
        ),
      );

      // Top/left highlight for embossed effect
      shadows.add(
        Shadow(
          color: superBright.withOpacity(0.9),
          offset: Offset(-1, -1),
          blurRadius: 0.5,
        ),
      );

      // Subtle secondary highlight
      shadows.add(
        Shadow(
          color: brightHighlight.withOpacity(0.5),
          offset: Offset(-1.5, -1.5),
          blurRadius: 2,
        ),
      );
    }

    // Apply glass effect if enabled
    if (_shaderSettings.textfxSettings.textGlassEnabled) {
      final glassColor = _shaderSettings.textfxSettings.textGlassColor;
      final opacity = _shaderSettings.textfxSettings.textGlassOpacity;
      final blur = _shaderSettings.textfxSettings.textGlassBlur;
      final refraction = _shaderSettings.textfxSettings.textGlassRefraction;

      // Add a series of very soft, offset shadows to simulate refraction
      for (int i = 0; i < 8; i++) {
        final double angle = i * (3.14159 / 4); // Distribute around 360 degrees
        shadows.add(
          Shadow(
            color: glassColor.withOpacity(opacity * 0.05),
            blurRadius: blur * 1.5,
            offset: Offset(
              cos(angle) * blur * 0.2 * refraction,
              sin(angle) * blur * 0.2 * refraction,
            ),
          ),
        );
      }

      // Make the text semi-transparent and add a subtle border
      style = style.copyWith(
        color: style.color?.withOpacity(opacity * 0.8),
        shadows: shadows,
        background: Paint()..color = glassColor.withOpacity(0.15),
      );
    }

    // Apply neon effect if enabled
    if (_shaderSettings.textfxSettings.textNeonEnabled) {
      final neonColor = _shaderSettings.textfxSettings.textNeonColor;
      final outerColor = _shaderSettings.textfxSettings.textNeonOuterColor;
      final intensity = _shaderSettings.textfxSettings.textNeonIntensity;
      final width = _shaderSettings.textfxSettings.textNeonWidth;

      // Inner glow - several tightly packed shadows
      final int innerSteps = 3;
      for (int i = 0; i < innerSteps; i++) {
        shadows.add(
          Shadow(
            color: neonColor.withOpacity(0.8),
            blurRadius: (i + 1) * width * 30,
            offset: Offset.zero,
          ),
        );
      }

      // Outer glow - larger, more diffuse shadows
      final int outerSteps = 3;
      for (int i = 0; i < outerSteps; i++) {
        double step = i + 1;
        shadows.add(
          Shadow(
            color: outerColor.withOpacity(0.5 / step),
            blurRadius: step * width * 50 * intensity,
            offset: Offset.zero,
          ),
        );
      }

      // Set the text color to be the neon color
      style = style.copyWith(color: neonColor);
    }

    // Apply all shadows to the style
    if (shadows.isNotEmpty && style.foreground == null) {
      style = style.copyWith(shadows: shadows);
    }

    return style;
  }

  // Build text overlay
  Widget _buildTextOverlay() {
    // Generate log messages but only actually log them if they've changed
    if (_shouldLogColorSettings(_shaderSettings)) {
      // Create color settings log message
      final String colorSettingsLog =
          "Color settings - hue: ${_shaderSettings.colorSettings.hue.toStringAsFixed(2)}, " +
          "sat: ${_shaderSettings.colorSettings.saturation.toStringAsFixed(2)}, " +
          "light: ${_shaderSettings.colorSettings.lightness.toStringAsFixed(2)}, " +
          "overlay: [${_shaderSettings.colorSettings.overlayHue.toStringAsFixed(2)}, " +
          "i=${_shaderSettings.colorSettings.overlayIntensity.toStringAsFixed(2)}, " +
          "o=${_shaderSettings.colorSettings.overlayOpacity.toStringAsFixed(2)}]";

      // Only log if it changed from last time
      if (_lastLoggedColorSettings != colorSettingsLog) {
        _log(colorSettingsLog);
        _lastLoggedColorSettings = colorSettingsLog;
      }
    }

    // Create text shader state log message
    final String textShaderState =
        "Building text overlay - Apply shaders to text: ${_shaderSettings.textfxSettings.applyShaderEffectsToText}";

    // Only log if it changed from last time or it's the first build
    if (_firstTextOverlayBuild ||
        _lastLoggedTextShaderState != textShaderState) {
      _log(textShaderState);
      _lastLoggedTextShaderState = textShaderState;
      _firstTextOverlayBuild = false;
    }

    // Get current animation value
    final double animationValue = _controller.value;

    // Always force a rebuild if this is the first time or if we don't have cached settings
    bool forceRebuild = _lastTextOverlaySettings == null;

    // Check if any text settings changed, and if so, force a rebuild by invalidating the cache
    if (_lastTextOverlaySettings != null && !forceRebuild) {
      // Check if any text-related settings have changed
      if (!_areTextSettingsEqual(_shaderSettings, _lastTextOverlaySettings!)) {
        _log("Text settings changed, forcing rebuild of text overlay");
        _cachedTextOverlay = null;
        forceRebuild = true;
      }
    }

    // Check if settings or animation value have changed significantly enough to rebuild
    bool settingsChanged =
        forceRebuild ||
        _lastTextOverlaySettings == null ||
        !_areTextSettingsEqual(_shaderSettings, _lastTextOverlaySettings!);

    // If using animated effects on text, we need to check animation value
    bool animationChanged =
        _shaderSettings.textfxSettings.applyShaderEffectsToText &&
        _shaderSettings.textfxSettings.textfxEnabled &&
        (_lastTextOverlayAnimValue == null ||
            // Only consider animation changes if using animated effects
            ((_shaderSettings.colorSettings.colorAnimated &&
                        _shaderSettings.colorEnabled) ||
                    (_shaderSettings.blurSettings.blurAnimated &&
                        _shaderSettings.blurEnabled) ||
                    (_shaderSettings.noiseSettings.noiseAnimated &&
                        _shaderSettings.noiseEnabled)) &&
                // Check for significant change in animation value (avoid rebuilds for tiny changes)
                (_lastTextOverlayAnimValue! - animationValue).abs() > 0.01);

    // Return cached overlay if available and nothing significant changed
    if (_cachedTextOverlay != null && !settingsChanged && !animationChanged) {
      return _cachedTextOverlay!;
    }

    // Build from scratch if needed
    final overlayStack = Stack(
      key: _textOverlayMemoKey,
      children: _buildTextLines(),
    );

    // Create and cache the result
    Widget result;
    // Apply shader effects only if both flags are enabled - otherwise just show regular text
    if (_shaderSettings.textfxSettings.applyShaderEffectsToText &&
        _shaderSettings.textfxSettings.textfxEnabled) {
      result = Container(
        color: Colors.transparent, // Ensure the container is transparent
        child: RepaintBoundary(
          child: EffectController.applyEffects(
            child: overlayStack,
            settings: _shaderSettings,
            animationValue: animationValue,
            isTextContent: true, // Explicitly identify this as text content
            preserveTransparency: true, // Always preserve transparency for text
          ),
        ),
      );
    } else {
      result = Container(
        color: Colors.transparent, // Ensure the container is transparent
        child: overlayStack,
      );
    }

    // Update cache
    _cachedTextOverlay = result;
    _lastTextOverlaySettings = ShaderSettings.fromMap(_shaderSettings.toMap());
    _lastTextOverlayAnimValue = animationValue;

    return result;
  }

  // Helper to check if text-related settings have changed
  bool _areTextSettingsEqual(ShaderSettings a, ShaderSettings b) {
    // Check main text toggles
    if (a.textLayoutSettings.textEnabled != b.textLayoutSettings.textEnabled ||
        a.textfxSettings.textfxEnabled != b.textfxSettings.textfxEnabled ||
        a.textfxSettings.applyShaderEffectsToText !=
            b.textfxSettings.applyShaderEffectsToText) {
      return false;
    }

    // Check text content
    if (a.textLayoutSettings.textTitle != b.textLayoutSettings.textTitle ||
        a.textLayoutSettings.textSubtitle !=
            b.textLayoutSettings.textSubtitle ||
        a.textLayoutSettings.textArtist != b.textLayoutSettings.textArtist ||
        a.textLayoutSettings.textLyrics != b.textLayoutSettings.textLyrics) {
      return false;
    }

    // Check text styling for all text lines
    // Title
    if (a.textLayoutSettings.titleFont != b.textLayoutSettings.titleFont ||
        a.textLayoutSettings.titleSize != b.textLayoutSettings.titleSize ||
        a.textLayoutSettings.titleWeight != b.textLayoutSettings.titleWeight ||
        a.textLayoutSettings.titleColor.value !=
            b.textLayoutSettings.titleColor.value ||
        a.textLayoutSettings.titlePosX != b.textLayoutSettings.titlePosX ||
        a.textLayoutSettings.titlePosY != b.textLayoutSettings.titlePosY ||
        a.textLayoutSettings.titleFitToWidth !=
            b.textLayoutSettings.titleFitToWidth ||
        a.textLayoutSettings.titleHAlign != b.textLayoutSettings.titleHAlign ||
        a.textLayoutSettings.titleVAlign != b.textLayoutSettings.titleVAlign ||
        a.textLayoutSettings.titleLineHeight !=
            b.textLayoutSettings.titleLineHeight) {
      return false;
    }

    // Subtitle
    if (a.textLayoutSettings.subtitleFont !=
            b.textLayoutSettings.subtitleFont ||
        a.textLayoutSettings.subtitleSize !=
            b.textLayoutSettings.subtitleSize ||
        a.textLayoutSettings.subtitleWeight !=
            b.textLayoutSettings.subtitleWeight ||
        a.textLayoutSettings.subtitleColor.value !=
            b.textLayoutSettings.subtitleColor.value ||
        a.textLayoutSettings.subtitlePosX !=
            b.textLayoutSettings.subtitlePosX ||
        a.textLayoutSettings.subtitlePosY !=
            b.textLayoutSettings.subtitlePosY ||
        a.textLayoutSettings.subtitleFitToWidth !=
            b.textLayoutSettings.subtitleFitToWidth ||
        a.textLayoutSettings.subtitleHAlign !=
            b.textLayoutSettings.subtitleHAlign ||
        a.textLayoutSettings.subtitleVAlign !=
            b.textLayoutSettings.subtitleVAlign ||
        a.textLayoutSettings.subtitleLineHeight !=
            b.textLayoutSettings.subtitleLineHeight) {
      return false;
    }

    // Artist
    if (a.textLayoutSettings.artistFont != b.textLayoutSettings.artistFont ||
        a.textLayoutSettings.artistSize != b.textLayoutSettings.artistSize ||
        a.textLayoutSettings.artistWeight !=
            b.textLayoutSettings.artistWeight ||
        a.textLayoutSettings.artistColor.value !=
            b.textLayoutSettings.artistColor.value ||
        a.textLayoutSettings.artistPosX != b.textLayoutSettings.artistPosX ||
        a.textLayoutSettings.artistPosY != b.textLayoutSettings.artistPosY ||
        a.textLayoutSettings.artistFitToWidth !=
            b.textLayoutSettings.artistFitToWidth ||
        a.textLayoutSettings.artistHAlign !=
            b.textLayoutSettings.artistHAlign ||
        a.textLayoutSettings.artistVAlign !=
            b.textLayoutSettings.artistVAlign ||
        a.textLayoutSettings.artistLineHeight !=
            b.textLayoutSettings.artistLineHeight) {
      return false;
    }

    // Lyrics
    if (a.textLayoutSettings.lyricsFont != b.textLayoutSettings.lyricsFont ||
        a.textLayoutSettings.lyricsSize != b.textLayoutSettings.lyricsSize ||
        a.textLayoutSettings.lyricsWeight !=
            b.textLayoutSettings.lyricsWeight ||
        a.textLayoutSettings.lyricsColor.value !=
            b.textLayoutSettings.lyricsColor.value ||
        a.textLayoutSettings.lyricsPosX != b.textLayoutSettings.lyricsPosX ||
        a.textLayoutSettings.lyricsPosY != b.textLayoutSettings.lyricsPosY ||
        a.textLayoutSettings.lyricsFitToWidth !=
            b.textLayoutSettings.lyricsFitToWidth ||
        a.textLayoutSettings.lyricsHAlign !=
            b.textLayoutSettings.lyricsHAlign ||
        a.textLayoutSettings.lyricsVAlign !=
            b.textLayoutSettings.lyricsVAlign ||
        a.textLayoutSettings.lyricsLineHeight !=
            b.textLayoutSettings.lyricsLineHeight) {
      return false;
    }

    // Check general text settings
    if (a.textLayoutSettings.textFont != b.textLayoutSettings.textFont ||
        a.textLayoutSettings.textSize != b.textLayoutSettings.textSize ||
        a.textLayoutSettings.textWeight != b.textLayoutSettings.textWeight ||
        a.textLayoutSettings.textColor.value !=
            b.textLayoutSettings.textColor.value ||
        a.textLayoutSettings.textFitToWidth !=
            b.textLayoutSettings.textFitToWidth ||
        a.textLayoutSettings.textHAlign != b.textLayoutSettings.textHAlign ||
        a.textLayoutSettings.textVAlign != b.textLayoutSettings.textVAlign ||
        a.textLayoutSettings.textLineHeight !=
            b.textLayoutSettings.textLineHeight) {
      return false;
    }

    // If we're applying shader effects to text, we need to check those settings as well
    if (a.textfxSettings.applyShaderEffectsToText) {
      // Check shader settings that affect text
      if (a.colorEnabled != b.colorEnabled ||
          a.blurEnabled != b.blurEnabled ||
          a.noiseEnabled != b.noiseEnabled) {
        return false;
      }

      // Only check detailed settings for enabled effects
      if (a.colorEnabled) {
        if (a.colorSettings.hue != b.colorSettings.hue ||
            a.colorSettings.saturation != b.colorSettings.saturation ||
            a.colorSettings.lightness != b.colorSettings.lightness) {
          return false;
        }
      }

      if (a.blurEnabled) {
        if (a.blurSettings.blurAmount != b.blurSettings.blurAmount ||
            a.blurSettings.blurRadius != b.blurSettings.blurRadius) {
          return false;
        }
      }

      if (a.noiseEnabled) {
        if (a.noiseSettings.waveAmount != b.noiseSettings.waveAmount ||
            a.noiseSettings.colorIntensity != b.noiseSettings.colorIntensity) {
          return false;
        }
      }
    }

    // All relevant settings are equal
    return true;
  }

  // Extract the text line building logic to a separate method
  List<Widget> _buildTextLines() {
    final Size screenSize = MediaQuery.of(context).size;

    // Use the raw controller value as the base time for text animations if needed
    final double animationValue = _controller.value;

    List<Widget> positionedLines = [];

    // Check if we need to reverse text direction
    // bool shouldReverseText = true;

    // Local helper to map int weight (100-900) to FontWeight constant
    FontWeight toFontWeight(int w) {
      switch (w) {
        case 100:
          return FontWeight.w100;
        case 200:
          return FontWeight.w200;
        case 300:
          return FontWeight.w300;
        case 400:
          return FontWeight.w400;
        case 500:
          return FontWeight.w500;
        case 600:
          return FontWeight.w600;
        case 700:
          return FontWeight.w700;
        case 800:
          return FontWeight.w800;
        case 900:
          return FontWeight.w900;
        default:
          return FontWeight.w400;
      }
    }

    // Helper to map horizontal alignment int to TextAlign
    TextAlign getTextAlign(int align) {
      switch (align) {
        case 0:
          return TextAlign.left;
        case 1:
          return TextAlign.center;
        case 2:
          return TextAlign.right;
        default:
          return TextAlign.center;
      }
    }

    // Helper to compute vertical alignment position
    double getVerticalPosition(
      double basePosition,
      int vAlign,
      double textHeight,
      double fontSize,
    ) {
      switch (vAlign) {
        case 0: // Top - already set by basePosition
          return basePosition;
        case 1: // Middle
          return basePosition - (fontSize / 2);
        case 2: // Bottom
          return basePosition - textHeight;
        default:
          return basePosition;
      }
    }

    void addLine({
      required String text,
      required String font,
      required double size,
      required double posX,
      required double posY,
      required int weight,
      required bool fitToWidth,
      required int hAlign,
      required int vAlign,
      required double lineHeight,
      required Color textColor,
    }) {
      if (text.isEmpty) return;

      // Compute appropriate text style for this line
      final double computedSize = size > 0
          ? size * screenSize.width
          : _shaderSettings.textLayoutSettings.textSize * screenSize.width;

      final String family = font.isNotEmpty
          ? font
          : _shaderSettings.textLayoutSettings.textFont;

      TextStyle baseStyle = TextStyle(
        color: textColor,
        fontSize: computedSize,
        fontWeight: toFontWeight(weight),
        height: fitToWidth
            ? lineHeight
            : null, // Only apply line height when text is wrapped
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

      // Apply text effects
      textStyle = _applyTextEffects(textStyle);

      // Define horizontal alignment and width constraints based on fitToWidth
      final TextAlign textAlign = getTextAlign(hAlign);

      // Calculate horizontal position based on alignment
      double leftPosition = posX * screenSize.width;

      // Calculate container width for text wrapping if fitToWidth is enabled
      double? maxWidth;
      if (fitToWidth) {
        // Use screen width minus the left position to avoid overflow
        maxWidth = screenSize.width - leftPosition;

        // Adjust left position for center/right text alignment with fitToWidth
        if (hAlign == 1) {
          // Center
          leftPosition = screenSize.width / 2;
        } else if (hAlign == 2) {
          // Right
          leftPosition = screenSize.width - 20; // Small padding from right edge
          maxWidth = leftPosition - 20; // Ensure text doesn't go to the edge
        }
      }

      // Create a TextPainter to measure the text for vertical alignment
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: textAlign,
        maxLines: fitToWidth ? null : 1,
      );
      textPainter.layout(maxWidth: maxWidth ?? double.infinity);

      // Calculate vertical position based on alignment
      final double topPosition = getVerticalPosition(
        posY * screenSize.height,
        vAlign,
        textPainter.height,
        computedSize,
      );

      // Create the base text widget with key for stability
      Widget textWidget = Text(
        text,
        key: ValueKey('text_${posX}_${posY}_${text.hashCode}'),
        style: textStyle,
        textAlign: textAlign,
        textDirection: TextDirection.ltr,
        softWrap: fitToWidth,
        overflow: fitToWidth ? TextOverflow.visible : TextOverflow.clip,
      );

      // Wrap in container if using fitToWidth
      if (fitToWidth) {
        textWidget = Container(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          alignment: hAlign == 1
              ? Alignment.center
              : (hAlign == 2 ? Alignment.centerRight : Alignment.centerLeft),
          child: textWidget,
        );
      }

      // Final stable wrapper to isolate repaint boundaries
      textWidget = RepaintBoundary(child: textWidget);

      positionedLines.add(
        Positioned(
          key: ValueKey('pos_${posX}_${posY}_${text.hashCode}'),
          left: hAlign == 1 && fitToWidth ? 0 : leftPosition,
          top: topPosition,
          width: hAlign == 1 && fitToWidth ? screenSize.width : null,
          child: textWidget,
        ),
      );
    }

    // Add each text line with its specific settings
    addLine(
      text: _shaderSettings.textLayoutSettings.textTitle,
      font: _shaderSettings.textLayoutSettings.titleFont,
      size: _shaderSettings.textLayoutSettings.titleSize,
      posX: _shaderSettings.textLayoutSettings.titlePosX,
      posY: _shaderSettings.textLayoutSettings.titlePosY,
      weight: _shaderSettings.textLayoutSettings.titleWeight > 0
          ? _shaderSettings.textLayoutSettings.titleWeight
          : _shaderSettings.textLayoutSettings.textWeight,
      fitToWidth: _shaderSettings.textLayoutSettings.titleFitToWidth,
      hAlign: _shaderSettings.textLayoutSettings.titleHAlign,
      vAlign: _shaderSettings.textLayoutSettings.titleVAlign,
      lineHeight: _shaderSettings.textLayoutSettings.titleLineHeight,
      textColor: _shaderSettings.textLayoutSettings.titleColor,
    );

    addLine(
      text: _shaderSettings.textLayoutSettings.textSubtitle,
      font: _shaderSettings.textLayoutSettings.subtitleFont,
      size: _shaderSettings.textLayoutSettings.subtitleSize,
      posX: _shaderSettings.textLayoutSettings.subtitlePosX,
      posY: _shaderSettings.textLayoutSettings.subtitlePosY,
      weight: _shaderSettings.textLayoutSettings.subtitleWeight > 0
          ? _shaderSettings.textLayoutSettings.subtitleWeight
          : _shaderSettings.textLayoutSettings.textWeight,
      fitToWidth: _shaderSettings.textLayoutSettings.subtitleFitToWidth,
      hAlign: _shaderSettings.textLayoutSettings.subtitleHAlign,
      vAlign: _shaderSettings.textLayoutSettings.subtitleVAlign,
      lineHeight: _shaderSettings.textLayoutSettings.subtitleLineHeight,
      textColor: _shaderSettings.textLayoutSettings.subtitleColor,
    );

    addLine(
      text: _shaderSettings.textLayoutSettings.textArtist,
      font: _shaderSettings.textLayoutSettings.artistFont,
      size: _shaderSettings.textLayoutSettings.artistSize,
      posX: _shaderSettings.textLayoutSettings.artistPosX,
      posY: _shaderSettings.textLayoutSettings.artistPosY,
      weight: _shaderSettings.textLayoutSettings.artistWeight > 0
          ? _shaderSettings.textLayoutSettings.artistWeight
          : _shaderSettings.textLayoutSettings.textWeight,
      fitToWidth: _shaderSettings.textLayoutSettings.artistFitToWidth,
      hAlign: _shaderSettings.textLayoutSettings.artistHAlign,
      vAlign: _shaderSettings.textLayoutSettings.artistVAlign,
      lineHeight: _shaderSettings.textLayoutSettings.artistLineHeight,
      textColor: _shaderSettings.textLayoutSettings.artistColor,
    );

    // Add Lyrics
    addLine(
      text: _shaderSettings.textLayoutSettings.textLyrics,
      font: _shaderSettings.textLayoutSettings.lyricsFont,
      size: _shaderSettings.textLayoutSettings.lyricsSize,
      posX: _shaderSettings.textLayoutSettings.lyricsPosX,
      posY: _shaderSettings.textLayoutSettings.lyricsPosY,
      weight: _shaderSettings.textLayoutSettings.lyricsWeight > 0
          ? _shaderSettings.textLayoutSettings.lyricsWeight
          : _shaderSettings.textLayoutSettings.textWeight,
      fitToWidth: _shaderSettings.textLayoutSettings.lyricsFitToWidth,
      hAlign: _shaderSettings.textLayoutSettings.lyricsHAlign,
      vAlign: _shaderSettings.textLayoutSettings.lyricsVAlign,
      lineHeight: _shaderSettings.textLayoutSettings.lyricsLineHeight,
      textColor: _shaderSettings.textLayoutSettings.lyricsColor,
    );

    return positionedLines;
  }

  // Reduces verbosity by only logging color settings that aren't all zeros
  bool _shouldLogColorSettings(ShaderSettings settings) {
    // Skip logging if everything is zero
    return !(settings.colorSettings.hue == 0.0 &&
        settings.colorSettings.saturation == 0.0 &&
        settings.colorSettings.lightness == 0.0 &&
        settings.colorSettings.overlayIntensity == 0.0 &&
        settings.colorSettings.overlayOpacity == 0.0);
  }
}
