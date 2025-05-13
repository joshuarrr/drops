import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/app_scaffold.dart';
import 'models/shader_effect.dart';
import 'models/effect_settings.dart';
import 'controllers/effect_controller.dart';
import 'views/effect_controls.dart';

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

  // List of available images
  final List<String> _availableImages = [
    'assets/img/abbey.png',
    'assets/img/darkside.png',
    'assets/img/bollocks.png',
    'assets/img/ill.png',
    'assets/img/londoncalling.png',
  ];

  // Map to identify which images are dark (true) vs light (false)
  final Map<String, bool> _darkImages = {
    'assets/img/abbey.png': false,
    'assets/img/darkside.png': true,
    'assets/img/bollocks.png': false,
    'assets/img/ill.png': true,
    'assets/img/londoncalling.png': false,
  };

  // Currently selected image
  String _selectedImage = 'assets/img/darkside.png';

  // Helper to determine if current image is dark
  bool get _isCurrentImageDark => _darkImages[_selectedImage] ?? false;

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
    final ThemeData dynamicTheme = _isCurrentImageDark
        ? ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              backgroundColor: Colors.transparent,
            ),
          )
        : ThemeData.light();

    return Theme(
      data: dynamicTheme,
      child: AppScaffold(
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
                      final double topInset = MediaQuery.of(
                        context,
                      ).padding.top;
                      const double toolbarHeight = kToolbarHeight; // 56
                      return Container(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          topInset + 8, // below system inset
                          16,
                          8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _isCurrentImageDark
                                  ? Colors.black.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                EffectControls.buildImageSelector(
                                  selectedImage: _selectedImage,
                                  availableImages: _availableImages,
                                  isCurrentImageDark: _isCurrentImageDark,
                                  onImageSelected: (String? value) {
                                    if (value != null &&
                                        value != _selectedImage) {
                                      setState(() {
                                        _selectedImage = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            EffectControls.buildAspectToggleBar(
                              settings: _shaderSettings,
                              isCurrentImageDark: _isCurrentImageDark,
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
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_shaderSettings.colorEnabled)
                              const Text(
                                "Color: ON",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            if (_shaderSettings.blurEnabled)
                              const Text(
                                "Shatter: ON",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
          alignment: Alignment.center, // Ensure content is centered
          child: Image.asset(
            _selectedImage,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }

  // Build parameter sliders for the selected aspect
  Widget _buildAspectParameterSliders() {
    final Color sliderColor = _isCurrentImageDark ? Colors.white : Colors.black;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth * 0.8,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 100),
        decoration: BoxDecoration(
          color: _isCurrentImageDark
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sliderColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: EffectControls.buildSlidersForAspect(
            aspect: _selectedAspect,
            settings: _shaderSettings,
            onSettingsChanged: (settings) {
              setState(() {
                _shaderSettings = settings;
              });
            },
            sliderColor: sliderColor,
          ),
        ),
      ),
    );
  }
}
