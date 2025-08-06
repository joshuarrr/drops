import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';

/// Service for detecting edges in images using Google ML Kit
class EdgeDetectionService {
  static final EdgeDetectionService _instance =
      EdgeDetectionService._internal();

  // Singleton instance
  factory EdgeDetectionService() => _instance;

  // ML Kit detectors
  late final ImageLabeler _imageLabeler;
  late final ObjectDetector _objectDetector;

  // Image dimensions and data
  Size _imageSize = Size(100, 100);
  List<Offset> _edgePoints = [];
  Path? _edgePath;

  // Processing state
  bool _isProcessing = false;

  // Results stream
  final _edgesController = StreamController<Path>.broadcast();
  Stream<Path> get edgesStream => _edgesController.stream;

  // Constructor
  EdgeDetectionService._internal() {
    // Initialize ML Kit detectors
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    _objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
  }

  // Getter for edge points
  List<Offset> get edgePoints => List.unmodifiable(_edgePoints);

  // Getter for edge path
  Path? get edgePath => _edgePath;

  // Getter for image size
  Size get imageSize => _imageSize;

  /// Process an image asset for edge detection using ML Kit
  Future<Path?> processImageForEdges(String imagePath) async {
    // Validate input
    if (imagePath.isEmpty) {
      print('Empty image path provided');
      return null;
    }

    // Prevent duplicate processing
    if (_isProcessing) {
      print('Already processing an image, skipping');
      return _edgePath;
    }

    // Start processing
    _isProcessing = true;
    print('Processing image for edge detection: $imagePath');

    try {
      // Reset state
      _edgePoints = [];
      _edgePath = null;

      // Load image asset as bytes
      final ByteData data = await rootBundle.load(imagePath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Get image dimensions using image package
      final img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Store image size for scaling calculations
      _imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      print('Image loaded with size: ${_imageSize.width}x${_imageSize.height}');

      // Save image to temporary file for ML Kit processing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_edge_detection.png');
      await tempFile.writeAsBytes(bytes);

      // Create InputImage for ML Kit
      final inputImage = InputImage.fromFilePath(tempFile.path);

      // Use ML Kit Object Detection to find objects and their boundaries
      final objects = await _objectDetector.processImage(inputImage);
      print('ML Kit detected ${objects.length} objects');

      // Perform actual edge detection on the image
      _edgePath = await _performActualEdgeDetection(decodedImage, objects);

      // Notify listeners
      if (_edgePath != null) {
        _edgesController.add(_edgePath!);
        print('Edge path created from actual edge detection');
      }

      return _edgePath;
    } catch (e) {
      print('Error in ML Kit edge detection: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Perform actual edge detection on the image
  Future<Path?> _performActualEdgeDetection(
    img.Image image,
    List<DetectedObject> objects,
  ) async {
    // Convert to grayscale for edge detection
    final grayscale = img.grayscale(image);

    // If we have detected objects, focus on the largest one
    Rect? focusRegion;
    if (objects.isNotEmpty) {
      // Sort by area and take the largest
      objects.sort((a, b) {
        final aArea = a.boundingBox.width * a.boundingBox.height;
        final bArea = b.boundingBox.width * b.boundingBox.height;
        return bArea.compareTo(aArea);
      });

      final mainObject = objects.first;
      focusRegion = mainObject.boundingBox;
      print(
        'Focusing edge detection on object: ${mainObject.labels.map((l) => l.text).join(', ')}',
      );
    }

    // Perform actual edge detection on the entire image or focused region
    final edgePoints = _detectEdgesInImage(grayscale, focusRegion);

    if (edgePoints.isEmpty) {
      print('No edges detected, using fallback');
      return _createFallbackOutline();
    }

    // Create a path from the detected edge points
    final path = _createPathFromEdgePoints(edgePoints);
    _edgePoints = edgePoints;

    return path;
  }

  /// Detect edges in the image using Canny-like edge detection
  List<Offset> _detectEdgesInImage(img.Image grayscale, Rect? focusRegion) {
    final width = grayscale.width;
    final height = grayscale.height;

    // Define the region to process
    int startX = 0, startY = 0, endX = width, endY = height;
    if (focusRegion != null) {
      startX = focusRegion.left.toInt().clamp(0, width);
      startY = focusRegion.top.toInt().clamp(0, height);
      endX = focusRegion.right.toInt().clamp(0, width);
      endY = focusRegion.bottom.toInt().clamp(0, height);
    }

    print('Detecting edges in region: $startX,$startY to $endX,$endY');

    // Step 1: Create gradient magnitude map
    final gradientMap = _createGradientMap(
      grayscale,
      startX,
      startY,
      endX,
      endY,
    );

    // Step 2: Apply non-maximum suppression
    final suppressedMap = _applyNonMaximumSuppression(
      gradientMap,
      startX,
      startY,
      endX,
      endY,
    );

    // Step 3: Apply double thresholding and edge tracking
    final edgeMap = _applyDoubleThresholding(
      suppressedMap,
      startX,
      startY,
      endX,
      endY,
    );

    // Step 4: Find coherent contours instead of random edge points
    final contours = _findCoherentContours(edgeMap, startX, startY, endX, endY);

    if (contours.isNotEmpty) {
      // Use the largest contour
      final mainContour = contours.reduce(
        (a, b) => a.length > b.length ? a : b,
      );
      print('Using main contour with ${mainContour.length} points');
      return mainContour;
    }

    print('No coherent contours found');
    return [];
  }

  /// Find coherent contours from the edge map
  List<List<Offset>> _findCoherentContours(
    List<List<bool>> edgeMap,
    int startX,
    int startY,
    int endX,
    int endY,
  ) {
    final contours = <List<Offset>>[];
    final visited = List.generate(
      edgeMap.length,
      (i) => List.filled(edgeMap[i].length, false),
    );

    // 8-directional search for contour tracing
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (int y = 0; y < edgeMap.length; y++) {
      for (int x = 0; x < edgeMap[y].length; x++) {
        if (edgeMap[y][x] && !visited[y][x]) {
          // Start a new contour
          final contour = <Offset>[];
          _traceContour(edgeMap, visited, x, y, contour, directions);

          // Only add contours with sufficient points and reasonable shape
          if (contour.length > 20 && _isReasonableContour(contour)) {
            // Convert to actual image coordinates
            final actualContour = contour
                .map((point) => Offset(point.dx + startX, point.dy + startY))
                .toList();
            contours.add(actualContour);
          }
        }
      }
    }

    return contours;
  }

  /// Trace a single contour starting from a given point
  void _traceContour(
    List<List<bool>> edgeMap,
    List<List<bool>> visited,
    int startX,
    int startY,
    List<Offset> contour,
    List<List<int>> directions,
  ) {
    int x = startX, y = startY;
    int direction = 0;

    do {
      visited[y][x] = true;
      contour.add(Offset(x.toDouble(), y.toDouble()));

      // Find next edge pixel in 8 directions
      bool found = false;
      for (int i = 0; i < 8; i++) {
        final nextDir = (direction + i) % 8;
        final dx = directions[nextDir][0];
        final dy = directions[nextDir][1];
        final nx = x + dx;
        final ny = y + dy;

        if (nx >= 0 &&
            nx < edgeMap[0].length &&
            ny >= 0 &&
            ny < edgeMap.length) {
          if (edgeMap[ny][nx] && !visited[ny][nx]) {
            x = nx;
            y = ny;
            direction = nextDir;
            found = true;
            break;
          }
        }
      }

      if (!found) break;
    } while (x != startX ||
        y != startY ||
        contour.length < 1000); // Prevent infinite loops
  }

  /// Check if a contour has a reasonable shape (not too jagged or scattered)
  bool _isReasonableContour(List<Offset> contour) {
    if (contour.length < 10) return false;

    // Calculate the bounding box
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (final point in contour) {
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
      maxX = math.max(maxX, point.dx);
      maxY = math.max(maxY, point.dy);
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final area = width * height;
    final contourLength = contour.length;

    // Check if the contour is reasonably compact (not too scattered)
    final density = contourLength / area;
    if (density < 0.01) return false; // Too scattered

    // Check if the aspect ratio is reasonable (not too elongated)
    final aspectRatio = width / height;
    if (aspectRatio > 10 || aspectRatio < 0.1) return false; // Too elongated

    return true;
  }

  /// Create gradient magnitude map using Sobel operators
  List<List<double>> _createGradientMap(
    img.Image grayscale,
    int startX,
    int startY,
    int endX,
    int endY,
  ) {
    final width = endX - startX;
    final height = endY - startY;
    final gradientMap = List.generate(height, (i) => List.filled(width, 0.0));

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final actualX = startX + x;
        final actualY = startY + y;

        // Calculate gradients using Sobel operators
        final gx = _sobelX(grayscale, actualX, actualY);
        final gy = _sobelY(grayscale, actualX, actualY);
        final magnitude = math.sqrt(gx * gx + gy * gy);

        gradientMap[y][x] = magnitude;
      }
    }

    return gradientMap;
  }

  /// Apply non-maximum suppression to thin edges
  List<List<double>> _applyNonMaximumSuppression(
    List<List<double>> gradientMap,
    int startX,
    int startY,
    int endX,
    int endY,
  ) {
    final width = endX - startX;
    final height = endY - startY;
    final suppressedMap = List.generate(height, (i) => List.filled(width, 0.0));

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final magnitude = gradientMap[y][x];
        if (magnitude == 0) continue;

        // Calculate gradient direction
        final gx = gradientMap[y][x + 1] - gradientMap[y][x - 1];
        final gy = gradientMap[y + 1][x] - gradientMap[y - 1][x];
        final angle = math.atan2(gy, gx) * 180 / math.pi;

        // Normalize angle to 0, 45, 90, 135 degrees
        double normalizedAngle = angle;
        if (angle < 0) normalizedAngle += 180;
        if (normalizedAngle >= 157.5)
          normalizedAngle = 0;
        else if (normalizedAngle >= 112.5)
          normalizedAngle = 135;
        else if (normalizedAngle >= 67.5)
          normalizedAngle = 90;
        else if (normalizedAngle >= 22.5)
          normalizedAngle = 45;
        else
          normalizedAngle = 0;

        // Check neighbors in the gradient direction
        bool isMax = true;
        if (normalizedAngle == 0) {
          // Horizontal
          if (magnitude < gradientMap[y][x - 1] ||
              magnitude < gradientMap[y][x + 1]) {
            isMax = false;
          }
        } else if (normalizedAngle == 45) {
          // Diagonal
          if (magnitude < gradientMap[y - 1][x + 1] ||
              magnitude < gradientMap[y + 1][x - 1]) {
            isMax = false;
          }
        } else if (normalizedAngle == 90) {
          // Vertical
          if (magnitude < gradientMap[y - 1][x] ||
              magnitude < gradientMap[y + 1][x]) {
            isMax = false;
          }
        } else if (normalizedAngle == 135) {
          // Diagonal
          if (magnitude < gradientMap[y - 1][x - 1] ||
              magnitude < gradientMap[y + 1][x + 1]) {
            isMax = false;
          }
        }

        if (isMax) {
          suppressedMap[y][x] = magnitude;
        }
      }
    }

    return suppressedMap;
  }

  /// Apply double thresholding to create strong and weak edges
  List<List<bool>> _applyDoubleThresholding(
    List<List<double>> suppressedMap,
    int startX,
    int startY,
    int endX,
    int endY,
  ) {
    final width = endX - startX;
    final height = endY - startY;
    final edgeMap = List.generate(height, (i) => List.filled(width, false));

    // Find high and low thresholds
    double maxMagnitude = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (suppressedMap[y][x] > maxMagnitude) {
          maxMagnitude = suppressedMap[y][x];
        }
      }
    }

    // Lower thresholds to detect more edges
    final highThreshold = maxMagnitude * 0.15; // Reduced from 0.3
    final lowThreshold = highThreshold * 0.1; // Reduced from 0.2

    print('Thresholds: high=$highThreshold, low=$lowThreshold');

    // Apply double thresholding
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final magnitude = suppressedMap[y][x];
        if (magnitude >= highThreshold) {
          edgeMap[y][x] = true;
        } else if (magnitude >= lowThreshold) {
          // Check if connected to strong edge
          if (_isConnectedToStrongEdge(suppressedMap, x, y, highThreshold)) {
            edgeMap[y][x] = true;
          }
        }
      }
    }

    return edgeMap;
  }

  /// Check if a weak edge is connected to a strong edge
  bool _isConnectedToStrongEdge(
    List<List<double>> suppressedMap,
    int x,
    int y,
    double highThreshold,
  ) {
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx >= 0 &&
            nx < suppressedMap[0].length &&
            ny >= 0 &&
            ny < suppressedMap.length) {
          if (suppressedMap[ny][nx] >= highThreshold) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Create a detailed outline around a detected object
  Path _createDetailedOutline(img.Image grayscale, Rect? focusRegion) {
    if (focusRegion == null) {
      // No object detected, create a fallback outline
      return _createFallbackOutline();
    }

    // Expand the region slightly to capture the full object
    final expandedRegion = Rect.fromLTRB(
      (focusRegion.left - focusRegion.width * 0.1).clamp(
        0.0,
        grayscale.width.toDouble(),
      ),
      (focusRegion.top - focusRegion.height * 0.1).clamp(
        0.0,
        grayscale.height.toDouble(),
      ),
      (focusRegion.right + focusRegion.width * 0.1).clamp(
        0.0,
        grayscale.width.toDouble(),
      ),
      (focusRegion.bottom + focusRegion.height * 0.1).clamp(
        0.0,
        grayscale.height.toDouble(),
      ),
    );

    print('Creating detailed outline for region: ${expandedRegion.toString()}');

    // Use the new edge detection approach
    final edgePoints = _detectEdgesInImage(grayscale, expandedRegion);

    if (edgePoints.isEmpty) {
      print('No edge points found, using fallback');
      return _createFallbackOutline();
    }

    // Create a path from the edge points
    return _createPathFromEdgePoints(edgePoints);
  }

  // Removed old sampling methods - now using proper Canny-like edge detection

  /// Calculate horizontal gradient using Sobel operator
  double _sobelX(img.Image grayscale, int x, int y) {
    final gx = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];

    double sum = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final pixel = grayscale.getPixel(x + i, y + j);
        final luminance = img.getLuminance(pixel);
        sum += luminance * gx[i + 1][j + 1];
      }
    }
    return sum;
  }

  /// Calculate vertical gradient using Sobel operator
  double _sobelY(img.Image grayscale, int x, int y) {
    final gy = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1],
    ];

    double sum = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final pixel = grayscale.getPixel(x + i, y + j);
        final luminance = img.getLuminance(pixel);
        sum += luminance * gy[i + 1][j + 1];
      }
    }
    return sum;
  }

  /// Calculate distance between two points
  double _distance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Create a fallback outline when no objects are detected
  Path _createFallbackOutline() {
    final path = Path();
    final centerX = _imageSize.width / 2;
    final centerY =
        _imageSize.height * 0.4; // Focus on upper part where faces usually are
    final width = _imageSize.width * 0.4;
    final height = _imageSize.height * 0.6;

    // Create a face-like oval
    path.addOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: width,
        height: height,
      ),
    );

    // Convert path to edge points
    _createEdgePointsFromPath(path);

    return path;
  }

  /// Convert a path to edge points for drawing
  void _createEdgePointsFromPath(Path path) {
    try {
      final metrics = path.computeMetrics();
      if (metrics.isEmpty) {
        print('Path has no metrics, creating fallback edge points');
        _createFallbackEdgePoints();
        return;
      }

      final numPoints = 72; // Number of points to generate
      _edgePoints = [];

      // Process each segment of the path
      int pointsPerSegment = (numPoints ~/ metrics.length).clamp(1, numPoints);
      if (pointsPerSegment < 5) pointsPerSegment = 5;

      for (final metric in metrics) {
        final length = metric.length;
        // Skip very short segments
        if (length < 5) continue;

        for (int i = 0; i < pointsPerSegment; i++) {
          final distance = i / (pointsPerSegment - 1) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            _edgePoints.add(tangent.position);
          }
        }
      }

      // If we still don't have enough points, add some from the fallback
      if (_edgePoints.length < 10) {
        print(
          'Not enough edge points (${_edgePoints.length}), adding fallback points',
        );
        _createFallbackEdgePoints();
      } else {
        print('Created ${_edgePoints.length} edge points from path');
      }
    } catch (e) {
      print('Error creating edge points from path: $e');
      _createFallbackEdgePoints();
    }
  }

  /// Create fallback edge points if path computation fails
  void _createFallbackEdgePoints() {
    _edgePoints = [];
    final centerX = _imageSize.width / 2;
    final centerY = _imageSize.height * 0.4;
    final radiusX = _imageSize.width * 0.2;
    final radiusY = _imageSize.height * 0.325;

    for (int i = 0; i < 72; i++) {
      final angle = i * (math.pi * 2 / 72);
      _edgePoints.add(
        Offset(
          centerX + radiusX * math.cos(angle),
          centerY + radiusY * math.sin(angle),
        ),
      );
    }
  }

  /// Create a path from edge points
  Path _createPathFromEdgePoints(List<Offset> points) {
    final path = Path();

    if (points.isEmpty) return path;

    // Start at the first point
    path.moveTo(points[0].dx, points[0].dy);

    // Connect points with smooth curves
    if (points.length == 1) {
      // Single point - create a small circle
      final radius = 5.0;
      path.addOval(
        Rect.fromCenter(
          center: points[0],
          width: radius * 2,
          height: radius * 2,
        ),
      );
    } else if (points.length == 2) {
      // Two points - draw a line
      path.lineTo(points[1].dx, points[1].dy);
    } else {
      // Multiple points - create a smooth closed path
      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final next = points[(i + 1) % points.length];

        // Use quadratic curves for smoothness
        if (i < points.length - 1) {
          final controlX = (current.dx + next.dx) / 2;
          final controlY = (current.dy + next.dy) / 2;
          path.quadraticBezierTo(current.dx, current.dy, controlX, controlY);
        } else {
          // Close the path smoothly
          final first = points[0];
          final controlX = (current.dx + first.dx) / 2;
          final controlY = (current.dy + first.dy) / 2;
          path.quadraticBezierTo(current.dx, current.dy, controlX, controlY);
        }
      }

      // Close the path
      path.close();
    }

    return path;
  }

  /// Create an edge painter for drawing the detected edges
  CustomPainter createEdgePainter({
    required Size displaySize,
    Color outlineColor = Colors.green,
    double strokeWidth = 2.0,
    bool glowEffect = false,
    Color glowColor = Colors.white,
  }) {
    return EdgePainter(
      edgePath: _edgePath,
      edgePoints: _edgePoints,
      imageSize: _imageSize,
      displaySize: displaySize,
      outlineColor: outlineColor,
      strokeWidth: strokeWidth,
      glowEffect: glowEffect,
      glowColor: glowColor,
    );
  }

  /// Clean up resources
  void dispose() {
    _imageLabeler.close();
    _objectDetector.close();
    _edgesController.close();
  }
}

/// Custom painter for drawing detected edges
class EdgePainter extends CustomPainter {
  final Path? edgePath;
  final List<Offset> edgePoints;
  final Size imageSize;
  final Size displaySize;
  final Color outlineColor;
  final double strokeWidth;
  final bool glowEffect;
  final Color glowColor;

  EdgePainter({
    required this.edgePath,
    required this.edgePoints,
    required this.imageSize,
    required this.displaySize,
    required this.outlineColor,
    required this.strokeWidth,
    required this.glowEffect,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (edgePath == null) {
      // Draw a simple outline around the image area
      _drawSimpleOutline(canvas);
      return;
    }

    // Calculate scaling factors
    final scaleX = displaySize.width / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;

    // Create a scaled path if we have an edge path from detection
    if (edgePath != null && !edgePath!.getBounds().isEmpty) {
      // Scale the path to match display size
      final scaledPath = Path();
      scaledPath.addPath(
        edgePath!.transform(
          Matrix4.diagonal3Values(scaleX, scaleY, 1.0).storage,
        ),
        Offset.zero,
      );

      // Draw the edge outline with gradient for more visual interest
      final rect = scaledPath.getBounds();
      final gradient = LinearGradient(
        colors: [
          outlineColor.withOpacity(1.0),
          outlineColor
              .withOpacity(0.7)
              .withBlue((outlineColor.blue + 50) % 255),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      // Create paint for edges with gradient
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw the edge outline
      canvas.drawPath(scaledPath, paint);

      // Add glow effect if enabled
      if (glowEffect) {
        final glowPaint = Paint()
          ..color = glowColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 3.0
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 3.0);

        canvas.drawPath(scaledPath, glowPaint);
      }
    }

    // If we have edge points (from edge detection algorithm), draw them
    if (edgePoints.isNotEmpty && edgePoints.length >= 3) {
      // Sort points by angle from center for proper ordering
      final sortedPoints = List<Offset>.from(edgePoints);
      final centerX = displaySize.width / 2;
      final centerY = displaySize.height * 0.4; // Match where faces usually are

      sortedPoints.sort((a, b) {
        final scaledA = Offset(a.dx * scaleX, a.dy * scaleY);
        final scaledB = Offset(b.dx * scaleX, b.dy * scaleY);
        final angleA = math.atan2(scaledA.dy - centerY, scaledA.dx - centerX);
        final angleB = math.atan2(scaledB.dy - centerY, scaledB.dx - centerX);
        return angleA.compareTo(angleB);
      });

      // Create a smooth outline path
      final pointPath = Path();

      // Start with the first point
      final firstScaled = Offset(
        sortedPoints[0].dx * scaleX,
        sortedPoints[0].dy * scaleY,
      );
      pointPath.moveTo(firstScaled.dx, firstScaled.dy);

      // Add curved segments for a smoother outline
      if (sortedPoints.length >= 6) {
        for (int i = 0; i < sortedPoints.length; i += 2) {
          final next = Offset(
            sortedPoints[(i + 1) % sortedPoints.length].dx * scaleX,
            sortedPoints[(i + 1) % sortedPoints.length].dy * scaleY,
          );

          final nextNext = Offset(
            sortedPoints[(i + 2) % sortedPoints.length].dx * scaleX,
            sortedPoints[(i + 2) % sortedPoints.length].dy * scaleY,
          );

          // Use quadratic curve for smoother appearance
          pointPath.quadraticBezierTo(
            next.dx,
            next.dy,
            nextNext.dx,
            nextNext.dy,
          );
        }
      } else {
        // If too few points, use simple lines
        for (int i = 1; i < sortedPoints.length; i++) {
          final scaledPoint = Offset(
            sortedPoints[i].dx * scaleX,
            sortedPoints[i].dy * scaleY,
          );
          pointPath.lineTo(scaledPoint.dx, scaledPoint.dy);
        }
      }

      // Close the path to form a complete outline
      pointPath.close();

      // Draw the smooth outline
      final pointPaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(pointPath, pointPaint);

      // Add glow to the outline if enabled
      if (glowEffect) {
        final pointGlowPaint = Paint()
          ..color = glowColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 2.0);

        canvas.drawPath(pointPath, pointGlowPaint);
      }
    }
  }

  void _drawSimpleOutline(Canvas canvas) {
    final paint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(0, 0, displaySize.width, displaySize.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
