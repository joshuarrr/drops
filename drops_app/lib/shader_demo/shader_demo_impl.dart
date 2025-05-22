import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';

import 'utils/logging_utils.dart' as logging;
import 'utils/animation_utils.dart';
import 'controllers/effect_controller.dart';
import 'controllers/preset_dialogs.dart';
import 'controllers/preset_controller.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'models/shader_preset.dart';
import 'models/image_category.dart';

import 'views/effect_controls.dart';
import 'views/panel_container.dart';
import 'views/image_container.dart';
import 'views/text_overlay.dart';
import 'views/slideshow_view.dart';
import 'widgets/image_panel.dart';

import 'state/shader_demo_state.dart';
import 'services/preset_service.dart';
import 'services/asset_service.dart';
import 'controllers/slideshow_controller.dart';

/// The main Shader Demo implementation widget
class ShaderDemoImpl extends StatefulWidget {
  const ShaderDemoImpl({super.key});

  @override
  State<ShaderDemoImpl> createState() => _ShaderDemoImplState();
}

class _ShaderDemoImplState extends State<ShaderDemoImpl>
    with SingleTickerProviderStateMixin {
  // State management
  late ShaderDemoState _state;

  // Animation controller
  late AnimationController _controller;

  // Slideshow controller
  late SlideshowController _slideshowController;

  // Key for capturing the shader effect for thumbnails
  final GlobalKey _previewKey = GlobalKey();

  // Animation duration bounds (from ShaderAnimationUtils)
  static const int _minDurationMs =
      ShaderAnimationUtils.minDurationMs; // slowest
  static const int _maxDurationMs =
      ShaderAnimationUtils.maxDurationMs; // fastest

  // Flag to track if presets have been loaded at startup
  bool _presetsLoadedAtStartup = false;

  @override
  void initState() {
    super.initState();

    // Initialize state
    _state = ShaderDemoState();

    // Initialize effect controls
    EffectControls.initMusicController(
      settings: _state.shaderSettings,
      onSettingsChanged: (updatedSettings) {
        setState(() {
          _state.shaderSettings = updatedSettings;
        });
      },
    );

    // Load music tracks
    _loadMusicTracks();

    // Load persisted settings
    _loadShaderSettings();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(milliseconds: _minDurationMs),
      vsync: this,
    )..repeat();

    // Initialize slideshow controller
    _slideshowController = SlideshowController();

    // Load image assets
    _loadImageAssets();

    // Set immersive mode after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up system UI to be fully immersive
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // Clean up duplicate presets then load all available presets once
      _cleanupDuplicateUntitledPresetsAndLoadPresets();
    });

    // Don't load presets here, we'll do it after cleanup
    // _loadAvailablePresets();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideshowController.dispose();
    // Clean up the effect controls resources
    EffectControls.dispose();
    // Restore system UI when we leave this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // Load persisted shader settings
  Future<void> _loadShaderSettings() async {
    await _state.loadShaderSettings();
    setState(() {});
  }

  // Load image assets
  Future<void> _loadImageAssets() async {
    try {
      final images = await AssetService.loadImageAssets();

      setState(() {
        _state.coverImages = images['covers'] ?? [];
        _state.artistImages = images['artists'] ?? [];

        // Determine whether current persisted image is valid
        bool isPersistedValid =
            _state.selectedImage.isNotEmpty &&
            (_state.coverImages.contains(_state.selectedImage) ||
                _state.artistImages.contains(_state.selectedImage));

        if (!isPersistedValid) {
          // No valid persisted image → choose default
          if (_state.coverImages.isNotEmpty) {
            _state.imageCategory = ImageCategory.covers;
            _state.selectedImage = _state.coverImages.first;
          } else if (_state.artistImages.isNotEmpty) {
            _state.imageCategory = ImageCategory.artists;
            _state.selectedImage = _state.artistImages.first;
          } else {
            _state.selectedImage = '';
          }
        } else {
          // Update category to match persisted image
          _state.imageCategory =
              _state.coverImages.contains(_state.selectedImage)
              ? ImageCategory.covers
              : ImageCategory.artists;
        }
      });
    } catch (e, stack) {
      logging.EffectLogger.log(
        'Failed to load image assets: $e',
        level: logging.LogLevel.error,
      );
      logging.EffectLogger.log(stack.toString(), level: logging.LogLevel.error);
    }
  }

  // Load music tracks
  Future<void> _loadMusicTracks() async {
    try {
      final tracks = await AssetService.loadMusicTracks();

      if (tracks.isNotEmpty) {
        // Select the first track by default but don't play it if music is disabled
        final firstTrack = tracks[0];
        logging.EffectLogger.log('Setting initial track: $firstTrack');

        // Update settings BEFORE calling selectMusicTrack
        final updatedSettings = ShaderSettings.fromMap(
          _state.shaderSettings.toMap(),
        );
        updatedSettings.musicSettings.currentTrack = firstTrack;

        // Apply the settings first to ensure the controller knows about the track
        setState(() {
          _state.shaderSettings = updatedSettings;
        });

        // Only select the track, our modified selectMusicTrack will
        // check if music is enabled before playing
        Future.microtask(() {
          EffectControls.selectMusicTrack(firstTrack);
        });
      }
    } catch (e) {
      logging.EffectLogger.log(
        'Error loading music tracks: $e',
        level: logging.LogLevel.error,
      );
    }
  }

  // Load all available presets
  Future<void> _loadAvailablePresets() async {
    await _state.loadAvailablePresets();
    setState(() {});
  }

  // Clean up duplicate untitled presets and then load presets once
  Future<void> _cleanupDuplicateUntitledPresetsAndLoadPresets() async {
    try {
      // Get the presets and ID in one operation to avoid loading presets twice
      final result =
          await PresetService.cleanupDuplicateUntitledPresetsWithReturn();

      if (result.id != null) {
        setState(() {
          _state.currentUntitledPresetId = result.id;
        });
      }

      // Use the already loaded presets instead of loading them again
      if (result.presets != null) {
        setState(() {
          _state.availablePresets = result.presets!;
          _state.presetsLoaded = true;
          _state.findCurrentPresetIndex();
        });

        // Set a flag to indicate we've already loaded presets at startup
        _presetsLoadedAtStartup = true;
      } else {
        // Fallback to loading presets if something went wrong
        await _loadAvailablePresets();
      }
    } catch (e) {
      logging.EffectLogger.log(
        'Error during preset cleanup: $e',
        level: logging.LogLevel.error,
      );
      // Still try to load presets as fallback
      await _loadAvailablePresets();
    }
  }

  // Save changes immediately to prevent loss when entering slideshow mode
  Future<void> _saveChangesImmediately() async {
    // Don't trigger reload if we're still initializing
    final shouldReloadPresets = _presetsLoadedAtStartup;

    await PresetService.saveChangesImmediately(
      settings: _state.shaderSettings,
      imagePath: _state.selectedImage,
      previewKey: _previewKey,
      currentUntitledPresetId: _state.currentUntitledPresetId,
      availablePresets: _state.availablePresets,
      hasUnsavedChanges: _state.hasUnsavedChanges(),
      onPresetIdChanged: (id) {
        setState(() {
          _state.currentUntitledPresetId = id;
        });
      },
      onPresetIndexChanged: (index) {
        setState(() {
          _state.currentPresetIndex = index;
        });
      },
      onPresetsReloaded: () {
        // Only reload if we should - avoids redundant calls during initialization
        if (shouldReloadPresets) {
          setState(() {
            _state.presetsLoaded = false;
          });
          _loadAvailablePresets();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkTheme = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Shaders',
      showAppBar:
          !_state.isPresetDialogOpen, // Hide app bar when preset dialog is open
      showBackButton: true,
      currentIndex: 1, // Demos tab
      extendBodyBehindAppBar: true,
      appBarBackgroundColor: Colors.transparent,
      appBarElevation: 0,
      appBarActions: [_buildAppBarActions()],
      body: GestureDetector(
        // Main screen tap handler for toggling control panels
        onTap: _handleMainScreenTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Show presets based on PageView when controls are hidden and we have loaded presets
            // Otherwise show the preview with current settings
            if (!_state.showControls && !_state.isPresetDialogOpen)
              _buildSlideshowView()
            else
              _buildPreviewWithCurrentSettings(),

            // Controls overlay
            if (_state.showControls && !_state.isPresetDialogOpen)
              _buildControlsOverlay(isDarkTheme),

            // Modal overlay when control panel is shown
            if (_state.showControls &&
                _state.showAspectSliders &&
                !_state.isPresetDialogOpen)
              _buildModalOverlay(),

            // The actual control panel
            if (_state.showControls &&
                _state.showAspectSliders &&
                !_state.isPresetDialogOpen)
              _buildAspectControlPanel(),
          ],
        ),
      ),
    );
  }

  // Build app bar actions
  Widget _buildAppBarActions() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'save_preset') {
          _handleSavePreset();
        } else if (value == 'update_preset') {
          _handleUpdatePreset();
        } else if (value == 'load_preset') {
          _handleLoadPreset();
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
        if (_state.currentPresetIndex >= 0 &&
            _state.currentPresetIndex < _state.availablePresets.length) {
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
    );
  }

  // Handle save preset menu option
  void _handleSavePreset() {
    PresetDialogs.showSavePresetDialog(
      context: context,
      settings: _state.shaderSettings,
      imagePath: _state.selectedImage,
      previewKey: _previewKey,
    ).then((_) {
      // Reload available presets immediately after saving
      setState(() {
        _state.presetsLoaded = false; // Force reload of presets
      });
      _loadAvailablePresets();
    });
  }

  // Handle update preset menu option
  void _handleUpdatePreset() {
    // Make sure we have a current preset to update
    if (_state.currentPresetIndex >= 0 &&
        _state.currentPresetIndex < _state.availablePresets.length) {
      final currentPreset = _state.availablePresets[_state.currentPresetIndex];

      PresetDialogs.showUpdatePresetDialog(
        context: context,
        preset: currentPreset,
        newSettings: _state.shaderSettings,
        previewKey: _previewKey,
      ).then((_) {
        // Reload available presets immediately after updating
        setState(() {
          _state.presetsLoaded = false; // Force reload of presets
        });
        _loadAvailablePresets();
      });
    }
  }

  // Handle load preset menu option
  void _handleLoadPreset() {
    setState(() {
      _state.isPresetDialogOpen = true;
    });

    PresetDialogs.showLoadPresetDialog(
      context: context,
      onPresetLoaded: (preset) {
        _applyPreset(preset);
        // Update the current preset index
        _state.findCurrentPresetIndex();
      },
    ).then((_) {
      // This runs when the dialog is closed (either with a preset or without)
      setState(() {
        _state.isPresetDialogOpen = false;
      });

      // Refresh available presets in case any were added or deleted
      _loadAvailablePresets();
    });
  }

  // Handle main screen tap
  void _handleMainScreenTap() async {
    // Always save the current state when tapping the screen, regardless of hasUnsavedChanges()
    if (_state.showControls) {
      // First save current shader settings to shared preferences
      _state.saveShaderSettings();

      // Force save with proper margin and fillScreen values to ensure they're preserved
      final Map<String, dynamic> specificSettings = {
        'fillScreen': _state.shaderSettings.fillScreen,
        'fitScreenMargin':
            _state.shaderSettings.textLayoutSettings.fitScreenMargin,
      };

      logging.EffectLogger.log(
        'Saving current settings before entering slideshow - margin: ${specificSettings['fitScreenMargin']}, fillScreen: ${specificSettings['fillScreen']}',
      );

      // Save current state as untitled preset
      final newPreset = await PresetService.saveUntitledPreset(
        settings: _state.shaderSettings,
        imagePath: _state.selectedImage,
        previewKey: _previewKey,
        specificSettings: specificSettings, // Pass specific settings explicitly
      );

      if (newPreset != null) {
        setState(() {
          _state.currentPresetIndex = _state.availablePresets.indexWhere(
            (p) => p.id == newPreset.id,
          );

          // Clear unsaved settings since we've now saved to a preset
          _state.unsavedSettings = null;
          _state.unsavedImage = null;
          _state.unsavedCategory = null;

          // Store current untitled preset ID
          _state.currentUntitledPresetId = newPreset.id;
        });

        // Reload presets to ensure we have the latest data
        await _loadAvailablePresets();
      }
    }

    setState(() {
      // Tap on screen hides both top controls and effect sliders
      _state.showControls = !_state.showControls;
      if (!_state.showControls) {
        _state.showAspectSliders = false;
      }
    });
  }

  // Build the slideshow view
  Widget _buildSlideshowView() {
    // Ensure presets are loaded
    if (!_state.presetsLoaded) {
      // Show a loading indicator while presets are being loaded
      return const Center(child: CircularProgressIndicator());
    }

    // Get a sorted copy of the presets based on the current preset's sort method
    List<ShaderPreset> sortedPresets = _ensurePresetsUseSavedSortMethod();

    // Filter out presets hidden from slideshow
    final visiblePresets = _slideshowController.getVisiblePresets(
      sortedPresets,
    );

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
    if (_state.currentPresetIndex >= 0 &&
        _state.currentPresetIndex < _state.availablePresets.length) {
      final currentPresetId =
          _state.availablePresets[_state.currentPresetIndex].id;
      // Find this preset in the filtered visible list
      final visibleIndex = visiblePresets.indexWhere(
        (p) => p.id == currentPresetId,
      );
      if (visibleIndex >= 0) {
        startIndex = visibleIndex;
      }
    }

    // CRITICAL: Force rebuild of PageController if the index has changed significantly
    if (_slideshowController.pageController.hasClients &&
        (_slideshowController.pageController.page?.round() ?? 0) !=
            startIndex) {
      // Create a new controller at the correct index
      _slideshowController = SlideshowController(initialPage: startIndex);
    }
    // Initialize page controller to current preset index if needed
    else if (!_state.isScrolling &&
        _slideshowController.pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Start with current preset
        if (!_state.isScrolling) {
          _slideshowController.resetToPage(startIndex);
        }
      });
    }

    return SlideshowView(
      presets: visiblePresets,
      pageController: _slideshowController.pageController,
      animationController: _controller,
      onPageChanged: (index) {
        if (!_state.isScrolling) {
          setState(() {
            // Find the preset ID from the visible presets list
            final selectedPresetId = visiblePresets[index].id;

            // Find the index of this preset in the full presets list
            _state.currentPresetIndex = _state.availablePresets.indexWhere(
              (p) => p.id == selectedPresetId,
            );

            // Apply the selected preset
            if (_state.currentPresetIndex >= 0) {
              // Apply the preset immediately, no need to wait
              _applyPreset(
                _state.availablePresets[_state.currentPresetIndex],
                showControls: false,
              );
            }
          });
        }
      },
    );
  }

  // Apply preset settings
  void _applyPreset(ShaderPreset preset, {bool showControls = true}) {
    // Check if this preset has a sort method that should be applied
    PresetSortMethod? sortMethodToApply = preset.sortMethod;

    // Log the specificSettings before applying them
    if (preset.specificSettings != null) {
      logging.EffectLogger.log(
        "Preset '${preset.name}' specificSettings: ${preset.specificSettings!.keys.join(', ')}",
      );

      if (preset.specificSettings!.containsKey('fitScreenMargin')) {
        logging.EffectLogger.log(
          "Preset margin: ${preset.specificSettings!['fitScreenMargin']}",
        );
      }

      if (preset.specificSettings!.containsKey('fillScreen')) {
        logging.EffectLogger.log(
          "Preset fillScreen: ${preset.specificSettings!['fillScreen']}",
        );
      }
    } else {
      logging.EffectLogger.log(
        "Preset '${preset.name}' has NO specificSettings",
      );
    }

    logging.EffectLogger.log(
      "Applying preset '${preset.name}' with text enabled: ${preset.settings.textLayoutSettings.textEnabled}",
    );

    // Apply the preset using our state manager
    setState(() {
      _state.applyPreset(preset, showControlsAfter: showControls);
    });

    // Verify that the margin was applied correctly
    logging.EffectLogger.log(
      "After applying preset: margin=${_state.shaderSettings.textLayoutSettings.fitScreenMargin}, " +
          "fillScreen=${_state.shaderSettings.fillScreen}",
    );

    // Force controller to restart animation to ensure effects are visible
    _controller.reset();
    _controller.repeat();

    // Save changes to persistent storage
    _state.saveShaderSettings();

    // If a preset with random sort method was loaded, immediately sort the presets
    if (sortMethodToApply == PresetSortMethod.random) {
      // Force re-loading and sorting of presets to ensure correct order for navigation
      _reloadAndSortPresets(preset);
    }
  }

  // Reload and sort presets based on a specific preset's sort method
  Future<void> _reloadAndSortPresets(ShaderPreset preset) async {
    if (!_state.presetsLoaded || preset.sortMethod == null) return;

    try {
      final allPresets = await PresetController.getAllPresets();
      final sortedPresets = _slideshowController.sortPresets(
        allPresets,
        preset.sortMethod,
        currentPreset: preset,
      );

      setState(() {
        _state.availablePresets = sortedPresets;
        // Find the current preset's index in the sorted list
        _state.currentPresetIndex = sortedPresets.indexWhere(
          (p) => p.id == preset.id,
        );
        if (_state.currentPresetIndex < 0 && sortedPresets.isNotEmpty) {
          _state.currentPresetIndex = 0;
        }
      });
    } catch (e) {
      logging.EffectLogger.log(
        'Error reloading presets for sort method: $e',
        level: logging.LogLevel.error,
      );
    }
  }

  // Ensure presets are sorted according to the current preset's saved sort method
  List<ShaderPreset> _ensurePresetsUseSavedSortMethod() {
    // If we're on a preset (not current state) and it has a sort method, apply it
    if (_state.currentPresetIndex >= 0 &&
        _state.currentPresetIndex < _state.availablePresets.length) {
      final currentPreset = _state.availablePresets[_state.currentPresetIndex];
      if (currentPreset.sortMethod != null) {
        // Return a sorted copy of the presets
        return _slideshowController.sortPresets(
          _state.availablePresets,
          currentPreset.sortMethod,
          currentPreset: currentPreset,
        );
      }
    }

    // No sort method or no current preset - return the original list
    return List<ShaderPreset>.from(_state.availablePresets);
  }

  // Build the preview with current settings
  Widget _buildPreviewWithCurrentSettings() {
    return RepaintBoundary(
      key: _previewKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildShaderEffect(),
          // Explicitly add text overlay to ensure it's captured in thumbnails
          if (_state.shaderSettings.textLayoutSettings.textEnabled &&
              (_state.shaderSettings.textLayoutSettings.textTitle.isNotEmpty ||
                  _state
                      .shaderSettings
                      .textLayoutSettings
                      .textSubtitle
                      .isNotEmpty ||
                  _state
                      .shaderSettings
                      .textLayoutSettings
                      .textArtist
                      .isNotEmpty))
            TextOverlay(
              settings: _state.shaderSettings,
              animationValue: _controller.value,
            ),
        ],
      ),
    );
  }

  // Build the main shader effect
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
          imagePath: _state.selectedImage,
          settings: _state.shaderSettings,
        ),
        builder: (context, baseImage) {
          // Use the raw controller value as the base time
          final double animationValue = _controller.value;

          // Check if any effect is targeted to image
          final bool shouldApplyEffectsToImage =
              (_state.shaderSettings.colorEnabled &&
                  _state.shaderSettings.colorSettings.applyToImage) ||
              (_state.shaderSettings.blurEnabled &&
                  _state.shaderSettings.blurSettings.applyToImage) ||
              (_state.shaderSettings.noiseEnabled &&
                  _state.shaderSettings.noiseSettings.applyToImage) ||
              (_state.shaderSettings.rainEnabled &&
                  _state.shaderSettings.rainSettings.applyToImage) ||
              (_state.shaderSettings.chromaticEnabled &&
                  _state.shaderSettings.chromaticSettings.applyToImage) ||
              (_state.shaderSettings.rippleEnabled &&
                  _state.shaderSettings.rippleSettings.applyToImage);

          // Apply all enabled effects using the shared base time
          Widget effectsWidget = shouldApplyEffectsToImage
              ? Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: EffectController.applyEffects(
                    child: baseImage!,
                    settings: _state.shaderSettings,
                    animationValue: animationValue,
                  ),
                )
              : baseImage!; // Don't apply effects if none target the image

          // Build only the image with effects, text overlay is added separately
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

  // Build the controls overlay
  Widget _buildControlsOverlay(bool isDarkTheme) {
    return Positioned(
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
                  settings: _state.shaderSettings,
                  isCurrentImageDark: isDarkTheme,
                  onAspectToggled: (aspect, enabled) {
                    setState(() {
                      // Toggle the enabled state of the selected aspect
                      switch (aspect) {
                        case ShaderAspect.color:
                          _state.shaderSettings.colorEnabled = enabled;
                          break;
                        case ShaderAspect.blur:
                          _state.shaderSettings.blurEnabled = enabled;
                          break;
                        case ShaderAspect.image:
                          // No enable/disable for image aspect
                          break;
                        case ShaderAspect.text:
                          _state.shaderSettings.textEnabled = enabled;
                          break;
                        case ShaderAspect.noise:
                          _state.shaderSettings.noiseEnabled = enabled;
                          break;
                        case ShaderAspect.textfx:
                          _state.shaderSettings.textfxEnabled = enabled;
                          break;
                        case ShaderAspect.rain:
                          _state.shaderSettings.rainEnabled = enabled;
                          break;
                        case ShaderAspect.chromatic:
                          _state.shaderSettings.chromaticEnabled = enabled;
                          break;
                        case ShaderAspect.ripple:
                          _state.shaderSettings.rippleEnabled = enabled;
                          break;
                        case ShaderAspect.music:
                          _state.shaderSettings.musicEnabled = enabled;
                          // When music is disabled, pause any currently playing music
                          if (!enabled &&
                              _state.shaderSettings.musicSettings.isPlaying) {
                            EffectControls.pauseMusic();
                          } else if (enabled &&
                              !_state.shaderSettings.musicSettings.isPlaying &&
                              _state
                                  .shaderSettings
                                  .musicSettings
                                  .currentTrack
                                  .isNotEmpty) {
                            // When music is enabled and there's a track selected but not playing, start playback
                            EffectControls.playMusic();
                          }
                          break;
                        case ShaderAspect.cymatics:
                          _state.shaderSettings.cymaticsEnabled = enabled;
                          break;
                      }
                    });
                    _state.saveShaderSettings();

                    // Add this line to save changes to the preset immediately
                    _saveChangesImmediately();
                  },
                  onAspectSelected: (aspect) {
                    setState(() {
                      // Check if user is selecting a new aspect or tapping the existing one
                      final bool selectingNewAspect =
                          _state.selectedAspect != aspect;
                      _state.selectedAspect = aspect;

                      // If selecting a new aspect, always show sliders
                      if (selectingNewAspect) {
                        _state.showAspectSliders = true;

                        // Auto-enable text effects if selecting the TextFx aspect and text is enabled
                        if (aspect == ShaderAspect.textfx &&
                            _state.shaderSettings.textEnabled &&
                            !_state.shaderSettings.textfxEnabled) {
                          _state.shaderSettings.textfxEnabled = true;
                        }
                      } else {
                        // If tapping the same aspect, toggle sliders
                        _state.showAspectSliders = !_state.showAspectSliders;
                      }
                    });
                  },
                  hidden: _state.showAspectSliders,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build the modal overlay
  Widget _buildModalOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        // Use a specific hit test behavior that allows taps to go through to children
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          setState(() {
            _state.showAspectSliders = false;
          });
          _state.saveShaderSettings();
          if (_state.hasUnsavedChanges()) {
            PresetService.saveUntitledPreset(
              settings: _state.shaderSettings,
              imagePath: _state.selectedImage,
              previewKey: _previewKey,
            );
          }
        },
        child: Container(color: Colors.black.withOpacity(0.1)),
      ),
    );
  }

  // Build the aspect control panel
  Widget _buildAspectControlPanel() {
    final theme = Theme.of(context);
    final Color sliderColor = theme.colorScheme.onSurface;

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      bottom: 20, // Add a bottom constraint to ensure panel can expand properly
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
            child: _buildAspectParameterSliders(sliderColor),
          ),
        ),
      ),
    );
  }

  // Build parameter sliders for the selected aspect
  Widget _buildAspectParameterSliders(Color sliderColor) {
    return PanelContainer(
      isDark: Theme.of(context).brightness == Brightness.dark,
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
              if (_state.selectedAspect == ShaderAspect.image) ...[
                // Use ImagePanel widget for image controls
                ImagePanel(
                  settings: _state.shaderSettings,
                  onSettingsChanged: (settings) {
                    setState(() {
                      _state.shaderSettings = settings;
                    });
                    // Save to shared preferences
                    _state.saveShaderSettings();

                    // CRITICAL FIX: Immediately save changes to current preset or create a new untitled preset
                    // This ensures margin settings are preserved when entering slideshow mode
                    _saveChangesImmediately();
                  },
                  sliderColor: sliderColor,
                  context: context,
                  coverImages: _state.coverImages,
                  artistImages: _state.artistImages,
                  selectedImage: _state.selectedImage,
                  imageCategory: _state.imageCategory,
                  onImageSelected: (path) {
                    setState(() {
                      _state.selectedImage = path;
                    });
                    _state.saveShaderSettings();
                    // Also save immediately to preset
                    _saveChangesImmediately();
                  },
                  onCategoryChanged: (category) {
                    setState(() {
                      _state.imageCategory = category;

                      // Ensure selected image belongs to category
                      final images = _state.getCurrentImages();
                      if (!images.contains(_state.selectedImage) &&
                          images.isNotEmpty) {
                        _state.selectedImage = images.first;
                      }
                    });
                    _state.saveShaderSettings();
                    // Also save immediately to preset
                    _saveChangesImmediately();
                  },
                ),
              ],
              if (_state.selectedAspect != ShaderAspect.image) ...[
                ...EffectControls.buildSlidersForAspect(
                  aspect: _state.selectedAspect,
                  settings: _state.shaderSettings,
                  onSettingsChanged: (settings) {
                    setState(() {
                      _state.shaderSettings = settings;
                    });
                    _state.saveShaderSettings();

                    // Add this line to immediately save changes to the preset
                    _saveChangesImmediately();
                  },
                  sliderColor: sliderColor,
                  context: context,
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
