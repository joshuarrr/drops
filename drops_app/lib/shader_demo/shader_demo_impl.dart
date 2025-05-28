/* TODO: Before adding to this file, analyze and suggest refactor to reduce file size */

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

      // CRITICAL FIX: Update the shared tracks list in EffectControls
      EffectControls.musicTracks = tracks;

      setState(() {
        // This will trigger a UI update with the new tracks
      });

      if (tracks.isNotEmpty) {
        // Select the first track by default but don't play it if music is disabled
        final firstTrack = tracks[0];
        logging.EffectLogger.log('Setting initial track: $firstTrack');

        // FIXED: Don't update settings directly here, let the selectMusicTrack handle it
        // This avoids the double "Current track set to" log messages

        // CRITICAL FIX: Make sure the track is properly selected even if music is disabled
        Future.microtask(() {
          // Call the select track method which properly handles the track selection
          EffectControls.selectMusicTrack(firstTrack);

          // Only play if music is enabled
          if (_state.shaderSettings.musicEnabled) {
            EffectControls.playMusic();
          }
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

        // CRITICAL FIX: Automatically apply the latest "Untitled" preset if it exists
        // This ensures user's recent changes (like background color) are restored
        if (result.id != null) {
          final untitledPreset = _state.availablePresets.firstWhere(
            (preset) => preset.id == result.id,
            orElse: () => _state.availablePresets.first,
          );

          logging.EffectLogger.log(
            'Auto-applying latest "Untitled" preset with background color: 0x${untitledPreset.settings.backgroundSettings.backgroundColor.value.toRadixString(16).padLeft(8, '0')}',
          );

          // CRITICAL FIX: Clear SharedPreferences first to prevent stale data loading
          await _clearSharedPreferences();

          // Apply the preset to restore the user's recent changes
          setState(() {
            _state.applyPreset(untitledPreset, showControlsAfter: true);
          });

          // Immediately save the applied settings to SharedPreferences to ensure consistency
          await _state.saveShaderSettings();

          logging.EffectLogger.log(
            'Preset applied and saved to SharedPreferences with background color: 0x${_state.shaderSettings.backgroundSettings.backgroundColor.value.toRadixString(16).padLeft(8, '0')}',
          );

          // Set a flag to indicate we've already loaded presets at startup
          _presetsLoadedAtStartup = true;
        }
      } else {
        // Fallback to loading presets if something went wrong
        await _loadAvailablePresets();
        _presetsLoadedAtStartup = true;
      }
    } catch (e) {
      logging.EffectLogger.log(
        'Error during preset cleanup: $e',
        level: logging.LogLevel.error,
      );
      // Still try to load presets as fallback
      await _loadAvailablePresets();
      _presetsLoadedAtStartup = true;
    }
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

      // Store current values in specificSettings to ensure they're preserved
      final Map<String, dynamic> specificSettings = {
        'fillScreen': _state.shaderSettings.fillScreen,
        'fitScreenMargin':
            _state.shaderSettings.textLayoutSettings.fitScreenMargin,
      };

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

    // Apply the preset using our state manager
    setState(() {
      _state.applyPreset(preset, showControlsAfter: showControls);
    });

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
        child: _state.shaderSettings.imageEnabled
            ? ImageContainer(
                imagePath: _state.selectedImage,
                settings: _state.shaderSettings,
              )
            : null, // No image when disabled
        builder: (context, baseImage) {
          // Use the raw controller value as the base time
          final double animationValue = _controller.value;

          Widget effectsWidget;

          // If image is disabled, just show background
          if (!_state.shaderSettings.imageEnabled) {
            effectsWidget = Container(
              width: width,
              height: height,
              color: Colors
                  .transparent, // Just transparent, background color will be applied below
            );
          } else {
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
            effectsWidget = shouldApplyEffectsToImage
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
          }

          // Build only the image with effects, text overlay is added separately
          return Container(
            color: _state.shaderSettings.backgroundEnabled
                ? _state.shaderSettings.backgroundSettings.backgroundColor
                : Colors.black,
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
                        case ShaderAspect.background:
                          _state.shaderSettings.backgroundEnabled = enabled;
                          break;
                        case ShaderAspect.color:
                          _state.shaderSettings.colorEnabled = enabled;
                          break;
                        case ShaderAspect.blur:
                          _state.shaderSettings.blurEnabled = enabled;
                          break;
                        case ShaderAspect.image:
                          _state.shaderSettings.imageEnabled = enabled;
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
                          // Preserve the current image settings when toggling music
                          final currentFillScreen =
                              _state.shaderSettings.fillScreen;
                          final currentMargin = _state
                              .shaderSettings
                              .textLayoutSettings
                              .fitScreenMargin;

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
                            // CRITICAL FIX: When music is enabled and there's a track selected but not playing,
                            // first update state to ensure we have a valid track
                            EffectControls.selectMusicTrack(
                              _state.shaderSettings.musicSettings.currentTrack,
                            );

                            // Now play the track
                            EffectControls.playMusic();
                          }

                          // Ensure we maintain the image settings after toggling music
                          _state.shaderSettings.fillScreen = currentFillScreen;
                          _state
                                  .shaderSettings
                                  .textLayoutSettings
                                  .fitScreenMargin =
                              currentMargin;
                          break;
                        case ShaderAspect.cymatics:
                          _state.shaderSettings.cymaticsEnabled = enabled;
                          break;
                      }
                    });
                    _state.saveShaderSettings();

                    // Save changes to the preset immediately
                    PresetService.saveChangesImmediately(
                      settings: _state.shaderSettings,
                      imagePath: _state.selectedImage,
                      previewKey: _previewKey,
                      currentUntitledPresetId: _state.currentUntitledPresetId,
                      availablePresets: _state.availablePresets,
                      hasUnsavedChanges:
                          true, // Force save since we know there are changes
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
                        if (_presetsLoadedAtStartup) {
                          setState(() {
                            _state.presetsLoaded = false;
                          });
                          _loadAvailablePresets();
                        }
                      },
                    );
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

                        // Auto-enable background if selecting the Background aspect and it's not enabled
                        if (aspect == ShaderAspect.background &&
                            !_state.shaderSettings.backgroundEnabled) {
                          _state.shaderSettings.backgroundEnabled = true;
                        }

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
                    _state.saveShaderSettings();

                    // Save changes to the preset immediately
                    PresetService.saveChangesImmediately(
                      settings:
                          settings, // Use the updated settings parameter, not _state.shaderSettings
                      imagePath: _state.selectedImage,
                      previewKey: _previewKey,
                      currentUntitledPresetId: _state.currentUntitledPresetId,
                      availablePresets: _state.availablePresets,
                      hasUnsavedChanges:
                          true, // Force save since we know there are changes
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
                        if (_presetsLoadedAtStartup) {
                          setState(() {
                            _state.presetsLoaded = false;
                          });
                          _loadAvailablePresets();
                        }
                      },
                    );
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
                    PresetService.saveChangesImmediately(
                      settings: _state.shaderSettings,
                      imagePath: path, // Use the new path
                      previewKey: _previewKey,
                      currentUntitledPresetId: _state.currentUntitledPresetId,
                      availablePresets: _state.availablePresets,
                      hasUnsavedChanges: true,
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
                        if (_presetsLoadedAtStartup) {
                          setState(() {
                            _state.presetsLoaded = false;
                          });
                          _loadAvailablePresets();
                        }
                      },
                    );
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
                    PresetService.saveChangesImmediately(
                      settings: _state.shaderSettings,
                      imagePath: _state.selectedImage,
                      previewKey: _previewKey,
                      currentUntitledPresetId: _state.currentUntitledPresetId,
                      availablePresets: _state.availablePresets,
                      hasUnsavedChanges: true,
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
                        if (_presetsLoadedAtStartup) {
                          setState(() {
                            _state.presetsLoaded = false;
                          });
                          _loadAvailablePresets();
                        }
                      },
                    );
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

                    // Save changes to the preset immediately
                    PresetService.saveChangesImmediately(
                      settings:
                          settings, // Use the updated settings parameter, not _state.shaderSettings
                      imagePath: _state.selectedImage,
                      previewKey: _previewKey,
                      currentUntitledPresetId: _state.currentUntitledPresetId,
                      availablePresets: _state.availablePresets,
                      hasUnsavedChanges:
                          true, // Force save since we know there are changes
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
                        if (_presetsLoadedAtStartup) {
                          setState(() {
                            _state.presetsLoaded = false;
                          });
                          _loadAvailablePresets();
                        }
                      },
                    );
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

  // Clear SharedPreferences shader settings key only
  Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ShaderDemoState.kShaderSettingsKey);
    logging.EffectLogger.log('Cleared stale SharedPreferences shader settings');
  }
}
