import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../services/edge_detection_service.dart';
import '../widgets/edge_detection_overlay.dart';

class ImageContainer extends StatefulWidget {
  final String imagePath;
  final ShaderSettings settings;

  const ImageContainer({
    Key? key,
    required this.imagePath,
    required this.settings,
  }) : super(key: key);

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  // Edge detection service for highlighting
  late final EdgeDetectionService _edgeDetectionService;

  // Error state tracking
  bool _edgeDetectionError = false;
  String _errorMessage = '';

  // Loading state
  bool _isProcessing = false;

  // Static tracking for path logging to avoid excessive logs
  static String? _lastLoggedPath;

  @override
  void initState() {
    super.initState();
    try {
      _edgeDetectionService = EdgeDetectionService();
      // We'll let the HighlightsPanel handle the initial processing
      // to avoid both components trying to process the same image
    } catch (e) {
      setState(() {
        _edgeDetectionError = true;
        _errorMessage = 'Error initializing detection: $e';
      });
      debugPrint('Error initializing detection services: $e');
    }
  }

  // Static variables to track processing state and history
  static DateTime? _lastProcessTime;
  static String? _lastProcessedImagePath;
  static bool _hasSuccessfullyProcessed = false;

  @override
  void didUpdateWidget(ImageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only process if something important changed
    final bool imageChanged = oldWidget.imagePath != widget.imagePath;
    final bool highlightsEnabledChanged = oldWidget.settings.highlightsEnabled != widget.settings.highlightsEnabled;
    final bool showContoursChanged = oldWidget.settings.highlightsSettings.showEdgeContours != widget.settings.highlightsSettings.showEdgeContours;

    // Log path changes (but limit frequency)
    if (imageChanged && widget.imagePath != _lastLoggedPath) {
      _lastLoggedPath = widget.imagePath;
      debugPrint('ImageContainer: imagePath="${widget.imagePath}"');
    }

    // Process if image changed or highlights settings changed
    if ((imageChanged || highlightsEnabledChanged || showContoursChanged) && 
        widget.settings.highlightsEnabled && 
        widget.settings.highlightsSettings.showEdgeContours) {
      
      // Aggressive throttling - only process if enough time has passed
      final now = DateTime.now();
      if (_lastProcessTime != null) {
        final difference = now.difference(_lastProcessTime!);
        if (difference.inSeconds < 30) { // 30 second cooldown
          debugPrint('Skipping processing - too soon since last process');
          return;
        }
      }

      // Only process if we haven't successfully processed this image yet
      if (widget.imagePath != _lastProcessedImagePath || !_hasSuccessfullyProcessed) {
        _lastProcessTime = now;
        _lastProcessedImagePath = widget.imagePath;
        _processEdgeDetection();
      }
    }
  }

  Future<void> _processEdgeDetection() async {
    // Skip if highlights not enabled or image path is empty
    if (!widget.settings.highlightsEnabled || widget.imagePath.isEmpty) {
      return;
    }

    // Set processing state
    setState(() {
      _isProcessing = true;
      _edgeDetectionError = false;
      _errorMessage = '';
    });

    try {
      debugPrint('Processing image for edge detection: ${widget.imagePath}');
      await _edgeDetectionService.processImageForEdges(widget.imagePath);
      _hasSuccessfullyProcessed = true;

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      debugPrint('✅ Successfully processed image with edge detection');
    } catch (e) {
      _hasSuccessfullyProcessed = false;

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _edgeDetectionError = true;
          _errorMessage = 'Error processing image: $e';
        });
      }
      debugPrint('Error processing image: $e');
    }
  }

  // Static logging control to reduce noise
  static int _logCount = 0;
  static const int _maxLogs =
      2; // Only log first 2 builds to verify it's working

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final bool fillScreen = widget.settings.fillScreen;
        final double margin = fillScreen
            ? 0.0
            : widget.settings.textLayoutSettings.fitScreenMargin;

        // Log only for debugging (very limited)
        if (_logCount < _maxLogs) {
          debugPrint(
            'ImageContainer: building new widget - margin=${margin.toStringAsFixed(1)}, fillScreen=$fillScreen',
          );
          _logCount++;
        }

        // Calculate image dimensions
        final bool isFitMode = !fillScreen;
        final double imageWidth = isFitMode
            ? screenWidth - (margin * 2)
            : screenWidth;
        final double imageHeight = isFitMode
            ? screenHeight - (margin * 2)
            : screenHeight;

        // Only log the image path when it changes
        if (_lastLoggedPath != widget.imagePath) {
          debugPrint('ImageContainer: imagePath="${widget.imagePath}"');
          _lastLoggedPath = widget.imagePath;
        }

        // Check if the path is valid
        Widget imageWidget;
        if (widget.imagePath.isEmpty) {
          debugPrint('ImageContainer: Empty path, showing empty container');
          imageWidget = SizedBox(width: imageWidth, height: imageHeight);
        } else {
          try {
            // Create stack to hold both the image and detection overlays
            imageWidget = Stack(
              children: [
                Image.asset(
                  widget.imagePath,
                  fit: fillScreen ? BoxFit.cover : BoxFit.contain,
                  width: imageWidth,
                  height: imageHeight,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('ImageContainer: Error loading image: $error');
                    return Container(
                      width: imageWidth,
                      height: imageHeight,
                      color: Colors.red.withOpacity(0.3),
                      child: const Center(
                        child: Text(
                          'Error loading image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),

                // Loading indicator while processing
                if (_isProcessing)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 12),
                          const Text(
                            'Processing image...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Detection overlay if enabled (either face or edge detection)
                if (widget.settings.highlightsEnabled &&
                    widget.settings.highlightsSettings.showEdgeContours &&
                    !_edgeDetectionError &&
                    !_isProcessing)
                  Positioned.fill(
                    child: EdgeDetectionOverlay(
                      imagePath: widget.imagePath,
                      edgeDetectionService: _edgeDetectionService,
                      settings: widget.settings,
                      imageSize: Size(imageWidth, imageHeight),
                    ),
                  ),

                // Error message if detection failed
                if (_edgeDetectionError)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Detection error: $_errorMessage',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _processEdgeDetection,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } catch (e) {
            debugPrint('ImageContainer: Exception loading image: $e');
            imageWidget = Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.red.withOpacity(0.3),
              child: Center(
                child: Text(
                  'Error loading image: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        }

        return Container(
          width: screenWidth,
          height: screenHeight,
          padding: isFitMode ? EdgeInsets.all(margin) : EdgeInsets.zero,
          child: Center(child: imageWidget),
        );
      },
    );
  }
}
