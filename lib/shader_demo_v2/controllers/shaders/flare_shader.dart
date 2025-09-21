import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../../models/effect_settings.dart';
import '../animation_state_manager.dart';
import '../../utils/animation_utils.dart';

class FlareShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;

  const FlareShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!settings.flareSettings.shouldApplyEffect) return child;

    return ShaderBuilder(assetKey: 'assets/shaders/flare.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          shader.setImageSampler(0, image);

          final s = settings.flareSettings;

          // Use AnimationStateManager for per-parameter locking and live values
          final animManager = AnimationStateManager();

          double t = 0.0;
          if (s.effectAnimated) {
            t = ShaderAnimationUtils.computeAnimatedValue(
              s.animOptions,
              animationValue,
            );
          }
          shader.setFloat(0, t);
          shader.setFloat(1, size.width > 0 ? size.width : 1.0);
          shader.setFloat(2, size.height > 0 ? size.height : 1.0);
          // Resolve animated values with parameter locks
          double distortion = s.distortion;
          double swirl = s.swirl;
          double grainMixer = s.grainMixer;
          double grainOverlay = s.grainOverlay;
          double offsetX = s.offsetX;
          double offsetY = s.offsetY;
          double scale = s.scale;
          double rotation = s.rotation;

          if (s.effectAnimated) {
            // Pulse 0..1 within userMin..userMax ranges
            final pulse = t;

            if (!animManager.isParameterLocked(ParameterIds.flareDistortion)) {
              distortion =
                  s.distortionRange.userMin +
                  (s.distortionRange.userMax - s.distortionRange.userMin) *
                      pulse;
              animManager.updateAnimatedValue(
                ParameterIds.flareDistortion,
                distortion,
              );
            }
            if (!animManager.isParameterLocked(ParameterIds.flareSwirl)) {
              swirl =
                  s.swirlRange.userMin +
                  (s.swirlRange.userMax - s.swirlRange.userMin) * pulse;
              animManager.updateAnimatedValue(ParameterIds.flareSwirl, swirl);
            }
            if (!animManager.isParameterLocked(ParameterIds.flareOffsetX)) {
              offsetX =
                  s.offsetXRange.userMin +
                  (s.offsetXRange.userMax - s.offsetXRange.userMin) * pulse;
              animManager.updateAnimatedValue(
                ParameterIds.flareOffsetX,
                offsetX,
              );
            }
            if (!animManager.isParameterLocked(ParameterIds.flareOffsetY)) {
              offsetY =
                  s.offsetYRange.userMin +
                  (s.offsetYRange.userMax - s.offsetYRange.userMin) * pulse;
              animManager.updateAnimatedValue(
                ParameterIds.flareOffsetY,
                offsetY,
              );
            }
            if (!animManager.isParameterLocked(ParameterIds.flareScale)) {
              scale =
                  s.scaleRange.userMin +
                  (s.scaleRange.userMax - s.scaleRange.userMin) * pulse;
              animManager.updateAnimatedValue(ParameterIds.flareScale, scale);
            }
            if (!animManager.isParameterLocked(ParameterIds.flareRotation)) {
              rotation =
                  s.rotationRange.userMin +
                  (s.rotationRange.userMax - s.rotationRange.userMin) * pulse;
              animManager.updateAnimatedValue(
                ParameterIds.flareRotation,
                rotation,
              );
            }
          } else {
            // Clear any animated values when not animating
            animManager.clearAnimatedValuesForEffect('flare.');
          }

          shader.setFloat(3, distortion.clamp(0.0, 1.0));
          shader.setFloat(4, swirl.clamp(0.0, 1.0));
          shader.setFloat(5, grainMixer.clamp(0.0, 1.0));
          shader.setFloat(6, grainOverlay.clamp(0.0, 1.0));
          shader.setFloat(7, offsetX.clamp(-1.0, 1.0));
          shader.setFloat(8, offsetY.clamp(-1.0, 1.0));
          shader.setFloat(9, scale.clamp(0.01, 4.0));
          shader.setFloat(10, rotation.clamp(0.0, 360.0));
          shader.setFloat(11, isTextContent ? 1.0 : 0.0);

          // Opacity (range + locks)
          double opacity = s.opacity;
          if (s.effectAnimated &&
              !animManager.isParameterLocked(ParameterIds.flareOpacity)) {
            final pulse = t;
            opacity =
                s.opacityRange.userMin +
                (s.opacityRange.userMax - s.opacityRange.userMin) * pulse;
            animManager.updateAnimatedValue(ParameterIds.flareOpacity, opacity);
          } else {
            animManager.updateAnimatedValue(ParameterIds.flareOpacity, opacity);
          }
          // Set at index 12
          shader.setFloat(12, opacity.clamp(0.0, 1.0));

          // Colors start at index 13 (16 floats)
          final colors = s.colors;
          for (int i = 0; i < 4; i++) {
            final c = i < colors.length ? colors[i] : const Color(0xFF000000);
            final base = 13 + i * 4;
            shader.setFloat(base + 0, c.red / 255.0);
            shader.setFloat(base + 1, c.green / 255.0);
            shader.setFloat(base + 2, c.blue / 255.0);
            shader.setFloat(base + 3, c.opacity);
          }

          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          // Fallback to source image if shader fails
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint(),
          );
        }
      }, child: this.child);
    }, child: child);
  }
}

Widget applyFlareEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return FlareShader(
    child: child,
    settings: settings,
    animationValue: animationValue,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
