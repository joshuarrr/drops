import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/shader_controller.dart';

import '../controllers/effect_controller.dart';
import '../controllers/effect_controls_bridge.dart';
import '../views/effect_controls.dart';
import '../views/preset_menu.dart';
import '../views/image_container.dart';
import '../views/text_overlay.dart';
import '../../common/app_scaffold.dart';
import 'dart:math' as math;
import '../services/thumbnail_service.dart';

/// Main screen for shader demo V2
/// Uses Provider pattern and Stack layout for overlay controls
class ShaderDemoScreen extends StatefulWidget {
  const ShaderDemoScreen({Key? key}) : super(key: key);

  @override
  State<ShaderDemoScreen> createState() => _ShaderDemoScreenState();
}

class _ShaderDemoScreenState extends State<ShaderDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ShaderController _shaderController;
  late PageController _pageController;
  bool _isInitialized = false;

  // Key for capturing thumbnails like V1
  final GlobalKey _previewKey = GlobalKey();

  // DEBUG: Track animation state changes
  bool? _lastAnimationState;
  int _effectsStackBuildCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with a sensible default duration
    // This will be updated dynamically based on animation speed settings
    _animationController = AnimationController(
      duration: const Duration(seconds: 10), // Default, will be updated
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Listen to animation controller status changes to trigger rebuilds
    _animationController.addStatusListener((status) {
      if (mounted) {
        setState(() {
          // Trigger rebuild when animation starts/stops to ensure AnimatedBuilder works
        });
      }
    });

    // DON'T start animation loop here - start it only when needed
    // _animationController.repeat();

    // Initialize shader controller
    _initializeController();
  }

  Future<void> _initializeController() async {
    _shaderController = ShaderController();
    await _shaderController.initialize();

    // Initialize PageController with current position from NavigationController
    _pageController = PageController(
      initialPage: _shaderController.navigationController.currentPosition,
    );

    // Listen to navigation changes to sync PageController
    _shaderController.navigationController.addListener(_onNavigationChanged);

    // Connect the bridge to the controller
    EffectControls.setController(_shaderController);

    // Listen to shader controller changes to optimize animation controller
    _shaderController.addListener(_onShaderSettingsChanged);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      // Schedule animation state check for next frame to ensure everything is fully initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateAnimationControllerState();
        }
      });
    }
  }

  /// Optimize animation controller based on whether any animations are actually active
  void _onShaderSettingsChanged() {
    _updateAnimationControllerState();
  }

  /// Start or stop animation controller based on whether any animations are active
  void _updateAnimationControllerState() {
    if (!mounted || !_isInitialized) return;

    final bool hasActiveAnimations = _hasActiveAnimations();

    // Calculate the required duration based on fastest active animation
    if (hasActiveAnimations) {
      final Duration requiredDuration = _calculateRequiredAnimationDuration();

      // Update controller duration if it has changed significantly
      if ((_animationController.duration! - requiredDuration).inMilliseconds
              .abs() >
          100) {
        final bool wasAnimating = _animationController.isAnimating;
        final double currentProgress = _animationController.value;

        // Stop current animation to change duration
        if (wasAnimating) {
          _animationController.stop();
        }

        // Update duration
        _animationController.duration = requiredDuration;

        // Restart from current progress if it was animating
        if (wasAnimating) {
          _animationController.forward(from: currentProgress);
          _animationController.repeat();
        }

        // print(
          "[ShaderDemoScreen] Updated animation duration to ${requiredDuration.inMilliseconds}ms",
        );
      }
    }

    // Only log significant animation controller state changes
    if (hasActiveAnimations && !_animationController.isAnimating) {
      // Start animation when needed
      // print("[ShaderDemoScreen] Starting animation controller");
      _animationController.repeat();
    } else if (!hasActiveAnimations && _animationController.isAnimating) {
      // Stop animation when not needed to prevent unnecessary rebuilds
      // print("[ShaderDemoScreen] Stopping animation controller");
      _animationController.stop();
      _animationController.reset();
    }
  }

  /// Calculate the required animation duration based on the fastest active animation
  Duration _calculateRequiredAnimationDuration() {
    if (!_isInitialized) return const Duration(seconds: 10);

    final settings = _shaderController.settings;
    double fastestSpeed = 0.0;

    // Find the fastest (highest) speed among all active animations
    if (settings.blurSettings.blurAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.blurSettings.blurAnimOptions.speed,
      );
    }
    if (settings.colorSettings.colorAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.colorSettings.colorAnimOptions.speed,
      );
    }
    if (settings.colorSettings.overlayAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.colorSettings.overlayAnimOptions.speed,
      );
    }
    if (settings.noiseSettings.noiseAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.noiseSettings.noiseAnimOptions.speed,
      );
    }
    if (settings.rainSettings.rainAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.rainSettings.rainAnimOptions.speed,
      );
    }
    if (settings.chromaticSettings.chromaticAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.chromaticSettings.animOptions.speed,
      );
    }
    if (settings.rippleSettings.rippleAnimated) {
      fastestSpeed = math.max(
        fastestSpeed,
        settings.rippleSettings.rippleAnimOptions.speed,
      );
    }

    // Map speed (0.0-1.0) to duration (30s to 0.5s)
    // Use the fastest speed to set controller duration
    final double durationSeconds = 30.0 - (fastestSpeed * 29.5); // 30s to 0.5s
    final int durationMs = (durationSeconds * 1000).round();

    return Duration(milliseconds: durationMs);
  }

  /// Check if any shader effects have animations enabled
  bool _hasActiveAnimations() {
    if (!_isInitialized) return false;

    final settings = _shaderController.settings;
    final hasAnimations =
        settings.blurSettings.blurAnimated ||
        settings.colorSettings.colorAnimated ||
        settings.noiseSettings.noiseAnimated ||
        settings.rainSettings.rainAnimated ||
        settings.chromaticSettings.chromaticAnimated ||
        settings.rippleSettings.rippleAnimated;

    // DEBUG: Log animation state changes
    if (_lastAnimationState != hasAnimations) {
      // print("[ShaderDemoScreen] Animation state changed to: $hasAnimations");
      if (hasAnimations) {
        // print(
          "  - Active animations: " +
              "blur:${settings.blurSettings.blurAnimated}, " +
              "color:${settings.colorSettings.colorAnimated}, " +
              "noise:${settings.noiseSettings.noiseAnimated}, " +
              "rain:${settings.rainSettings.rainAnimated}, " +
              "chromatic:${settings.chromaticSettings.chromaticAnimated}, " +
              "ripple:${settings.rippleSettings.rippleAnimated}",
        );
      }
      _lastAnimationState = hasAnimations;
    }

    return hasAnimations;
  }

  /// Sync PageController with NavigationController changes
  void _onNavigationChanged() {
    if (!_isInitialized || !_pageController.hasClients) return;

    final targetPage = _shaderController.navigationController.currentPosition;
    final currentPage = _pageController.page?.round() ?? 0;

    if (targetPage != currentPage) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _pageController.dispose();
      _shaderController.navigationController.removeListener(
        _onNavigationChanged,
      );
      _shaderController.removeListener(_onShaderSettingsChanged);
      _shaderController.dispose();
      // Disconnect the bridge
      EffectControls.setController(null);
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isInitialized) {
      return AppScaffold(
        title: 'Shaders',
        showBackButton: true,
        currentIndex: 1,
        appBarBackgroundColor: Colors.transparent,
        appBarElevation: 0,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _shaderController,
      child: Consumer<ShaderController>(
        builder: (context, controller, child) {
          return AppScaffold(
            title: 'Shaders',
            showBackButton: true,
            currentIndex: 1,
            extendBodyBehindAppBar: true,
            appBarBackgroundColor: Colors.transparent,
            appBarElevation: 0,
            appBarActions: [_buildAppBarActions()],
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Main shader effect area with tap handling
                _buildShaderArea(controller, theme),

                // Controls overlay (toggleable) - this should handle its own events
                if (controller.controlsVisible)
                  _buildControlsOverlay(controller, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build app bar actions (similar to V1)
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
        ];

        return items;
      },
    );
  }

  void _handleSavePreset() {
    _showSaveDialog(_shaderController, Theme.of(context));
  }

  void _handleUpdatePreset() {
    // TODO: Implement update preset functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update Preset functionality coming soon')),
    );
  }

  void _handleLoadPreset() {
    _showPresetMenu();
  }

  /// Build the main shader effect area with vertical PageView navigation
  Widget _buildShaderArea(ShaderController controller, ThemeData theme) {
    final navigatorOrder = controller.navigationController.navigatorOrder;

    // If no presets, show current content
    if (navigatorOrder.isEmpty) {
      final Widget contentWidget = _buildContentWidget(controller);
      return Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => controller.toggleControls(),
          child: Container(
            color: Colors.black,
            child: RepaintBoundary(
              key: _previewKey,
              child: _buildEffectsStack(controller, contentWidget),
            ),
          ),
        ),
      );
    }

    // Build PageView with vertical scrolling for TikTok-style navigation
    return Positioned.fill(
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: navigatorOrder.length,
        onPageChanged: (index) {
          // Update navigation controller position when user swipes
          controller.navigationController.navigateToPosition(index);
        },
        itemBuilder: (context, index) {
          final preset = navigatorOrder[index];
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => controller.toggleControls(),
            child: Container(
              color: Colors.black,
              child: RepaintBoundary(
                key: index == controller.navigationController.currentPosition
                    ? _previewKey
                    : null,
                child: _buildPresetView(preset, controller),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build a preset view for the PageView
  Widget _buildPresetView(preset, ShaderController controller) {
    // Create content widget for this preset
    Widget contentWidget;
    if (preset.settings.imageEnabled) {
      contentWidget = ImageContainer(
        imagePath: preset.imagePath,
        settings: preset.settings,
      );
    } else {
      final backgroundColor = preset.settings.backgroundEnabled
          ? preset.settings.backgroundSettings.backgroundColor
          : Colors.black;
      contentWidget = Container(
        color: backgroundColor,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Build effects stack with preset settings
    return _buildEffectsStackForPreset(contentWidget, preset.settings);
  }

  /// Build effects stack for a specific preset (used in PageView)
  Widget _buildEffectsStackForPreset(Widget contentWidget, settings) {
    // Create list of stack children
    List<Widget> stackChildren = [];

    // Add main shader effect
    stackChildren.add(
      Positioned.fill(
        child: Container(
          alignment: Alignment.center,
          child: EffectController.applyEffects(
            child: contentWidget,
            settings: settings,
            animationValue: _animation.value,
            preserveTransparency: false,
            isTextContent: false,
          ),
        ),
      ),
    );

    // Add text overlay if text is enabled and has content
    if (settings.textEnabled &&
        (settings.textLayoutSettings.textTitle.isNotEmpty ||
            settings.textLayoutSettings.textSubtitle.isNotEmpty ||
            settings.textLayoutSettings.textArtist.isNotEmpty ||
            settings.textLayoutSettings.textLyrics.isNotEmpty)) {
      stackChildren.add(
        TextOverlay(settings: settings, animationValue: _animation.value),
      );
    }

    return Stack(fit: StackFit.expand, children: stackChildren);
  }

  /// Build the stable content widget (ImageContainer or background)
  /// This is cached and only rebuilt when critical settings change
  Widget _buildContentWidget(ShaderController controller) {
    // PERFORMANCE FIX: Include ALL properties that affect ImageContainer to prevent rebuilds
    final cacheKey = [
      "imageEnabled:${controller.settings.imageEnabled}",
      "selectedImage:${controller.selectedImage}",
      "backgroundEnabled:${controller.settings.backgroundEnabled}",
      "backgroundColor:${controller.settings.backgroundSettings.backgroundColor.value}",
      "fillScreen:${controller.settings.fillScreen}",
      "fitScreenMargin:${controller.settings.textLayoutSettings.fitScreenMargin}",
    ].join("_");

    // Use a cached widget to prevent rebuilds unless essential properties change
    return _cachedContentWidget(cacheKey, controller);
  }

  Widget? _lastContentWidget;
  String? _lastContentCacheKey;

  Widget _cachedContentWidget(String cacheKey, ShaderController controller) {
    // Only rebuild content if cache key changed
    if (_lastContentCacheKey == cacheKey && _lastContentWidget != null) {
      return _lastContentWidget!;
    }

    Widget contentWidget;
    if (controller.settings.imageEnabled) {
      // Use ImageContainer to properly handle fit/fill and margins
      contentWidget = ImageContainer(
        imagePath: controller.selectedImage,
        settings: controller.settings,
      );
    } else {
      // Show background color from settings when image is disabled
      final backgroundColor = controller.settings.backgroundEnabled
          ? controller.settings.backgroundSettings.backgroundColor
          : Colors.black;
      contentWidget = Container(
        color: backgroundColor,
        width: double.infinity,
        height: double.infinity,
      );
    }

    _lastContentWidget = contentWidget;
    _lastContentCacheKey = cacheKey;
    return contentWidget;
  }

  /// Build the effects stack - optimized to use AnimatedBuilder only when controller is running
  Widget _buildEffectsStack(ShaderController controller, Widget contentWidget) {
    // DEBUG: Log rebuild triggers
    _effectsStackBuildCount++;
    if (_effectsStackBuildCount <= 10) {
      // print(
        "[ShaderDemoScreen] _buildEffectsStack called #$_effectsStackBuildCount, isAnimating: ${_animationController.isAnimating}",
      );
    }

    if (_animationController.isAnimating) {
      // Use AnimatedBuilder when animations are active
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _buildStackContent(
            controller,
            contentWidget,
            _animation.value,
          );
        },
      );
    } else {
      // Static build when no animations are active - prevents unnecessary rebuilds
      return _buildStackContent(controller, contentWidget, 0.0);
    }
  }

  /// Build the actual stack content (shared between animated and static builds)
  Widget _buildStackContent(
    ShaderController controller,
    Widget contentWidget,
    double animationValue,
  ) {
    // Create list of stack children
    List<Widget> stackChildren = [];

    // Add main shader effect - use V1's working approach with alignment container
    stackChildren.add(
      Positioned.fill(
        child: Container(
          alignment: Alignment.center,
          child: EffectController.applyEffects(
            child: contentWidget,
            settings: controller.settings,
            animationValue: animationValue,
            preserveTransparency: false,
            isTextContent: false,
          ),
        ),
      ),
    );

    // Add text overlay if text is enabled and has content
    if (controller.settings.textEnabled &&
        (controller.settings.textLayoutSettings.textTitle.isNotEmpty ||
            controller.settings.textLayoutSettings.textSubtitle.isNotEmpty ||
            controller.settings.textLayoutSettings.textArtist.isNotEmpty ||
            controller.settings.textLayoutSettings.textLyrics.isNotEmpty)) {
      stackChildren.add(
        TextOverlay(
          settings: controller.settings,
          animationValue: animationValue,
        ),
      );
    }

    // Return the stack directly (RepaintBoundary moved to _buildShaderArea)
    return Stack(fit: StackFit.expand, children: stackChildren);
  }

  /// Build the controls overlay
  Widget _buildControlsOverlay(ShaderController controller, ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Tapping empty areas toggles controls off
          controller.toggleControls();
        },
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
                  // Effect controls - let them handle their own events
                  const Expanded(child: EffectControlsV2()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Show preset menu
  void _showPresetMenu() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider.value(
              value: _shaderController,
              child: PresetMenu(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  /// Show save dialog for naming and saving current preset
  Future<void> _showSaveDialog(
    ShaderController controller,
    ThemeData theme,
  ) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          'Save Preset',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter preset name',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      // First save the preset
      final success = await controller.saveNamedPreset(result);

      if (success && mounted) {
        // Then capture a thumbnail for the saved preset
        final savedPreset = controller.savedPresets
            .where((p) => p.name == result)
            .lastOrNull; // Get the most recently saved preset with this name

        if (savedPreset != null) {
          // Ensure controls are hidden for thumbnail capture
          final originalControlsVisible = controller.controlsVisible;
          if (originalControlsVisible) {
            controller.toggleControls(); // Hide controls
            // Wait for next frame to ensure UI is updated
            await Future.delayed(const Duration(milliseconds: 100));
          }

          try {
            // Capture thumbnail of the clean shader view
            final thumbnailBase64 =
                await ThumbnailService.capturePresetThumbnail(
                  preset: savedPreset,
                  previewKey: _previewKey,
                );
          } catch (e) {
            // print('Error capturing thumbnail: $e');
          } finally {
            // Restore original controls visibility
            if (originalControlsVisible && mounted) {
              controller.toggleControls();
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preset'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
