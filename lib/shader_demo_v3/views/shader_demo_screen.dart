import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../controllers/shader_controller.dart';
import '../controllers/color_effect_shader.dart';
import '../widgets/color_panel.dart';
import '../widgets/image_container.dart';
import '../../common/app_scaffold.dart';

/// Main screen for shader demo V3
/// Uses AnimatedBuilder at the top level like V1
class ShaderDemoScreen extends StatefulWidget {
  const ShaderDemoScreen({super.key});

  @override
  State<ShaderDemoScreen> createState() => _ShaderDemoScreenState();
}

class _ShaderDemoScreenState extends State<ShaderDemoScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller - initialized and immediately repeating like V1
  late AnimationController _animationController;
  late ShaderController _shaderController;

  @override
  void initState() {
    super.initState();

    // Initialize shader controller
    _shaderController = ShaderController();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 5), // 5 second cycle
      vsync: this,
    );

    // Add listener for debugging
    _animationController.addListener(() {
      if (_animationController.value % 0.1 < 0.01) {
        debugPrint(
          '[V3] Animation value: ${_animationController.value.toStringAsFixed(3)}',
        );
      }
    });

    // Listen for animation state changes
    _shaderController.addListener(_updateAnimationControllerState);

    // Initial animation state
    _updateAnimationControllerState();
  }

  @override
  void dispose() {
    _shaderController.removeListener(_updateAnimationControllerState);
    _animationController.dispose();
    _shaderController.dispose();
    super.dispose();
  }

  /// Updates animation controller based on current settings
  void _updateAnimationControllerState() {
    final hasActiveAnimations = _hasActiveAnimations();

    // Schedule after frame to avoid setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasActiveAnimations && !_animationController.isAnimating) {
        debugPrint('[V3] Starting animation controller');
        _animationController.forward(from: 0.0).then((_) {
          if (_animationController.isAnimating) {
            _animationController.repeat();
          }
        });
      } else if (!hasActiveAnimations && _animationController.isAnimating) {
        debugPrint('[V3] Stopping animation controller');
        _animationController.stop();
      }
    });
  }

  /// Checks if any animations are currently active
  bool _hasActiveAnimations() {
    final settings = _shaderController.settings;
    final colorAnimationActive =
        settings.colorEnabled && settings.colorSettings.colorAnimated;

    debugPrint(
      '[V3] Checking animations: colorEnabled=${settings.colorEnabled}, ' +
          'colorAnimated=${settings.colorSettings.colorAnimated}, ' +
          'active=$colorAnimationActive',
    );

    return colorAnimationActive;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _shaderController,
      child: Consumer<ShaderController>(
        builder: (context, controller, child) {
          return AppScaffold(
            title: 'Shader Demo V3',
            showBackButton: true,
            currentIndex: 1,
            extendBodyBehindAppBar: true,
            appBarBackgroundColor: Colors.transparent,
            appBarElevation: 0,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Main shader effect area with tap handling
                _buildShaderArea(controller),

                // Controls overlay (toggleable)
                if (controller.showControls) _buildControlsOverlay(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build the main shader area with AnimatedBuilder at the top level like V1
  Widget _buildShaderArea(ShaderController controller) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => controller.toggleControls(),
        child: Container(
          color: Colors.black,
          // AnimatedBuilder at the top level like V1
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Direct use of animation value like V1
              final animationValue = _animationController.value;

              // Only apply color effect if enabled
              if (controller.settings.colorEnabled) {
                return ColorEffectShader(
                  settings: controller.settings.colorSettings,
                  animationValue: animationValue,
                  child: ImageContainer(
                    imagePath: controller.settings.selectedImage,
                  ),
                );
              } else {
                // Just show the image without effects
                return ImageContainer(
                  imagePath: controller.settings.selectedImage,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  /// Build the controls overlay
  Widget _buildControlsOverlay(ShaderController controller) {
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
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 56, // Below app bar
            16,
            16,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Color panel
                ColorPanel(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
