import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/shader_controller.dart';
import '../controllers/animation_controller_manager.dart';

import '../controllers/effect_controller.dart';
import '../controllers/effect_controls_bridge.dart';
import '../views/effect_controls.dart';
import '../views/preset_menu.dart';
import '../views/image_container.dart';
import '../views/text_overlay.dart';
import '../../common/app_scaffold.dart';
import '../services/thumbnail_service.dart';
import '../services/preset_service.dart';
import '../models/preset.dart';

/// Main screen for shader demo V2
/// Uses Provider pattern and Stack layout for overlay controls
class ShaderDemoScreen extends StatefulWidget {
  const ShaderDemoScreen({Key? key}) : super(key: key);

  @override
  State<ShaderDemoScreen> createState() => _ShaderDemoScreenState();
}

class _ShaderDemoScreenState extends State<ShaderDemoScreen>
    with TickerProviderStateMixin {
  late AnimationControllerManager _animationControllerManager;
  bool _isCapturingScreenshot = false;
  String? _pendingPresetName; // Store the preset name for success message
  String? _pendingErrorMessage; // Store error messages
  late ShaderController _shaderController;
  late PageController _pageController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller manager
    _animationControllerManager = AnimationControllerManager(this);
    _animationControllerManager.initialize();

    // Listen to animation controller manager changes to trigger rebuilds
    _animationControllerManager.addListener(() {
      // Animation logging disabled for performance
      if (mounted) {
        setState(() {
          // Trigger rebuild when animation values change
        });
      }
    });

    // Initialize shader controller
    _initializeController();
  }

  Future<void> _initializeController() async {
    // Disable effect caching to fix image update issues
    EffectController.disableCaching();

    _shaderController = ShaderController();
    await _shaderController.initialize();

    // Initialize PageController with current position from NavigationController
    _pageController = PageController(
      initialPage: _shaderController.navigationController.currentPosition,
      viewportFraction: 1.0, // Ensure each page takes full viewport
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

  /// Optimize animation controller and trigger UI update when settings change
  void _onShaderSettingsChanged() {
    // Force rebuild by calling setState
    if (mounted) {
      setState(() {
        // Update animation controller state
        _updateAnimationControllerState();
      });
    } else {
      _updateAnimationControllerState();
    }
  }

  /// Update animation controller duration based on current speed settings
  void _updateAnimationDuration() {
    if (!_isInitialized) return;

    // Update animation state in the manager
    _animationControllerManager.updateAnimationState(
      _shaderController.settings,
    );
  }

  /// Start or stop animation controller based on whether any animations are active
  /// Now includes dynamic duration control
  void _updateAnimationControllerState() {
    if (!mounted || !_isInitialized) return;

    // Update animation state in the manager
    _updateAnimationDuration();
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
    _animationControllerManager.dispose();
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
          // Show success toast if we have a pending preset name
          if (_pendingPresetName != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Preset "$_pendingPresetName" saved successfully!',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                _pendingPresetName = null; // Clear after showing
              }
            });
          }

          // Show error toast if we have a pending error message
          if (_pendingErrorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_pendingErrorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
                _pendingErrorMessage = null; // Clear after showing
              }
            });
          }

          return AppScaffold(
            title: 'Shaders',
            showBackButton: true,
            showAppBar:
                !_isCapturingScreenshot, // Hide app bar during screenshot capture
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
          if (_shaderController.basePreset != null)
            const PopupMenuItem<String>(
              value: 'update_preset',
              child: Row(
                children: [
                  Icon(Icons.update),
                  SizedBox(width: 8),
                  Text('Update Preset'),
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
    if (_shaderController.basePreset != null) {
      _showUpdateDialog(_shaderController, Theme.of(context));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No preset selected to update')),
      );
    }
  }

  void _handleLoadPreset() {
    _showPresetMenu();
  }

  Future<void> _showUpdateDialog(
    ShaderController controller,
    ThemeData theme,
  ) async {
    final currentPreset = controller.basePreset!;

    // Hide ALL UI elements for clean capture
    controller.setControlsVisible(false); // Force hide controls

    // Set screenshot capture flag to hide app bar
    setState(() {
      _isCapturingScreenshot = true;
    });

    // Wait longer for all UI to settle
    await Future.delayed(const Duration(milliseconds: 800));

    // Capture screenshot of clean screen
    final captureResult = await ThumbnailService.capturePreview(
      null, // Using native screenshot, no key needed
    );

    // Restore app bar visibility
    if (mounted) {
      setState(() {
        _isCapturingScreenshot = false;
      });
    }

    bool updateSuccess = false;
    if (captureResult != null) {
      final capturedThumbnail = base64Encode(captureResult);
      print('🖼️ [ShaderDemoScreen] Clean screenshot captured for update');

      // Update the preset with the captured thumbnail
      final presetSuccess = await controller.updatePreset(
        currentPreset.id,
        thumbnailBase64: capturedThumbnail,
      );
      if (presetSuccess) {
        // Thumbnail is already saved as part of updatePreset
        print('Clean thumbnail updated for preset: ${currentPreset.name}');
        updateSuccess = true;
      }
    }

    // Show success toast only if both preset and thumbnail updated successfully
    if (updateSuccess) {
      _showSuccessToast('Updated "${currentPreset.name}"');
    } else {
      // Show error toast if something failed
      _showErrorToast('Failed to update preset "${currentPreset.name}"');
    }
  }

  /// Build the main shader effect area with vertical PageView navigation
  Widget _buildShaderArea(ShaderController controller, ThemeData theme) {
    final navigatorOrder = controller.navigationController.navigatorOrder;

    // If no presets, show current content
    if (navigatorOrder.isEmpty) {
      final Widget contentWidget = _buildContentWidget(controller);
      return Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.toggleControls(),
          onLongPress: () {}, // Add empty handler to ensure events bubble up
          child: Container(
            color: Colors.black,
            // Use animation controller manager for independent effect animations
            child: AnimatedBuilder(
              animation: _animationControllerManager,
              builder: (context, child) {
                final animationValues = _animationControllerManager
                    .getAllAnimationValues();
                return _buildStackContent(
                  controller,
                  contentWidget,
                  animationValues,
                );
              },
            ),
          ),
        ),
      );
    }

    // Build PageView with vertical scrolling for TikTok-style navigation
    return Positioned.fill(
      child: Container(
        color: Colors.black, // Prevent transparency during transitions
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: navigatorOrder.length,
          pageSnapping: true,
          onPageChanged: (index) {
            // Update navigation controller position when user swipes
            controller.navigationController.navigateToPosition(index);
          },
          itemBuilder: (context, index) {
            final preset = navigatorOrder[index];
            return GestureDetector(
              key: ValueKey(preset.id),
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.toggleControls(),
              onLongPress:
                  () {}, // Add empty handler to ensure events bubble up
              child: Container(
                color: Colors.black,
                // Use animation controller manager for independent effect animations
                child: AnimatedBuilder(
                  animation: _animationControllerManager,
                  builder: (context, child) {
                    final animationValues = _animationControllerManager
                        .getAllAnimationValues();
                    // Animation debugging disabled
                    // print(
                    //   "[CRITICAL] PageView AnimatedBuilder with values: $animationValues",
                    // );

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

                    return ClipRect(
                      child: _buildStackContent(
                        controller,
                        contentWidget,
                        animationValues,
                      ),
                    );
                  },
                ),
              ),
            );
          }, // End of PageView.builder
        ),
      ),
    );
  } // End of _buildShaderArea

  // Removed _buildPresetView and _buildEffectsStackForPreset as they're no longer needed
  // Now using _buildStackContent directly from AnimatedBuilder

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

  // Removed unused cache variables

  Widget _cachedContentWidget(String cacheKey, ShaderController controller) {
    // FIXED: Always rebuild content to ensure settings changes are reflected immediately
    // Removed caching conditional to fix image visibility toggle and selection not updating

    Widget contentWidget;

    // Add debug logging for image state
    print(
      'DEBUG IMAGE STATE: imageEnabled=${controller.settings.imageEnabled}, selectedImage=${controller.selectedImage}',
    );

    if (controller.settings.imageEnabled) {
      // Use ImageContainer to properly handle fit/fill and margins
      print(
        'DEBUG: Creating ImageContainer with path: ${controller.selectedImage}',
      );
      contentWidget = ImageContainer(
        imagePath: controller.selectedImage,
        settings: controller.settings,
      );
    } else {
      // Show background color from settings when image is disabled
      final backgroundColor = controller.settings.backgroundEnabled
          ? controller.settings.backgroundSettings.backgroundColor
          : Colors.black;
      print(
        'DEBUG: Creating background container - backgroundEnabled=${controller.settings.backgroundEnabled}, '
        'backgroundColor=0x${backgroundColor.value.toRadixString(16)}',
      );
      contentWidget = Container(
        color: backgroundColor,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Removed cache assignments to fix immediate updates
    return contentWidget;
  }

  // Removed _buildEffectsStack - now using AnimatedBuilder directly

  /// Build the actual stack content (shared between animated and static builds)
  Widget _buildStackContent(
    ShaderController controller,
    Widget contentWidget,
    Map<String, double> animationValues,
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
            animationValues: animationValues,
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
          animationValues: animationValues,
        ),
      );
    }

    // Use a unique ValueKey for each page in the navigation stack to avoid conflicts
    // The key is only used for identification, not for finding the widget
    return ClipRect(
      child: RepaintBoundary(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(fit: StackFit.expand, children: stackChildren),
        ),
      ),
    );
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
            // const double toolbarHeight = kToolbarHeight; // 56
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

  /// Show success toast using a safe approach
  void _showSuccessToast(String presetName) {
    // Store the preset name and trigger a rebuild to show toast
    _pendingPresetName = presetName;
    if (mounted) {
      setState(() {});
    }
  }

  /// Show error toast using a safe approach
  void _showErrorToast(String message) {
    // Store the error message and trigger a rebuild to show toast
    _pendingErrorMessage = message;
    if (mounted) {
      setState(() {});
    }
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
    // Generate automatic name first
    final autoName = await PresetService.generateAutomaticPresetName();
    final nameController = TextEditingController(text: autoName);
    String? selectedPreset;
    ValueNotifier<int> refreshTrigger = ValueNotifier(0);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          'Save Image Preset',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: ValueListenableBuilder<int>(
          valueListenable: refreshTrigger,
          builder: (context, _, __) {
            return FutureBuilder<List<Preset>>(
              future: PresetService.loadAllPresets(),
              builder: (context, snapshot) {
                final presets = snapshot.data ?? [];
                final presetNames = presets.map((p) => p.name).toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Preset Name',
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
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    if (presetNames.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Or update existing preset:',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select a preset to update',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        value: selectedPreset,
                        dropdownColor: theme.dialogBackgroundColor,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        items: presetNames.map((name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedPreset = value;
                          if (value != null) {
                            nameController.text = value;
                          }
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Hide ALL UI elements for clean capture
                controller.setControlsVisible(false); // Force hide controls

                // Set screenshot capture flag to hide app bar
                setState(() {
                  _isCapturingScreenshot = true;
                });

                // Close dialog to hide it
                Navigator.of(context).pop(name);

                // Wait longer for all UI to settle
                await Future.delayed(const Duration(milliseconds: 800));

                // Capture screenshot of clean screen
                final captureResult = await ThumbnailService.capturePreview(
                  null, // Using native screenshot, no key needed
                );

                // Restore app bar visibility
                if (mounted) {
                  setState(() {
                    _isCapturingScreenshot = false;
                  });
                }

                bool saveSuccess = false;
                if (captureResult != null) {
                  final capturedThumbnail = base64Encode(captureResult);
                  print('🖼️ [ShaderDemoScreen] Clean screenshot captured');

                  // Save the preset with the captured thumbnail
                  final presetSuccess = await controller.saveNamedPreset(
                    name,
                    thumbnailBase64: capturedThumbnail,
                  );
                  if (presetSuccess) {
                    // Thumbnail is already saved as part of saveNamedPreset
                    print('Clean thumbnail saved for preset: $name');
                    saveSuccess = true;
                  }
                }

                // Show success toast only if both preset and thumbnail saved successfully
                if (saveSuccess) {
                  _showSuccessToast(name);
                } else {
                  // Show error toast if something failed
                  _showErrorToast('Failed to save preset "$name"');
                }
              }
            },
            child: const Text('Save'),
          ),
          ValueListenableBuilder<int>(
            valueListenable: refreshTrigger,
            builder: (context, _, __) {
              return FutureBuilder<List<Preset>>(
                future: PresetService.loadAllPresets(),
                builder: (context, snapshot) {
                  final presets = snapshot.data ?? [];
                  final presetNames = presets.map((p) => p.name).toList();
                  if (snapshot.hasData &&
                      nameController.text.isNotEmpty &&
                      presetNames.contains(nameController.text)) {
                    return FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          // Hide ALL UI elements for clean capture
                          controller.setControlsVisible(
                            false,
                          ); // Force hide controls

                          // Set screenshot capture flag to hide app bar
                          setState(() {
                            _isCapturingScreenshot = true;
                          });

                          // Close dialog to hide it
                          Navigator.of(context).pop(name);

                          // Wait longer for all UI to settle
                          await Future.delayed(
                            const Duration(milliseconds: 800),
                          );

                          // Capture screenshot of clean screen
                          final captureResult =
                              await ThumbnailService.capturePreview(
                                null, // Using native screenshot, no key needed
                              );

                          // Restore app bar visibility
                          if (mounted) {
                            setState(() {
                              _isCapturingScreenshot = false;
                            });
                          }

                          bool saveSuccess = false;
                          if (captureResult != null) {
                            final capturedThumbnail = base64Encode(
                              captureResult,
                            );
                            print(
                              '🖼️ [ShaderDemoScreen] Clean screenshot captured',
                            );

                            // Save the preset with the captured thumbnail
                            final presetSuccess = await controller
                                .saveNamedPreset(name);
                            if (presetSuccess) {
                              final savedPreset = controller.savedPresets
                                  .where((p) => p.name == name)
                                  .lastOrNull;

                              if (savedPreset != null) {
                                try {
                                  await PresetService.savePresetThumbnail(
                                    savedPreset.id,
                                    capturedThumbnail,
                                  );
                                  print(
                                    '🖼️ [ShaderDemoScreen] Thumbnail saved successfully',
                                  );
                                  saveSuccess = true;
                                } catch (e) {
                                  print(
                                    '🖼️ [ShaderDemoScreen] Error saving thumbnail: $e',
                                  );
                                }
                              }
                            }
                          } else {
                            print(
                              '🖼️ [ShaderDemoScreen] Screenshot capture failed',
                            );
                          }

                          // Restore controls visibility
                          controller.setControlsVisible(true);

                          if (saveSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Preset "$name" updated successfully',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update preset'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Update'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ],
      ),
    );

    if (result != null) {
      // Preset already saved in the Save button callback
      print('Preset saved: $result');
    }
  }
}
