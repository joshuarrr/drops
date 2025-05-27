import 'package:flutter/material.dart';
import '../models/shader_preset.dart';
import '../models/effect_settings.dart';
import '../state/shader_demo_state.dart';
import 'text_overlay.dart';
import 'image_container.dart';
import '../controllers/effect_controller.dart';
import '../utils/logging_utils.dart';

/// A view for displaying presets in a slideshow
class SlideshowView extends StatelessWidget {
  final List<ShaderPreset> presets;
  final PageController pageController;
  final Function(int) onPageChanged;
  final AnimationController animationController;

  const SlideshowView({
    Key? key,
    required this.presets,
    required this.pageController,
    required this.onPageChanged,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle no presets case
    if (presets.isEmpty) {
      return const Center(
        child: Text(
          'No presets available for slideshow.\nTap to return to edit mode.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: pageController,
      // Set these properties to enable smooth circular scrolling
      allowImplicitScrolling: true,
      padEnds: false,
      onPageChanged: onPageChanged,
      itemCount: presets.length,
      // Add keep alive to prevent rebuilding pages when they're still in view
      itemBuilder: (context, index) {
        final preset = presets[index];
        // Add key with preset ID to prevent state mixing
        return KeyedSubtree(
          key: ValueKey('preset_view_${preset.id}'),
          child: _buildPresetView(context, preset),
        );
      },
    );
  }

  Widget _buildPresetView(BuildContext context, ShaderPreset preset) {
    // Get screen dimensions to ensure consistent sizing
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    // Create a deep copy of the settings to avoid modification issues
    final presetSettings = preset.settings.copy();

    // Get margin and fillScreen using the helper methods
    double margin = preset.getMargin();
    bool fillScreen = preset.getFillScreen();

    // Apply the settings directly
    presetSettings.fillScreen = fillScreen;
    presetSettings.textLayoutSettings.fitScreenMargin = margin;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          final double animationValue = animationController.value;

          Widget effectsWidget;

          // Check if image is enabled in the preset
          if (!presetSettings.imageEnabled) {
            // If image is disabled, just show transparent container
            effectsWidget = Container(
              width: width,
              height: height,
              color: Colors.transparent,
            );
          } else {
            // Use ImageContainer with proper key and cached values to prevent unnecessary rebuilds
            Widget baseImage = ImageContainer(
              key: ValueKey('image_${preset.id}_${margin}_${fillScreen}'),
              imagePath: preset.imagePath,
              settings: presetSettings,
              cachedMargin: margin,
              cachedFillScreen: fillScreen,
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
            effectsWidget = shouldApplyEffectsToImage
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
          }

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
            color: presetSettings.backgroundEnabled
                ? presetSettings.backgroundSettings.backgroundColor
                : Colors.black,
            width: width,
            height: height,
            child: Stack(fit: StackFit.expand, children: stackChildren),
          );
        },
      ),
    );
  }
}
