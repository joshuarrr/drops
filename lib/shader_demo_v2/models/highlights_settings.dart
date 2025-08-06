import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'dart:developer' as developer;

/// Settings for the Highlights effect
class HighlightsSettings {
  // Static flag for controlling logging
  static bool enableLogging = true;

  // Tag for logging
  static const String _logTag = 'HighlightsSettings';
  // Core properties
  bool _highlightsEnabled = false;
  bool _highlightsAnimated = false;
  bool _applyToImage = true;
  bool _applyToText = true;

  // Edge detection properties
  bool _showEdgeContours = true;
  Color _contourColor = Colors.green;
  double _contourWidth = 2.0;

  // Animation options
  AnimationOptions _highlightsAnimOptions = AnimationOptions();

  // Getters and setters
  bool get highlightsEnabled => _highlightsEnabled;
  set highlightsEnabled(bool value) {
    _highlightsEnabled = value;
  }

  bool get highlightsAnimated => _highlightsAnimated;
  set highlightsAnimated(bool value) {
    _highlightsAnimated = value;
  }

  bool get applyToImage => _applyToImage;
  set applyToImage(bool value) {
    _applyToImage = value;
  }

  bool get applyToText => _applyToText;
  set applyToText(bool value) {
    _applyToText = value;
  }

  AnimationOptions get highlightsAnimOptions => _highlightsAnimOptions;
  set highlightsAnimOptions(AnimationOptions value) {
    _highlightsAnimOptions = value;
  }

  // Edge contour getters and setters
  bool get showEdgeContours => _showEdgeContours;
  set showEdgeContours(bool value) {
    _showEdgeContours = value;
  }

  Color get contourColor => _contourColor;
  set contourColor(Color value) {
    _contourColor = value;
  }

  double get contourWidth => _contourWidth;
  set contourWidth(double value) {
    _contourWidth = value;
  }

  // Constructor
  HighlightsSettings({
    bool highlightsEnabled = false,
    bool highlightsAnimated = false,
    bool applyToImage = true,
    bool applyToText = true,
    bool showEdgeContours = true,
    Color? contourColor,
    double contourWidth = 2.0,
    AnimationOptions? highlightsAnimOptions,
  }) {
    _highlightsEnabled = highlightsEnabled;
    _highlightsAnimated = highlightsAnimated;
    _applyToImage = applyToImage;
    _applyToText = applyToText;
    _showEdgeContours = showEdgeContours;
    _contourColor = contourColor ?? Colors.green;
    _contourWidth = contourWidth;
    _highlightsAnimOptions = highlightsAnimOptions ?? AnimationOptions();
  }

  // Copy constructor
  HighlightsSettings copyWith({
    bool? highlightsEnabled,
    bool? highlightsAnimated,
    bool? applyToImage,
    bool? applyToText,
    bool? showEdgeContours,
    Color? contourColor,
    double? contourWidth,
    AnimationOptions? highlightsAnimOptions,
  }) {
    return HighlightsSettings(
      highlightsEnabled: highlightsEnabled ?? _highlightsEnabled,
      highlightsAnimated: highlightsAnimated ?? _highlightsAnimated,
      applyToImage: applyToImage ?? _applyToImage,
      applyToText: applyToText ?? _applyToText,
      showEdgeContours: showEdgeContours ?? _showEdgeContours,
      contourColor: contourColor ?? _contourColor,
      contourWidth: contourWidth ?? _contourWidth,
      highlightsAnimOptions: highlightsAnimOptions ?? _highlightsAnimOptions,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'highlightsEnabled': _highlightsEnabled,
      'highlightsAnimated': _highlightsAnimated,
      'applyToImage': _applyToImage,
      'applyToText': _applyToText,
      'showEdgeContours': _showEdgeContours,
      'contourColor': _contourColor.value,
      'contourWidth': _contourWidth,
      'highlightsAnimOptions': _highlightsAnimOptions.toMap(),
    };
  }

  // Create from map for deserialization
  factory HighlightsSettings.fromMap(Map<String, dynamic> map) {
    return HighlightsSettings(
      highlightsEnabled: map['highlightsEnabled'] ?? false,
      highlightsAnimated: map['highlightsAnimated'] ?? false,
      applyToImage: map['applyToImage'] ?? true,
      applyToText: map['applyToText'] ?? true,
      showEdgeContours: map['showEdgeContours'] ?? true,
      contourColor: map['contourColor'] != null
          ? Color(map['contourColor'])
          : Colors.green,
      contourWidth: map['contourWidth']?.toDouble() ?? 2.0,
      highlightsAnimOptions: map['highlightsAnimOptions'] != null
          ? AnimationOptions.fromMap(map['highlightsAnimOptions'])
          : AnimationOptions(),
    );
  }

  // Reset to default values
  void reset() {
    _highlightsEnabled = false;
    _highlightsAnimated = false;
    _applyToImage = true;
    _applyToText = true;
    _showEdgeContours = true;
    _contourColor = Colors.green;
    _contourWidth = 2.0;
    _highlightsAnimOptions = AnimationOptions();
  }

  // Check if settings have changed
  bool hasChanged(HighlightsSettings other) {
    return _highlightsEnabled != other._highlightsEnabled ||
        _highlightsAnimated != other._highlightsAnimated ||
        _applyToImage != other._applyToImage ||
        _applyToText != other._applyToText ||
        _showEdgeContours != other._showEdgeContours ||
        _contourColor != other._contourColor ||
        _contourWidth != other._contourWidth;
  }
}
