import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'utils/animation_utils.dart';
import 'utils/logging_utils.dart' as logging;
import 'controllers/effect_controller.dart';
import 'controllers/preset_dialogs.dart';
import 'controllers/preset_controller.dart';
import 'controllers/custom_shader_widgets.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'models/shader_preset.dart';
import 'models/image_category.dart';

import 'views/effect_controls.dart';
import 'views/panel_container.dart';
import 'views/image_container.dart';
import 'views/text_overlay.dart';
import 'widgets/image_panel.dart';

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

  // Add a flag to track when the preset dialog is open
  bool _isPresetDialogOpen = false;

  // Add state variables for preset navigation
  List<ShaderPreset> _availablePresets = [];
  int _currentPresetIndex = -1;
  bool _presetsLoaded = false;

  // Store unsaved edits to restore when returning to current state
  ShaderSettings? _unsavedSettings;
  String? _unsavedImage;
  ImageCategory? _unsavedCategory;

  // PageController for smooth preset transitions
  late PageController _pageController;
  bool _isScrolling = false;

  // Add a variable to track the current session's untitled preset ID
  String? _currentUntitledPresetId;

  @override
  void initState() {
    super.initState();

    // Initialize unified settings object
    _shaderSettings = ShaderSettings();

    // Set default values for effect targeting
    _shaderSettings.colorSettings.applyToImage = true;
    _shaderSettings.colorSettings.applyToText = true;
    _shaderSettings.blurSettings.applyToImage = true;
    _shaderSettings.blurSettings.applyToText = true;
    _shaderSettings.noiseSettings.applyToImage = true;
    _shaderSettings.noiseSettings.applyToText = true;
    _shaderSettings.rainSettings.applyToImage = true;
    _shaderSettings.rainSettings.applyToText = true;
    _shaderSettings.chromaticSettings.applyToImage = true;
    _shaderSettings.chromaticSettings.applyToText = true;
    _shaderSettings.rippleSettings.applyToImage = true;
    _shaderSettings.rippleSettings.applyToText = true;

    // Initialize music controller
    EffectControls.initMusicController(
      settings: _shaderSettings,
      onSettingsChanged: (updatedSettings) {
        setState(() {
          _shaderSettings = updatedSettings;
        });
      },
    );

    // Load music tracks from the assets directory
    _loadMusicTracks();

    // Load persisted settings (if any) before building UI
    _loadShaderSettings();

    // Drive animations using the slowest duration (_minDurationMs). Individual
    // effects scale this base time based on the user-selected speed so the
    // "Min" position on the speed slider truly results in the slowest motion.
    _controller = AnimationController(
      duration: Duration(milliseconds: _minDurationMs),
      vsync: this,
    )..repeat();

    // Initialize PageController with initial page 0
    _pageController = PageController(initialPage: 0);

    _loadImageAssets();

    // Delay full immersive mode until after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up system UI to be fully immersive
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // Clean up any duplicate "Untitled" presets
      _cleanupDuplicateUntitledPresets();
    });

    // Load all available presets
    _loadAvailablePresets();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    // Clean up the effect controls resources
    EffectControls.dispose();
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
      showAppBar:
          !_isPresetDialogOpen, // Hide app bar when preset dialog is open
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
              ).then((_) {
                // Reload available presets immediately after saving
                setState(() {
                  _presetsLoaded = false; // Force reload of presets
                });
                _loadAvailablePresets();
              });
            } else if (value == 'update_preset') {
              // Make sure we have a current preset to update
              if (_currentPresetIndex >= 0 &&
                  _currentPresetIndex < _availablePresets.length) {
                final currentPreset = _availablePresets[_currentPresetIndex];

                PresetDialogs.showUpdatePresetDialog(
                  context: context,
                  preset: currentPreset,
                  newSettings: _shaderSettings,
                  previewKey: _previewKey,
                ).then((_) {
                  // Reload available presets immediately after updating
                  setState(() {
                    _presetsLoaded = false; // Force reload of presets
                  });
                  _loadAvailablePresets();
                });
              }
            } else if (value == 'load_preset') {
              setState(() {
                _isPresetDialogOpen = true;
              });

              PresetDialogs.showLoadPresetDialog(
                context: context,
                onPresetLoaded: (preset) {
                  _applyPreset(preset);
                  // Update the current preset index
                  _findCurrentPresetIndex();
                  // Note: We don't need to set _isPresetDialogOpen to false here
                  // as the dialog is closed automatically and will trigger the then() block
                },
              ).then((_) {
                // This runs when the dialog is closed (either with a preset or without)
                setState(() {
                  _isPresetDialogOpen = false;
                });

                // Refresh available presets in case any were added or deleted
                _loadAvailablePresets();
              });
            }
          },
          itemBuilder: (context) {
            List<PopupMenuItem<String>> items = [
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
            ];

            // Only show the Update option if we have a current preset selected
            if (_currentPresetIndex >= 0 &&
                _currentPresetIndex < _availablePresets.length) {
              items.add(
                const PopupMenuItem<String>(
                  value: 'update_preset',
                  child: Row(
                    children: [
                      Icon(Icons.update),
                      SizedBox(width: 8),
                      Text('Update Current Preset'),
                    ],
                  ),
                ),
              );
            }

            // Add the load preset option
            items.add(
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
            );

            return items;
          },
        ),
      ],
      body: GestureDetector(
        // Main screen tap handler for toggling control panels
        onTap: () async {
          // Note: Handling of aspect sliders is now done in their own overlay
          // First, save the current edited state if we have unsaved changes
          if (_showControls && _hasUnsavedChanges()) {
            // Save current state as untitled preset
            final newPreset = await _saveUntitledPreset();
            if (newPreset != null) {
              _currentPresetIndex = _availablePresets.indexWhere(
                (p) => p.id == newPreset.id,
              );

              // Clear unsaved settings since we've now saved to a preset
              _unsavedSettings = null;
              _unsavedImage = null;
              _unsavedCategory = null;
            }
          }

          setState(() {
            // Tap on screen hides both top controls and effect sliders
            _showControls = !_showControls;
            if (!_showControls) {
              _showAspectSliders = false;
              // Save current shader settings when hiding controls
              _saveShaderSettings();

              // CRITICAL FIX: Also save immediately to current preset before entering slideshow mode
              // This ensures all changes (especially margin settings) will be preserved
              _saveChangesImmediately();
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Show presets based on PageView when controls are hidden and we have loaded presets
            // Otherwise show the preview with current settings
            if (!_showControls && !_isPresetDialogOpen)
              _buildPresetPageView()
            else
              RepaintBoundary(
                key: _previewKey,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildShaderEffect(),
                    // Explicitly add text overlay to ensure it's captured in thumbnails
                    if (_shaderSettings.textLayoutSettings.textEnabled &&
                        (_shaderSettings
                                .textLayoutSettings
                                .textTitle
                                .isNotEmpty ||
                            _shaderSettings
                                .textLayoutSettings
                                .textSubtitle
                                .isNotEmpty ||
                            _shaderSettings
                                .textLayoutSettings
                                .textArtist
                                .isNotEmpty))
                      TextOverlay(
                        settings: _shaderSettings,
                        animationValue: _controller.value,
                      ),
                  ],
                ),
              ),

            // Controls overlay that can be toggled
            if (_showControls && !_isPresetDialogOpen)
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
                      decoration: BoxDecoration(color: Colors.transparent),
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
                                  case ShaderAspect.ripple:
                                    _shaderSettings.rippleEnabled = enabled;
                                    break;
                                  case ShaderAspect.music:
                                    _shaderSettings.musicEnabled = enabled;
                                    // When music is disabled, pause any currently playing music
                                    if (!enabled &&
                                        _shaderSettings
                                            .musicSettings
                                            .isPlaying) {
                                      EffectControls.pauseMusic();
                                    } else if (enabled &&
                                        !_shaderSettings
                                            .musicSettings
                                            .isPlaying &&
                                        _shaderSettings
                                            .musicSettings
                                            .currentTrack
                                            .isNotEmpty) {
                                      // When music is enabled and there's a track selected but not playing, start playback
                                      EffectControls.playMusic();
                                    }
                                    break;
                                  case ShaderAspect.cymatics:
                                    _shaderSettings.cymaticsEnabled = enabled;
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

            // Modal overlay when control panel is shown
            if (_showControls && _showAspectSliders && !_isPresetDialogOpen)
              Positioned.fill(
                child: GestureDetector(
                  // Use a specific hit test behavior that allows taps to go through to children
                  behavior: HitTestBehavior.deferToChild,
                  onTap: () {
                    debugPrint("DEBUG: MODAL BARRIER TAPPED!");
                    setState(() {
                      _showAspectSliders = false;
                    });
                    _saveShaderSettings();
                    if (_hasUnsavedChanges()) {
                      _saveUntitledPreset();
                    }
                  },
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ),

            // The actual control panel
            if (_showControls && _showAspectSliders && !_isPresetDialogOpen)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                bottom:
                    20, // Add a bottom constraint to ensure panel can expand properly
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    // Remove any height constraint to allow scrolling
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height -
                          150, // Leave some padding at top and bottom
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: _buildAspectParameterSliders(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build a PageView for swiping through presets
  Widget _buildPresetPageView() {
    // Ensure presets are loaded
    if (!_presetsLoaded) {
      // Load presets if not already loaded
      _loadAvailablePresets();

      // Show a loading indicator while presets are being loaded
      return const Center(child: CircularProgressIndicator());
    }

    // Apply sort method before building PageView to ensure consistent ordering
    _ensurePresetsUseSavedSortMethod();

    // Filter out presets that are hidden from slideshow
    final visiblePresets = _availablePresets
        .where((preset) => !preset.isHiddenFromSlideshow)
        .toList();

    // Handle no presets case
    if (visiblePresets.isEmpty) {
      return const Center(
        child: Text(
          'No presets available for slideshow.\nTap to return to edit mode.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Determine which preset to start with
    int startIndex = 0; // Default to first preset

    // If we have a current preset selected, start with that
    if (_currentPresetIndex >= 0 &&
        _currentPresetIndex < _availablePresets.length) {
      final currentPresetId = _availablePresets[_currentPresetIndex].id;
      // Find this preset in the filtered visible list
      final visibleIndex = visiblePresets.indexWhere(
        (p) => p.id == currentPresetId,
      );
      if (visibleIndex >= 0) {
        startIndex = visibleIndex;
      }
    }

    // CRITICAL: Force rebuild of PageController if the index has changed significantly
    // This ensures we can always navigate the full list in both directions
    if (_pageController.hasClients &&
        (_pageController.page?.round() ?? 0) != startIndex) {
      // Dispose old controller
      final oldController = _pageController;

      // Create a new controller at the correct index
      _pageController = PageController(initialPage: startIndex);

      // Schedule disposal after this frame to avoid build errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController.dispose();
      });
    }
    // Initialize page controller to current preset index if needed
    else if (!_isScrolling && _pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Start with current preset
        if (!_isScrolling) {
          _pageController.jumpToPage(startIndex);
        }
      });
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      // Set these properties to enable smooth circular scrolling
      allowImplicitScrolling: true,
      padEnds: false,
      onPageChanged: (index) {
        if (!_isScrolling) {
          setState(() {
            // Find the preset ID from the visible presets list
            final selectedPresetId = visiblePresets[index].id;

            // Find the index of this preset in the full presets list
            _currentPresetIndex = _availablePresets.indexWhere(
              (p) => p.id == selectedPresetId,
            );

            // Apply the selected preset
            if (_currentPresetIndex >= 0) {
              // We'll apply the preset immediately, no need to wait for _saveChangesImmediately
              // as we're just switching between existing presets in slideshow mode
              _applyPreset(
                _availablePresets[_currentPresetIndex],
                showControls: false,
              );
            }
          });
        }
      },
      itemCount: visiblePresets.length,
      itemBuilder: (context, index) {
        final preset = visiblePresets[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
              if (!_showControls) {
                _showAspectSliders = false;
              }
            });
          },
          child: _buildShaderEffectForPreset(preset),
        );
      },
    );
  }

  // Build shader effect for a specific preset
  Widget _buildShaderEffectForPreset(ShaderPreset preset) {
    // Get screen dimensions first to ensure consistent sizing
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    // Create a temporary settings object for this preset to avoid modifying the main one
    final presetSettings = preset.settings;

    // CRITICAL FIX: Apply margin from specificSettings if available
    if (preset.specificSettings != null &&
        preset.specificSettings!.containsKey('fitScreenMargin')) {
      // Update the margin in the settings to match the stored specific setting
      presetSettings.textLayoutSettings.fitScreenMargin =
          (preset.specificSettings!['fitScreenMargin'] as num).toDouble();
    }

    // Apply fillScreen setting if available in specificSettings
    if (preset.specificSettings != null &&
        preset.specificSettings!.containsKey('fillScreen')) {
      presetSettings.fillScreen =
          preset.specificSettings!['fillScreen'] as bool;
    }

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double animationValue = _controller.value;

          // Use ImageContainer to properly respect margin settings
          // instead of directly using Image.asset with BoxFit.cover
          Widget baseImage = ImageContainer(
            imagePath: preset.imagePath,
            settings: presetSettings,
          );

          // Check if any effect is targeted to image
          final bool shouldApplyEffectsToImage =
              (presetSettings.colorEnabled &&
                  presetSettings.colorSettings.applyToImage) ||
              (presetSettings.blurEnabled &&
                  presetSettings.blurSettings.applyToImage) ||
              (presetSettings.noiseEnabled &&
                  presetSettings.noiseSettings.applyToImage) ||
              (presetSettings.rainEnabled &&
                  presetSettings.rainSettings.applyToImage) ||
              (presetSettings.chromaticEnabled &&
                  presetSettings.chromaticSettings.applyToImage) ||
              (presetSettings.rippleEnabled &&
                  presetSettings.rippleSettings.applyToImage);

          // Apply effects using the preset's settings
          Widget effectsWidget = shouldApplyEffectsToImage
              ? Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: EffectController.applyEffects(
                    child: baseImage,
                    settings: presetSettings,
                    animationValue: animationValue,
                  ),
                )
              : baseImage; // Don't apply effects if none target the image

          // Add text overlay if enabled in the preset
          List<Widget> stackChildren = [Positioned.fill(child: effectsWidget)];

          if (presetSettings.textLayoutSettings.textEnabled &&
              (presetSettings.textLayoutSettings.textTitle.isNotEmpty ||
                  presetSettings.textLayoutSettings.textSubtitle.isNotEmpty ||
                  presetSettings.textLayoutSettings.textArtist.isNotEmpty)) {
            stackChildren.add(
              TextOverlay(
                settings: presetSettings,
                animationValue: animationValue,
              ),
            );
          }

          return Container(
            color: Colors.black,
            width: width,
            height: height,
            child: Stack(fit: StackFit.expand, children: stackChildren),
          );
        },
      ),
    );
  }

  Widget _buildShaderEffect() {
    // Get screen dimensions first to ensure consistent sizing
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
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

          // Check if any effect is targeted to image
          final bool shouldApplyEffectsToImage =
              (_shaderSettings.colorEnabled &&
                  _shaderSettings.colorSettings.applyToImage) ||
              (_shaderSettings.blurEnabled &&
                  _shaderSettings.blurSettings.applyToImage) ||
              (_shaderSettings.noiseEnabled &&
                  _shaderSettings.noiseSettings.applyToImage) ||
              (_shaderSettings.rainEnabled &&
                  _shaderSettings.rainSettings.applyToImage) ||
              (_shaderSettings.chromaticEnabled &&
                  _shaderSettings.chromaticSettings.applyToImage) ||
              (_shaderSettings.rippleEnabled &&
                  _shaderSettings.rippleSettings.applyToImage);

          // Apply all enabled effects using the shared base time
          // CRITICAL: We need to ensure the size is maintained throughout the effect chain
          Widget effectsWidget = shouldApplyEffectsToImage
              ? Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: EffectController.applyEffects(
                    child: baseImage!,
                    settings: _shaderSettings,
                    animationValue: animationValue,
                  ),
                )
              : baseImage!; // Don't apply effects if none target the image

          // Build only the image with effects, text overlay is added separately
          // in the RepaintBoundary wrapper to ensure thumbnails capture it correctly
          return Container(
            color: Colors.black,
            width: width,
            height: height,
            child: effectsWidget,
          );
        },
      ),
    );
  }

  // Build parameter sliders for the selected aspect
  Widget _buildAspectParameterSliders() {
    final theme = Theme.of(context);
    final Color sliderColor = theme.colorScheme.onSurface;

    return PanelContainer(
      isDark: theme.brightness == Brightness.dark,
      margin: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          // Use AlwaysScrollableScrollPhysics to ensure scrolling works even with small content
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
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
                    // Save to shared preferences
                    _saveShaderSettings();

                    // CRITICAL FIX: Immediately save changes to current preset or create a new untitled preset
                    // This ensures margin settings are preserved when entering slideshow mode
                    _saveChangesImmediately();
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
                    // Also save immediately to preset
                    _saveChangesImmediately();
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
                    // Also save immediately to preset
                    _saveChangesImmediately();
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
    );
  }

  void _applyPreset(ShaderPreset preset, {bool showControls = true}) {
    // Check if this preset has a sort method that should be applied
    PresetSortMethod? sortMethodToApply = preset.sortMethod;

    // Debug logging for text settings
    _log(
      "Applying preset '${preset.name}' with text enabled: ${preset.settings.textLayoutSettings.textEnabled}",
    );
    _log(
      "Text content - Title: '${preset.settings.textLayoutSettings.textTitle}', Subtitle: '${preset.settings.textLayoutSettings.textSubtitle}', Artist: '${preset.settings.textLayoutSettings.textArtist}'",
    );

    // Log specific settings if available
    if (preset.specificSettings != null) {
      _log("Specific settings: ${preset.specificSettings!.keys.join(', ')}");
      if (preset.specificSettings!.containsKey('fitScreenMargin')) {
        _log("  Margin: ${preset.specificSettings!['fitScreenMargin']}");
      }
      if (preset.specificSettings!.containsKey('fillScreen')) {
        _log("  Fill Screen: ${preset.specificSettings!['fillScreen']}");
      }
    }

    // Force a rebuild with new settings
    setState(() {
      // Apply all settings from the preset
      _shaderSettings = preset.settings;

      // CRITICAL FIX: Apply margin from specificSettings if available
      if (preset.specificSettings != null) {
        // Apply margin setting if available
        if (preset.specificSettings!.containsKey('fitScreenMargin')) {
          _shaderSettings.textLayoutSettings.fitScreenMargin =
              (preset.specificSettings!['fitScreenMargin'] as num).toDouble();
        }

        // Apply fillScreen setting if available
        if (preset.specificSettings!.containsKey('fillScreen')) {
          _shaderSettings.fillScreen =
              preset.specificSettings!['fillScreen'] as bool;
        }
      }

      _selectedImage = preset.imagePath;

      // Update image category based on the loaded image
      if (_selectedImage.contains('/covers/')) {
        _imageCategory = ImageCategory.covers;
      } else if (_selectedImage.contains('/artists/')) {
        _imageCategory = ImageCategory.artists;
      }

      // Only show controls if explicitly requested
      if (showControls) {
        _showControls = true;
      }

      // If aspect sliders are open, maintain current aspect but refresh its state
      if (_showAspectSliders) {
        // No change to _selectedAspect here, just keep what the user was looking at
      } else {
        // If no sliders were open, default to color aspect as that's most visually obvious
        _selectedAspect = ShaderAspect.color;
      }

      // Clear unsaved settings when applying a preset
      // This ensures we don't have stale unsaved settings
      _unsavedSettings = null;
      _unsavedImage = null;
      _unsavedCategory = null;
    });

    // Force controller to restart animation to ensure effects are visible
    _controller.reset();
    _controller.repeat();

    // Save changes to persistent storage
    _saveShaderSettings();

    // If a preset with random sort method was loaded, we need to immediately sort the presets
    // This ensures the PageView is built with the correct order when first viewing the preset
    if (sortMethodToApply == PresetSortMethod.random) {
      // Force re-loading and sorting of presets to ensure correct order for navigation
      _reloadAndSortPresets(preset);
    }
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

  // Load all available presets for navigation
  Future<void> _loadAvailablePresets() async {
    // Only load if not already loaded
    if (_presetsLoaded) return;

    try {
      final presets = await PresetController.getAllPresets();

      // Sort presets by created date (newest first)
      presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _availablePresets = presets;
        _presetsLoaded = true;

        // Find the current preset index if possible
        _findCurrentPresetIndex();
      });
    } catch (e) {
      debugPrint('Error loading available presets: $e');
    }
  }

  // Find current preset in available presets list
  void _findCurrentPresetIndex() {
    // This is a simple check - in a production app, you might want
    // to do a more sophisticated comparison of the settings
    for (int i = 0; i < _availablePresets.length; i++) {
      final preset = _availablePresets[i];
      if (preset.imagePath == _selectedImage) {
        _currentPresetIndex = i;
        break;
      }
    }
  }

  // Ensure presets are sorted according to the current preset's saved sort method
  void _ensurePresetsUseSavedSortMethod() {
    // If we're on a preset (not current state) and it has a sort method, apply it
    if (_currentPresetIndex >= 0 &&
        _currentPresetIndex < _availablePresets.length) {
      final currentPreset = _availablePresets[_currentPresetIndex];
      if (currentPreset.sortMethod != null) {
        // Save the current preset ID to restore the correct index after sorting
        final String currentPresetId = currentPreset.id;

        // Sort the presets according to the preset's sort method
        switch (currentPreset.sortMethod!) {
          case PresetSortMethod.dateNewest:
            _availablePresets.sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            );
            break;
          case PresetSortMethod.alphabetical:
            _availablePresets.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
            break;
          case PresetSortMethod.reverseAlphabetical:
            _availablePresets.sort(
              (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
            );
            break;
          case PresetSortMethod.random:
            // For random, we need to use a fixed seed to ensure consistent order during swiping
            // We'll use the preset's creation timestamp as the seed
            final random = Random(
              currentPreset.createdAt.millisecondsSinceEpoch,
            );
            // Fisher-Yates shuffle
            for (var i = _availablePresets.length - 1; i > 0; i--) {
              var j = random.nextInt(i + 1);
              var temp = _availablePresets[i];
              _availablePresets[i] = _availablePresets[j];
              _availablePresets[j] = temp;
            }
            break;
        }

        // Find the index of the current preset in the sorted/shuffled list
        _currentPresetIndex = _availablePresets.indexWhere(
          (p) => p.id == currentPresetId,
        );

        // In case the preset was somehow removed
        if (_currentPresetIndex < 0 && _availablePresets.isNotEmpty) {
          _currentPresetIndex = 0;
        }
      }
    }
  }

  // Add a new method to reload and sort presets based on a specific preset's sort method
  Future<void> _reloadAndSortPresets(ShaderPreset preset) async {
    if (!_presetsLoaded || preset.sortMethod == null) return;

    try {
      // Use the preset's sort method to re-sort presets
      // For random sort, we'll use the preset's creation timestamp as the seed
      final allPresets = await PresetController.getAllPresets();

      if (preset.sortMethod == PresetSortMethod.random) {
        final random = Random(preset.createdAt.millisecondsSinceEpoch);
        // Fisher-Yates shuffle with consistent seed
        for (var i = allPresets.length - 1; i > 0; i--) {
          var j = random.nextInt(i + 1);
          var temp = allPresets[i];
          allPresets[i] = allPresets[j];
          allPresets[j] = temp;
        }
      } else if (preset.sortMethod == PresetSortMethod.dateNewest) {
        allPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (preset.sortMethod == PresetSortMethod.alphabetical) {
        allPresets.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      } else if (preset.sortMethod == PresetSortMethod.reverseAlphabetical) {
        allPresets.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      }

      setState(() {
        _availablePresets = allPresets;
        // Find the current preset's index in the sorted list
        _currentPresetIndex = allPresets.indexWhere((p) => p.id == preset.id);
        if (_currentPresetIndex < 0 && allPresets.isNotEmpty) {
          _currentPresetIndex = 0;
        }
      });
    } catch (e) {
      debugPrint('Error reloading presets for sort method: $e');
    }
  }

  // Fix navigation method to apply preset without recalculating index
  void _navigateToPreviousPreset() {
    // Ensure presets are loaded
    if (!_presetsLoaded) {
      _loadAvailablePresets().then((_) => _navigateToPreviousPreset());
      return;
    }

    // Make sure we're using the sort method from the current preset
    _ensurePresetsUseSavedSortMethod();

    // Filter out presets hidden from slideshow
    final visiblePresets = _availablePresets
        .where((preset) => !preset.isHiddenFromSlideshow)
        .toList();

    if (visiblePresets.isEmpty) return; // No presets to navigate to

    // Get the current page from controller
    final int currentPage = _pageController.page?.round() ?? 0;

    // Calculate the target page with proper wraparound
    int targetPage = (currentPage - 1) % visiblePresets.length;

    // Handle negative modulo properly
    if (targetPage < 0) targetPage += visiblePresets.length;

    // Use the PageController to animate to the previous page
    _isScrolling = true;
    _pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _isScrolling = false;
        });
  }

  // Fix navigation method to apply preset without recalculating index
  void _navigateToNextPreset() {
    // Ensure presets are loaded
    if (!_presetsLoaded) {
      _loadAvailablePresets().then((_) => _navigateToNextPreset());
      return;
    }

    // Make sure we're using the sort method from the current preset
    _ensurePresetsUseSavedSortMethod();

    // Filter out presets hidden from slideshow
    final visiblePresets = _availablePresets
        .where((preset) => !preset.isHiddenFromSlideshow)
        .toList();

    if (visiblePresets.isEmpty) return; // No presets to navigate to

    // Get the current page from controller
    final int currentPage = _pageController.page?.round() ?? 0;

    // Calculate target page with proper wraparound
    int targetPage = (currentPage + 1) % visiblePresets.length;

    // Use the PageController to animate to the next page
    _isScrolling = true;
    _pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _isScrolling = false;
        });
  }

  // Load music tracks from assets directory
  Future<void> _loadMusicTracks() async {
    _log('Loading music tracks from assets directory');
    try {
      // Load tracks from assets directory with a callback
      const musicPath = 'assets/music';
      await EffectControls.loadMusicTracks(
        musicPath,
        onTracksLoaded: (tracks) {
          if (tracks.isNotEmpty) {
            _log('Found ${tracks.length} music tracks:');
            for (final track in tracks) {
              _log('  - ${track.split('/').last}');
            }

            // Select the first track by default but don't play it if music is disabled
            final firstTrack = tracks[0];
            _log('Setting initial track: $firstTrack');

            // Important: Update settings BEFORE calling selectMusicTrack
            final updatedSettings = ShaderSettings.fromMap(
              _shaderSettings.toMap(),
            );
            updatedSettings.musicSettings.currentTrack = firstTrack;

            // Important: Apply the settings first to ensure the controller knows about the track
            setState(() {
              _shaderSettings = updatedSettings;
            });

            // Only select the track, our modified selectMusicTrack will
            // check if music is enabled before playing
            Future.microtask(() {
              EffectControls.selectMusicTrack(firstTrack);
            });
          } else {
            _log(
              'No music tracks found in assets directory',
              level: LogLevel.warning,
            );
          }
        },
      );
    } catch (e) {
      _log('Error loading music tracks: $e', level: LogLevel.error);
    }
  }

  // Add a method to save the current edited state as an untitled preset
  Future<ShaderPreset?> _saveUntitledPreset() async {
    try {
      // Use a fixed name "Untitled" for the session preset
      const String presetName = "Untitled";

      // CRITICAL FIX: Extract and log important settings that need to be directly accessible
      // Ensure we're getting the current values for margin and fillScreen
      final double currentMargin =
          _shaderSettings.textLayoutSettings.fitScreenMargin;
      final bool currentFillScreen = _shaderSettings.fillScreen;

      final Map<String, dynamic> specificSettings = {
        'fillScreen': currentFillScreen,
        'fitScreenMargin': currentMargin,
      };

      debugPrint('SAVE UNTITLED PRESET:');
      debugPrint('  currentMargin: $currentMargin');
      debugPrint('  fillScreen: $currentFillScreen');
      debugPrint(
        '  specificSettings keys: ${specificSettings.keys.join(', ')}',
      );

      // Get all existing presets to check if "Untitled" already exists
      final allPresets = await PresetController.getAllPresets();
      final existingUntitledPreset = allPresets
          .where((p) => p.name == presetName)
          .toList();

      // If an "Untitled" preset already exists, update it instead of creating a new one
      if (existingUntitledPreset.isNotEmpty) {
        debugPrint(
          'Found existing untitled preset - updating instead of creating new',
        );
        final preset = existingUntitledPreset.first;
        _currentUntitledPresetId = preset.id;

        // Update the existing preset
        final updatedPreset = await _updatePresetWithImagePath(
          id: preset.id,
          settings: _shaderSettings,
          imagePath: _selectedImage,
          previewKey: _previewKey,
        );

        // Force reload of presets
        setState(() {
          _presetsLoaded = false;
        });
        await _loadAvailablePresets();

        // Set this as the current preset
        _currentPresetIndex = _availablePresets.indexWhere(
          (p) => p.id == updatedPreset.id,
        );

        return updatedPreset;
      } else {
        debugPrint('No existing untitled preset found - creating new');
        // Save as a new preset with the specific settings
        final newPreset = await PresetController.savePreset(
          name: presetName,
          settings: _shaderSettings,
          imagePath: _selectedImage,
          previewKey: _previewKey,
          specificSettings: specificSettings,
        );

        // Store the ID of this untitled preset for future updates
        _currentUntitledPresetId = newPreset.id;

        debugPrint('PRESET SAVED: ${newPreset.name}');
        if (newPreset.specificSettings != null) {
          debugPrint(
            '  Has specificSettings: ${newPreset.specificSettings!.keys.join(', ')}',
          );
          if (newPreset.specificSettings!.containsKey('fitScreenMargin')) {
            debugPrint(
              '  margin set to: ${newPreset.specificSettings!['fitScreenMargin']}',
            );
          } else {
            debugPrint('  NO margin in specificSettings!');
          }
        } else {
          debugPrint('  NO specificSettings on saved preset!');
        }

        // Force reload of presets to include the new one
        setState(() {
          _presetsLoaded = false;
        });
        await _loadAvailablePresets();

        // Set this new preset as the current one
        _currentPresetIndex = _availablePresets.indexWhere(
          (p) => p.id == newPreset.id,
        );

        return newPreset;
      }
    } catch (e, stack) {
      debugPrint('Error saving untitled preset: $e');
      debugPrint(stack.toString());
      return null;
    }
  }

  // Add a helper method to handle updating a preset with image path changes
  Future<ShaderPreset> _updatePresetWithImagePath({
    required String id,
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
  }) async {
    // Get the existing preset data
    final prefs = await SharedPreferences.getInstance();
    final presetJson = prefs.getString('shader_preset_$id');

    if (presetJson == null) {
      throw Exception('Preset not found');
    }

    // Parse the preset
    final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
    final existing = ShaderPreset.fromMap(presetMap);

    // Extract current margin and fillScreen values to ensure they're preserved
    Map<String, dynamic> specificSettings = {};

    // Preserve existing specificSettings if available
    if (existing.specificSettings != null) {
      specificSettings.addAll(existing.specificSettings!);
    }

    // Update with current values to ensure they're preserved
    specificSettings['fitScreenMargin'] =
        settings.textLayoutSettings.fitScreenMargin;
    specificSettings['fillScreen'] = settings.fillScreen;

    debugPrint('Updating preset with specificSettings:');
    debugPrint('  margin: ${settings.textLayoutSettings.fitScreenMargin}');
    debugPrint('  fillScreen: ${settings.fillScreen}');

    // Create updated preset with new settings, image path and specific settings
    final updatedPreset = existing.copyWith(
      settings: settings,
      imagePath: imagePath,
      specificSettings: specificSettings,
    );

    // Call the original updatePreset method to handle thumbnail capture and saving
    await PresetController.updatePreset(
      id: id,
      settings: settings,
      previewKey: previewKey,
    );

    // Save the updated preset with new image path and specific settings
    try {
      final Map<String, dynamic> updatedMap = updatedPreset.toMap();
      final updatedJson = jsonEncode(updatedMap);
      await prefs.setString('shader_preset_$id', updatedJson);
      return updatedPreset;
    } catch (e) {
      debugPrint('Error updating preset with image path: $e');
      throw Exception('Failed to update preset with new image path: $e');
    }
  }

  // Immediately save current changes to either the current preset or create a new untitled preset
  Future<void> _saveChangesImmediately() async {
    try {
      // If we have a current preset selected and no unsaved changes, nothing to do
      if (_currentPresetIndex >= 0 &&
          _currentPresetIndex < _availablePresets.length &&
          !_hasUnsavedChanges()) {
        debugPrint('No changes detected, skipping save');
        return;
      }

      // If we already have a current untitled preset for this session, update it
      if (_currentUntitledPresetId != null) {
        debugPrint(
          'UPDATING EXISTING UNTITLED PRESET: $_currentUntitledPresetId',
        );

        // Find the preset with this ID
        final existingPresetIndex = _availablePresets.indexWhere(
          (p) => p.id == _currentUntitledPresetId,
        );

        if (existingPresetIndex >= 0) {
          final existingPreset = _availablePresets[existingPresetIndex];

          // Update the existing untitled preset
          await _updatePresetWithImagePath(
            id: existingPreset.id,
            settings: _shaderSettings,
            imagePath: _selectedImage,
            previewKey: _previewKey,
          );

          // Set as current preset
          _currentPresetIndex = existingPresetIndex;

          // Clear unsaved settings since we've now saved to a preset
          _unsavedSettings = null;
          _unsavedImage = null;
          _unsavedCategory = null;

          // Force reload presets to ensure we have the latest version
          setState(() {
            _presetsLoaded = false;
          });
          await _loadAvailablePresets();
          return;
        }
      }

      // If we don't have a current untitled preset for this session, create one
      debugPrint('CREATING NEW UNTITLED PRESET FOR SESSION');
      final newPreset = await _saveUntitledPreset();
      if (newPreset != null) {
        // Store the ID of the untitled preset for this session
        _currentUntitledPresetId = newPreset.id;

        _currentPresetIndex = _availablePresets.indexWhere(
          (p) => p.id == newPreset.id,
        );

        // Clear unsaved settings since we've now saved to a preset
        _unsavedSettings = null;
        _unsavedImage = null;
        _unsavedCategory = null;

        debugPrint('Created new preset with index: $_currentPresetIndex');

        // Make sure the specificSettings include current margin and fillScreen values
        if (newPreset.specificSettings != null) {
          final currentMargin =
              _shaderSettings.textLayoutSettings.fitScreenMargin;
          final currentFillScreen = _shaderSettings.fillScreen;

          debugPrint(
            'Saved margin: $currentMargin, fillScreen: $currentFillScreen',
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving changes immediately: $e');
    }
  }

  // Check if current settings have been modified from the current preset
  bool _hasUnsavedChanges() {
    // If we're not on a preset, always consider as having changes
    if (_currentPresetIndex < 0 ||
        _currentPresetIndex >= _availablePresets.length) {
      return true;
    }

    final currentPreset = _availablePresets[_currentPresetIndex];

    // Compare image path - most basic check
    if (_selectedImage != currentPreset.imagePath) {
      return true;
    }

    // Compare important settings that would be visually noticeable
    // This is a simplified comparison that only checks key properties

    // Check color settings
    if (_shaderSettings.colorEnabled != currentPreset.settings.colorEnabled) {
      return true;
    }

    // Check blur settings
    if (_shaderSettings.blurEnabled != currentPreset.settings.blurEnabled) {
      return true;
    }

    // Check noise settings
    if (_shaderSettings.noiseEnabled != currentPreset.settings.noiseEnabled) {
      return true;
    }

    // Check chromatic settings
    if (_shaderSettings.chromaticEnabled !=
        currentPreset.settings.chromaticEnabled) {
      return true;
    }

    // Check ripple settings
    if (_shaderSettings.rippleEnabled != currentPreset.settings.rippleEnabled) {
      return true;
    }

    // Check text settings - important for visual appearance
    if (_shaderSettings.textEnabled != currentPreset.settings.textEnabled) {
      return true;
    }

    if (_shaderSettings.textEnabled) {
      // Compare text content if text is enabled
      if (_shaderSettings.textLayoutSettings.textTitle !=
          currentPreset.settings.textLayoutSettings.textTitle) {
        return true;
      }

      if (_shaderSettings.textLayoutSettings.textSubtitle !=
          currentPreset.settings.textLayoutSettings.textSubtitle) {
        return true;
      }

      if (_shaderSettings.textLayoutSettings.textArtist !=
          currentPreset.settings.textLayoutSettings.textArtist) {
        return true;
      }
    }

    // If we reach here, we consider settings as not significantly changed
    return false;
  }

  // Method to find and clean up duplicate "Untitled" presets
  Future<void> _cleanupDuplicateUntitledPresets() async {
    try {
      // Get all existing presets
      final allPresets = await PresetController.getAllPresets();

      // Find all presets named "Untitled"
      final untitledPresets = allPresets
          .where((p) => p.name == "Untitled")
          .toList();

      debugPrint('Found ${untitledPresets.length} "Untitled" presets');

      // If we have more than one, keep only the most recent one
      if (untitledPresets.length > 1) {
        // Sort by creation date (newest first)
        untitledPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Keep the first one (most recent)
        final keepPreset = untitledPresets.first;

        // Store its ID as the current session's untitled preset
        _currentUntitledPresetId = keepPreset.id;

        debugPrint('Keeping most recent "Untitled" preset: ${keepPreset.id}');

        // Delete all others
        for (int i = 1; i < untitledPresets.length; i++) {
          final toDelete = untitledPresets[i];
          debugPrint('Deleting duplicate "Untitled" preset: ${toDelete.id}');
          await PresetController.deletePreset(toDelete.id);
        }

        // Force reload of presets
        setState(() {
          _presetsLoaded = false;
        });
        await _loadAvailablePresets();
      } else if (untitledPresets.length == 1) {
        // If we have exactly one, store its ID
        _currentUntitledPresetId = untitledPresets.first.id;
        debugPrint('Found one "Untitled" preset: ${untitledPresets.first.id}');
      }
    } catch (e) {
      debugPrint('Error cleaning up duplicate presets: $e');
    }
  }
}
