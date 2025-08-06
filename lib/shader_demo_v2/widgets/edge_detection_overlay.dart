import 'package:flutter/material.dart';
import '../services/edge_detection_service.dart';
import '../models/effect_settings.dart';
import 'dart:developer' as developer;

/// Widget that overlays detected edges on top of an image
class EdgeDetectionOverlay extends StatefulWidget {
  final String? imagePath;
  final EdgeDetectionService edgeDetectionService;
  final ShaderSettings settings;
  final Size imageSize;

  const EdgeDetectionOverlay({
    Key? key,
    required this.imagePath,
    required this.edgeDetectionService,
    required this.settings,
    required this.imageSize,
  }) : super(key: key);

  @override
  State<EdgeDetectionOverlay> createState() => _EdgeDetectionOverlayState();
}

class _EdgeDetectionOverlayState extends State<EdgeDetectionOverlay> {
  final String _logTag = 'EdgeDetectionOverlay';
  bool _isProcessing = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Track build count to avoid excessive logs
  static int _buildCount = 0;

  @override
  void initState() {
    super.initState();

    // Process the image on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImageForEdges();
    });
  }

  @override
  void didUpdateWidget(EdgeDetectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reprocess if the image path changes
    if (oldWidget.imagePath != widget.imagePath &&
        !_isProcessing &&
        widget.imagePath != null) {
      _processImageForEdges();
    }
  }

  Future<void> _processImageForEdges() async {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return;
    }

    if (_isProcessing) {
      developer.log('Already processing image, skipping', name: _logTag);
      return;
    }

    setState(() {
      _isProcessing = true;
      _hasError = false;
    });

    try {
      developer.log(
        'Processing image for edge detection: ${widget.imagePath}',
        name: _logTag,
      );
      final edgePath = await widget.edgeDetectionService.processImageForEdges(
        widget.imagePath!,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      developer.log('Edge detection complete', name: _logTag);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _hasError = true;
          _errorMessage = 'Error detecting edges: $e';
        });
      }
      developer.log('Error in edge detection: $e', name: _logTag);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Limit logging
    final buildCount = ++_buildCount;
    if (buildCount % 20 == 0) {
      developer.log('Build count: $buildCount', name: _logTag);
    }

    // Skip rendering if not enabled or no image
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: SizedBox(
        width: widget.imageSize.width,
        height: widget.imageSize.height,
        child: Stack(
          children: [
            // Edge overlay
            if (!_isProcessing && !_hasError)
              CustomPaint(
                size: widget.imageSize,
                painter: widget.edgeDetectionService.createEdgePainter(
                  displaySize: widget.imageSize,
                  outlineColor: widget.settings.highlightsSettings.contourColor,
                  strokeWidth: widget.settings.highlightsSettings.contourWidth,
                  glowEffect:
                      widget.settings.highlightsSettings.highlightsAnimated,
                  glowColor: widget.settings.highlightsSettings.contourColor
                      .withOpacity(0.7),
                ),
                child: widget.settings.highlightsSettings.highlightsAnimated
                    ? _buildAnimatedGlow()
                    : null,
              ),

            // Loading indicator
            if (_isProcessing)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

            // Error message
            if (_hasError)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Add pulsing glow animation if enabled
  Widget? _buildAnimatedGlow() {
    if (!widget.settings.highlightsSettings.highlightsAnimated) {
      return null;
    }

    // Use a separate class for animation to avoid state rebuild
    return _AnimatedGlowEffect(
      imageSize: widget.imageSize,
      edgeDetectionService: widget.edgeDetectionService,
      settings: widget.settings,
    );
  }
}

/// Separate stateful widget to handle glow animation
class _AnimatedGlowEffect extends StatefulWidget {
  final Size imageSize;
  final EdgeDetectionService edgeDetectionService;
  final ShaderSettings settings;

  const _AnimatedGlowEffect({
    required this.imageSize,
    required this.edgeDetectionService,
    required this.settings,
  });

  @override
  State<_AnimatedGlowEffect> createState() => _AnimatedGlowEffectState();
}

class _AnimatedGlowEffectState extends State<_AnimatedGlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create animation controller for glow effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Create animation for pulsing glow
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set up repeating animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: widget.imageSize,
          painter: widget.edgeDetectionService.createEdgePainter(
            displaySize: widget.imageSize,
            outlineColor: widget.settings.highlightsSettings.contourColor
                .withOpacity(_animation.value),
            strokeWidth: widget.settings.highlightsSettings.contourWidth * 2.0,
            glowEffect: true,
            glowColor: widget.settings.highlightsSettings.contourColor
                .withOpacity(_animation.value * 0.4),
          ),
        );
      },
    );
  }
}
