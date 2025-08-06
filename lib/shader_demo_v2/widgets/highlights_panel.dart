import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../services/edge_detection_service.dart';
import '../controllers/shader_controller.dart';
import 'package:provider/provider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';
import 'dart:developer' as developer;

/// Control panel for the Highlights effect
/// Provides edge detection and highlighting features
class HighlightsPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const HighlightsPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<HighlightsPanel> createState() => _HighlightsPanelState();
}

class _HighlightsPanelState extends State<HighlightsPanel> {
  // Edge detection service
  late final EdgeDetectionService _edgeDetectionService;

  // Track current image path to avoid redundant processing
  String? _lastProcessedImage;

  // Error state
  String? _errorMessage;

  // Logging tag
  final String _logTag = 'HighlightsPanel';

  @override
  void initState() {
    super.initState();
    _edgeDetectionService = EdgeDetectionService();

    // Process detection if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _processEdgeDetection();
      }
    });
  }

  // Track if we're currently processing to prevent duplicate calls
  bool _isProcessing = false;

  // Track when last processing was completed successfully to prevent reprocessing too often
  DateTime? _lastProcessingTime;

  void _processEdgeDetection() {
    try {
      // Skip if already processing
      if (_isProcessing) {
        developer.log('Edge detection already in progress', name: _logTag);
        return;
      }

      // Very aggressive throttling - 5 seconds between attempts
      if (_lastProcessingTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastProcessingTime!);
        if (difference.inMilliseconds < 5000) {
          developer.log(
            'Skipping detection, processed too recently: ${difference.inMilliseconds}ms ago',
            name: _logTag,
          );
          return;
        }
      }

      // Get the currently selected image path from controller
      final String? imagePath = widget.settings.imageEnabled
          ? Provider.of<ShaderController>(
              widget.context,
              listen: false,
            ).selectedImage
          : null;

      // Skip if no image or empty path
      if (imagePath == null || imagePath.isEmpty) {
        developer.log('No image to process or empty path', name: _logTag);
        return;
      }

      // Only skip if we've already processed this exact image successfully
      if (imagePath == _lastProcessedImage && _edgeDetectionService.edgePath != null) {
        developer.log(
          'Already processed this image with edge detection',
          name: _logTag,
        );
        return;
      }

      // Process the image directly
      _isProcessing = true;
      setState(() {
        _errorMessage = null;
      });

      developer.log(
        'Processing image for edge detection: $imagePath',
        name: _logTag,
      );

      // Update last processed image
      _lastProcessedImage = imagePath;

      // Process with edge detection service
      _edgeDetectionService.processImageForEdges(imagePath)
          .then((_) {
            _isProcessing = false;
            _lastProcessingTime = DateTime.now();

            // Trigger UI update after processing
            if (mounted) {
              setState(() {});
              developer.log(
                'Successfully processed image with edge detection',
                name: _logTag,
              );
            }
          })
          .catchError((error) {
            _isProcessing = false;
            if (mounted) {
              setState(() {
                _errorMessage = 'Edge detection error: $error';
              });
            }
            developer.log(
              'Error processing edge detection: $error',
              name: _logTag,
            );
          });
    } catch (e) {
      _isProcessing = false;
      developer.log('Exception in _processEdgeDetection: $e', name: _logTag);
      if (mounted) {
        setState(() {
          _errorMessage = 'Detection error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.highlights,
          onPresetSelected: _applyPreset,
          onReset: _resetHighlights,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: widget.settings.highlightsSettings.applyToImage,
          applyToText: widget.settings.highlightsSettings.applyToText,
          onApplyToImageChanged: (value) {
            widget.settings.highlightsSettings.applyToImage = value;
            widget.onSettingsChanged(widget.settings);
          },
          onApplyToTextChanged: (value) {
            widget.settings.highlightsSettings.applyToText = value;
            widget.onSettingsChanged(widget.settings);
          },
        ),

        // Edge detection status and controls
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: widget.sliderColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edge Detection',
                    style: TextStyle(
                      color: widget.sliderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: widget.settings.highlightsSettings.showEdgeContours,
                    thumbColor: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.selected)
                          ? widget.sliderColor
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        widget.settings.highlightsSettings.showEdgeContours = value;
                        widget.onSettingsChanged(widget.settings);
                        // Reprocess with the new detection type
                        _processEdgeDetection();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Edge Detection Status or Error
              _errorMessage != null
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detected Edges:',
                          style: TextStyle(
                            color: widget.sliderColor,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _edgeDetectionService.edgePath != null ? 'Yes' : 'No',
                          style: TextStyle(
                            color: widget.sliderColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              // Detect Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Detect Edges'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.sliderColor.withOpacity(0.2),
                    foregroundColor: widget.sliderColor,
                  ),
                  onPressed: () {
                    try {
                      _processEdgeDetection();
                    } catch (e) {
                      setState(() {
                        _errorMessage = 'Failed to process image: $e';
                      });
                      developer.log(
                        'Error in detect edges button: $e',
                        name: _logTag,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Toggle for animation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Animate',
              style: TextStyle(color: widget.sliderColor, fontSize: 14),
            ),
            Switch(
              value: widget.settings.highlightsSettings.highlightsAnimated,
              thumbColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? widget.sliderColor
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  widget.settings.highlightsSettings.highlightsAnimated = value;
                  if (!widget.settings.highlightsEnabled)
                    widget.settings.highlightsEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                });
              },
            ),
          ],
        ),

        // Animation controls that show only when animation is enabled
        if (widget.settings.highlightsSettings.highlightsAnimated)
          AnimationControls(
            animationSpeed:
                widget.settings.highlightsSettings.highlightsAnimOptions.speed,
            onSpeedChanged: (v) {
              setState(() {
                widget.settings.highlightsSettings.highlightsAnimOptions =
                    widget.settings.highlightsSettings.highlightsAnimOptions
                        .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
              });
            },
            animationMode:
                widget.settings.highlightsSettings.highlightsAnimOptions.mode,
            onModeChanged: (m) {
              setState(() {
                widget.settings.highlightsSettings.highlightsAnimOptions =
                    widget.settings.highlightsSettings.highlightsAnimOptions
                        .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
              });
            },
            animationEasing:
                widget.settings.highlightsSettings.highlightsAnimOptions.easing,
            onEasingChanged: (e) {
              setState(() {
                widget.settings.highlightsSettings.highlightsAnimOptions =
                    widget.settings.highlightsSettings.highlightsAnimOptions
                        .copyWith(easing: e);
                widget.onSettingsChanged(widget.settings);
              });
            },
            sliderColor: widget.sliderColor,
          ),
      ],
    );
  }

  void _resetHighlights() {
    setState(() {
      widget.settings.highlightsEnabled = false;
      widget.settings.highlightsSettings.highlightsAnimated = false;
      widget.settings.highlightsSettings.showEdgeContours = true; // Reset to edge detection
      widget.settings.highlightsSettings.contourColor = Colors.green;
      widget.settings.highlightsSettings.contourWidth = 2.0;
      widget.settings.highlightsSettings.highlightsAnimOptions =
          AnimationOptions();

      widget.onSettingsChanged(widget.settings);
    });
  }

  // Build color selection button
  Widget _buildColorOption(Color color) {
    final bool isSelected =
        widget.settings.highlightsSettings.contourColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.settings.highlightsSettings.contourColor = color;
          widget.onSettingsChanged(widget.settings);
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? widget.sliderColor : Colors.transparent,
            width: isSelected ? 2.0 : 0.0,
          ),
        ),
      ),
    );
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    setState(() {
      widget.settings.highlightsEnabled =
          presetData['highlightsEnabled'] ?? widget.settings.highlightsEnabled;
      widget.settings.highlightsSettings.highlightsAnimated =
          presetData['highlightsAnimated'] ??
          widget.settings.highlightsSettings.highlightsAnimated;

      // Apply edge detection settings
      widget.settings.highlightsSettings.showEdgeContours =
          presetData['showEdgeContours'] ??
          widget.settings.highlightsSettings.showEdgeContours;

      if (presetData['contourColor'] != null) {
        widget.settings.highlightsSettings.contourColor = Color(
          presetData['contourColor'],
        );
      }

      widget.settings.highlightsSettings.contourWidth =
          presetData['contourWidth']?.toDouble() ??
          widget.settings.highlightsSettings.contourWidth;

      if (presetData['highlightsAnimOptions'] != null) {
        widget.settings.highlightsSettings.highlightsAnimOptions =
            AnimationOptions.fromMap(
              Map<String, dynamic>.from(presetData['highlightsAnimOptions']),
            );
      }

      widget.onSettingsChanged(widget.settings);

      // Process edge detection if enabled
      if (widget.settings.highlightsEnabled &&
          widget.settings.highlightsSettings.showEdgeContours) {
        _processEdgeDetection();
      }
    });
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'highlightsEnabled': widget.settings.highlightsEnabled,
      'highlightsAnimated':
          widget.settings.highlightsSettings.highlightsAnimated,
      'showEdgeContours': widget.settings.highlightsSettings.showEdgeContours,
      'contourColor': widget.settings.highlightsSettings.contourColor.value,
      'contourWidth': widget.settings.highlightsSettings.contourWidth,
      'highlightsAnimOptions': widget
          .settings
          .highlightsSettings
          .highlightsAnimOptions
          .toMap(),
    };

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  // Static cache for preset management
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
    // Call the central refresh method for immediate UI update
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return success;
  }
}
