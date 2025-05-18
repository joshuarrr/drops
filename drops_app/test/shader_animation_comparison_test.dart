import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drops_app/shader_demo/utils/animation_utils.dart';
import 'package:drops_app/shader_demo/models/animation_options.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

void main() {
  group('Original vs Refactored Animation Functions', () {
    // Original implementation from shader classes
    double _originalHash(double x) {
      return (math.sin(x * 12.9898) * 43758.5453).abs() % 1;
    }

    double _originalSmoothRandom(double t, {int segments = 8}) {
      final double scaled = t * segments;
      final double idx0 = scaled.floorToDouble();
      final double idx1 = idx0 + 1.0;
      final double frac = scaled - idx0;

      final double r0 = _originalHash(idx0);
      final double r1 = _originalHash(idx1);

      final double eased = Curves.easeInOut.transform(frac);
      return ui.lerpDouble(r0, r1, eased)!;
    }

    double _originalApplyEasing(AnimationEasing easing, double t) {
      switch (easing) {
        case AnimationEasing.easeIn:
          return Curves.easeIn.transform(t);
        case AnimationEasing.easeOut:
          return Curves.easeOut.transform(t);
        case AnimationEasing.easeInOut:
          return Curves.easeInOut.transform(t);
        case AnimationEasing.linear:
        default:
          return t;
      }
    }

    double _originalComputeAnimatedValue(
      AnimationOptions opts,
      double baseTime,
    ) {
      // Animation duration bounds – keep in sync with the demo.
      const int _minDurationMs = 30000;
      const int _maxDurationMs = 300;

      final double durationMs = ui.lerpDouble(
        _minDurationMs.toDouble(),
        _maxDurationMs.toDouble(),
        opts.speed,
      )!;

      final double speedFactor = _minDurationMs / durationMs;
      final double scaledTime = (baseTime * speedFactor) % 1.0;

      final double modeValue = opts.mode == AnimationMode.pulse
          ? scaledTime
          : _originalSmoothRandom(scaledTime);

      return _originalApplyEasing(opts.easing, modeValue);
    }

    test('hash function produces identical results', () {
      for (double x = 0.0; x < 1.0; x += 0.1) {
        expect(
          ShaderAnimationUtils.hash(x),
          _originalHash(x),
          reason: 'Hash values should be identical for input $x',
        );
      }
    });

    test('smoothRandom function produces identical results', () {
      for (double t = 0.0; t < 1.0; t += 0.1) {
        expect(
          ShaderAnimationUtils.smoothRandom(t),
          _originalSmoothRandom(t),
          reason: 'SmoothRandom values should be identical for input $t',
        );
      }
    });

    test('applyEasing function produces identical results', () {
      for (AnimationEasing easing in AnimationEasing.values) {
        for (double t = 0.0; t < 1.0; t += 0.1) {
          expect(
            ShaderAnimationUtils.applyEasing(easing, t),
            _originalApplyEasing(easing, t),
            reason:
                'ApplyEasing values should be identical for input $t with easing $easing',
          );
        }
      }
    });

    test('computeAnimatedValue function produces identical results', () {
      // Test with various animation options
      for (AnimationMode mode in AnimationMode.values) {
        for (AnimationEasing easing in AnimationEasing.values) {
          for (double speed = 0.0; speed <= 1.0; speed += 0.25) {
            final opts = AnimationOptions(
              speed: speed,
              mode: mode,
              easing: easing,
            );

            for (double t = 0.0; t < 1.0; t += 0.1) {
              expect(
                ShaderAnimationUtils.computeAnimatedValue(opts, t),
                _originalComputeAnimatedValue(opts, t),
                reason:
                    'ComputeAnimatedValue should be identical for input $t with options: mode=$mode, easing=$easing, speed=$speed',
              );
            }
          }
        }
      }
    });
  });
}
