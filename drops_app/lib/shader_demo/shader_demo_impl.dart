import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/animation_utils.dart';
import 'utils/logging_utils.dart' as logging;
import 'controllers/effect_controller.dart';
import 'controllers/preset_dialogs.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'models/shader_preset.dart';
import 'controllers/preset_controller.dart';
import 'views/effect_controls.dart';
import 'views/panel_container.dart';
import 'views/image_container.dart';
import 'views/text_overlay.dart';
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
              PresetDialogs.showSavePresetDialog(
                context: context,
                settings: _shaderSettings,
                imagePath: _selectedImage,
                previewKey: _previewKey,
              );
            } else if (value == 'load_preset') {
              PresetDialogs.showLoadPresetDialog(
                context: context,
                onPresetLoaded: _applyPreset,
              );
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
      child: ImageContainer(
        imagePath: _selectedImage,
        settings: _shaderSettings,
      ),
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
          stackChildren.add(
            TextOverlay(
              settings: _shaderSettings,
              animationValue: animationValue,
            ),
          );
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

  void _applyPreset(ShaderPreset preset) {
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
}
