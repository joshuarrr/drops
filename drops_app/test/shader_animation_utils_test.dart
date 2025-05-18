import 'package:flutter_test/flutter_test.dart';
import 'package:drops_app/shader_demo/utils/animation_utils.dart';
import 'package:drops_app/shader_demo/models/animation_options.dart';

void main() {
  group('ShaderAnimationUtils', () {
    test('hash function returns consistent values', () {
      // Test for consistency
      expect(ShaderAnimationUtils.hash(0.5), ShaderAnimationUtils.hash(0.5));
      expect(ShaderAnimationUtils.hash(1.0), ShaderAnimationUtils.hash(1.0));

      // Test for range [0,1)
      expect(ShaderAnimationUtils.hash(0.5), lessThan(1.0));
      expect(ShaderAnimationUtils.hash(0.5), greaterThanOrEqualTo(0.0));
    });

    test('smoothRandom returns values in range [0,1)', () {
      for (double t = 0.0; t < 1.0; t += 0.1) {
        double value = ShaderAnimationUtils.smoothRandom(t);
        expect(value, lessThan(1.0));
        expect(value, greaterThanOrEqualTo(0.0));
      }
    });

    test('applyEasing transforms values based on easing type', () {
      // For linear easing, input should equal output
      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.linear, 0.5),
        0.5,
      );

      // Other easing types should transform the value
      // We can't test exact values, but we can test that they're in range
      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.easeIn, 0.5),
        lessThan(1.0),
      );
      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.easeIn, 0.5),
        greaterThanOrEqualTo(0.0),
      );

      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.easeOut, 0.5),
        lessThan(1.0),
      );
      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.easeOut, 0.5),
        greaterThanOrEqualTo(0.0),
      );

      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.easeInOut, 0.5),
        lessThan(1.0),
      );
      expect(
        ShaderAnimationUtils.applyEasing(AnimationEasing.easeInOut, 0.5),
        greaterThanOrEqualTo(0.0),
      );
    });

    test('computeAnimatedValue returns values in range [0,1)', () {
      final opts = AnimationOptions(
        speed: 0.5,
        mode: AnimationMode.pulse,
        easing: AnimationEasing.linear,
      );

      for (double t = 0.0; t < 1.0; t += 0.1) {
        double value = ShaderAnimationUtils.computeAnimatedValue(opts, t);
        expect(value, lessThan(1.0));
        expect(value, greaterThanOrEqualTo(0.0));
      }
    });

    test('different animation modes produce different results', () {
      final pulseOpts = AnimationOptions(
        speed: 0.5,
        mode: AnimationMode.pulse,
        easing: AnimationEasing.linear,
      );

      final randomOpts = AnimationOptions(
        speed: 0.5,
        mode: AnimationMode.randomixed,
        easing: AnimationEasing.linear,
      );

      // Compare results for same inputs but different modes
      // They should be different
      final pulseValue = ShaderAnimationUtils.computeAnimatedValue(
        pulseOpts,
        0.5,
      );
      final randomValue = ShaderAnimationUtils.computeAnimatedValue(
        randomOpts,
        0.5,
      );

      expect(pulseValue, isNot(equals(randomValue)));
    });
  });
}
