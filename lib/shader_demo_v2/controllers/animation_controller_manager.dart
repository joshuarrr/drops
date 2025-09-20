import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/effect_settings.dart';

/// Manages multiple independent animation controllers for different effects
/// Each effect can have its own animation speed and timing
class AnimationControllerManager extends ChangeNotifier {
  // Animation controllers for each effect type
  late AnimationController _blurController;
  late AnimationController _colorController;
  late AnimationController _overlayController;
  late AnimationController _noiseController;
  late AnimationController _rainController;
  late AnimationController _chromaticController;
  late AnimationController _rippleController;
  late AnimationController _sketchController;
  late AnimationController _edgeController;
  late AnimationController _glitchController;
  late AnimationController _vhsController;

  // Track which controllers are currently active
  final Set<String> _activeControllers = <String>{};

  // Animation values for each effect
  final Map<String, double> _animationValues = {};

  // Ticker provider for animation controllers
  final TickerProvider _tickerProvider;

  // Track initialization state
  bool _isInitialized = false;

  AnimationControllerManager(this._tickerProvider);

  /// Initialize all animation controllers
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize controllers with default 5-second duration
    _blurController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _colorController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _overlayController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _noiseController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _rainController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _chromaticController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _rippleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _sketchController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _edgeController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _glitchController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );
    _vhsController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: _tickerProvider,
    );

    // Add listeners to track animation values
    _blurController.addListener(
      () => _updateAnimationValue('blur', _blurController.value),
    );
    _colorController.addListener(
      () => _updateAnimationValue('color', _colorController.value),
    );
    _overlayController.addListener(
      () => _updateAnimationValue('overlay', _overlayController.value),
    );
    _noiseController.addListener(
      () => _updateAnimationValue('noise', _noiseController.value),
    );
    _rainController.addListener(
      () => _updateAnimationValue('rain', _rainController.value),
    );
    _chromaticController.addListener(
      () => _updateAnimationValue('chromatic', _chromaticController.value),
    );
    _rippleController.addListener(
      () => _updateAnimationValue('ripple', _rippleController.value),
    );
    _sketchController.addListener(
      () => _updateAnimationValue('sketch', _sketchController.value),
    );
    _edgeController.addListener(
      () => _updateAnimationValue('edge', _edgeController.value),
    );
    _glitchController.addListener(
      () => _updateAnimationValue('glitch', _glitchController.value),
    );
    _vhsController.addListener(
      () => _updateAnimationValue('vhs', _vhsController.value),
    );

    _isInitialized = true;
  }

  /// Calculate animation duration based on speed slider value
  /// Maps speed (0-1) to duration (60s to 0.5s)
  Duration _calculateAnimationDuration(double speed) {
    final durationMs = 60000 - (speed * 59500);
    return Duration(milliseconds: durationMs.round());
  }

  /// Update animation controller duration based on speed settings
  void _updateControllerDuration(String effectType, double speed) {
    if (!_isInitialized) return;

    final newDuration = _calculateAnimationDuration(speed);
    AnimationController controller = _getController(effectType);

    // Only update if duration has changed
    if (controller.duration != newDuration) {
      if (controller.isAnimating) {
        // Stop current animation, update duration, and restart
        controller.stop();
        controller.duration = newDuration;
        controller.reset();
        controller.repeat(reverse: true);
      } else {
        // Safe to update duration when not animating
        controller.duration = newDuration;
      }
    }
  }

  /// Get the appropriate controller for an effect type
  AnimationController _getController(String effectType) {
    switch (effectType) {
      case 'blur':
        return _blurController;
      case 'color':
        return _colorController;
      case 'overlay':
        return _overlayController;
      case 'noise':
        return _noiseController;
      case 'rain':
        return _rainController;
      case 'chromatic':
        return _chromaticController;
      case 'ripple':
        return _rippleController;
      case 'sketch':
        return _sketchController;
      case 'edge':
        return _edgeController;
      case 'glitch':
        return _glitchController;
      case 'vhs':
        return _vhsController;
      default:
        throw ArgumentError('Unknown effect type: $effectType');
    }
  }

  /// Update animation value for an effect
  void _updateAnimationValue(String effectType, double value) {
    _animationValues[effectType] = value;
    notifyListeners();
  }

  /// Get animation value for a specific effect
  double getAnimationValue(String effectType) {
    return _animationValues[effectType] ?? 0.0;
  }

  /// Get animation values for all effects
  Map<String, double> getAllAnimationValues() {
    return Map.from(_animationValues);
  }

  /// Update animation state based on settings
  void updateAnimationState(ShaderSettings settings) {
    if (!_isInitialized) return;

    // Update blur animation
    if (settings.blurEnabled && settings.blurSettings.blurAnimated) {
      _updateControllerDuration(
        'blur',
        settings.blurSettings.blurAnimOptions.speed,
      );
      _startController('blur');
    } else {
      _stopController('blur');
    }

    // Update color animation
    if (settings.colorEnabled && settings.colorSettings.colorAnimated) {
      _updateControllerDuration(
        'color',
        settings.colorSettings.colorAnimOptions.speed,
      );
      _startController('color');
    } else {
      _stopController('color');
    }

    // Update overlay animation
    if (settings.colorEnabled && settings.colorSettings.overlayAnimated) {
      _updateControllerDuration(
        'overlay',
        settings.colorSettings.overlayAnimOptions.speed,
      );
      _startController('overlay');
    } else {
      _stopController('overlay');
    }

    // Update noise animation
    if (settings.noiseEnabled && settings.noiseSettings.noiseAnimated) {
      _updateControllerDuration(
        'noise',
        settings.noiseSettings.noiseAnimOptions.speed,
      );
      _startController('noise');
    } else {
      _stopController('noise');
    }

    // Update rain animation
    if (settings.rainEnabled && settings.rainSettings.rainAnimated) {
      _updateControllerDuration(
        'rain',
        settings.rainSettings.rainAnimOptions.speed,
      );
      _startController('rain');
    } else {
      _stopController('rain');
    }

    // Update chromatic animation
    if (settings.chromaticEnabled &&
        settings.chromaticSettings.chromaticAnimated) {
      _updateControllerDuration(
        'chromatic',
        settings.chromaticSettings.animOptions.speed,
      );
      _startController('chromatic');
    } else {
      _stopController('chromatic');
    }

    // Update ripple animation
    if (settings.rippleEnabled && settings.rippleSettings.rippleAnimated) {
      _updateControllerDuration(
        'ripple',
        settings.rippleSettings.rippleAnimOptions.speed,
      );
      _startController('ripple');
    } else {
      _stopController('ripple');
    }

    // Update sketch animation
    if (settings.sketchEnabled && settings.sketchSettings.sketchAnimated) {
      _updateControllerDuration(
        'sketch',
        settings.sketchSettings.sketchAnimOptions.speed,
      );
      _startController('sketch');
    } else {
      _stopController('sketch');
    }

    // Update edge animation
    if (settings.edgeEnabled && settings.edgeSettings.edgeAnimated) {
      _updateControllerDuration(
        'edge',
        settings.edgeSettings.edgeAnimOptions.speed,
      );
      _startController('edge');
    } else {
      _stopController('edge');
    }

    // Update glitch animation
    if (settings.glitchEnabled && settings.glitchSettings.effectAnimated) {
      _updateControllerDuration(
        'glitch',
        settings.glitchSettings.effectAnimOptions.speed,
      );
      _startController('glitch');
    } else {
      _stopController('glitch');
    }

    // Update VHS animation
    if (settings.vhsEnabled && settings.vhsSettings.effectAnimated) {
      _updateControllerDuration(
        'vhs',
        settings.vhsSettings.effectAnimOptions.speed,
      );
      _startController('vhs');
    } else {
      _stopController('vhs');
    }
  }

  /// Start a specific controller
  void _startController(String effectType) {
    if (!_activeControllers.contains(effectType)) {
      _activeControllers.add(effectType);
      final controller = _getController(effectType);

      // Schedule after frame to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller.reset();
        controller.repeat(reverse: true);
      });
    }
  }

  /// Stop a specific controller
  void _stopController(String effectType) {
    if (_activeControllers.contains(effectType)) {
      _activeControllers.remove(effectType);
      final controller = _getController(effectType);

      // Schedule after frame to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller.stop();
        controller.reset();
        _animationValues.remove(effectType);
      });
    }
  }

  /// Check if any animations are active
  bool hasActiveAnimations() {
    return _activeControllers.isNotEmpty;
  }

  /// Get list of active effect types
  List<String> getActiveEffectTypes() {
    return _activeControllers.toList();
  }

  /// Dispose all controllers
  @override
  void dispose() {
    if (_isInitialized) {
      _blurController.dispose();
      _colorController.dispose();
      _overlayController.dispose();
      _noiseController.dispose();
      _rainController.dispose();
      _chromaticController.dispose();
      _rippleController.dispose();
      _sketchController.dispose();
      _edgeController.dispose();
      _glitchController.dispose();
      _vhsController.dispose();
    }
    super.dispose();
  }
}
