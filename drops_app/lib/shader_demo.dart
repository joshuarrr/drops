import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ShaderDemo extends StatefulWidget {
  const ShaderDemo({super.key});

  @override
  State<ShaderDemo> createState() => _ShaderDemoState();
}

class _ShaderDemoState extends State<ShaderDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.Image? _loadedImage;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _imageLoadTimer;

  // List of available images
  final List<String> _availableImages = [
    'assets/img/image1.jpg.webp',
    'assets/img/darkside.png',
    'assets/img/bollocks.png',
    'assets/img/ill.png',
    'assets/img/londoncalling.png',
    'assets/img/image 197.png',
  ];

  // Currently selected image
  String _selectedImage = 'assets/img/darkside.png';

  @override
  void initState() {
    super.initState();

    // Use slower animation to reduce GPU load
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Increased from 5 to 10 seconds
      vsync: this,
    )..repeat();

    // Delay full immersive mode until after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up system UI to be fully immersive
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });

    _loadImage();
  }

  void _loadImage() async {
    // Cancel any previous load timer
    _imageLoadTimer?.cancel();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final completer = Completer<void>();

      // Set a timeout for image loading
      _imageLoadTimer = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.completeError('Image loading timed out');
        }
      });

      final ByteData data = await DefaultAssetBundle.of(
        context,
      ).load(_selectedImage);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: MediaQuery.of(
          context,
        ).size.width.toInt(), // Optimize image size
      );
      final ui.FrameInfo fi = await codec.getNextFrame();

      // Dispose of the previous image if it exists
      _loadedImage?.dispose();

      setState(() {
        _loadedImage = fi.image;
        _isLoading = false;
      });

      _imageLoadTimer?.cancel();

      if (!completer.isCompleted) {
        completer.complete();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadedImage?.dispose();
    _imageLoadTimer?.cancel();

    // Restore system UI when we leave this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full screen image
            _buildShaderBackground(),

            // Controls overlay that can be toggled
            if (_showControls)
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedImage.split('/').last.split('.').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildImageSelector(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShaderBackground() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading image: $_errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_loadedImage == null) {
      return const Center(child: Text('Failed to load image'));
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderBuilder(assetKey: 'assets/simple_shader.frag', (
          context,
          shader,
          child,
        ) {
          if (shader == null) {
            return const Center(child: Text('Shader not available'));
          }

          final size = MediaQuery.of(context).size;
          shader
            ..setFloat(
              0,
              _controller.value * 5.0,
            ) // uTime - reduced from 10.0 to 5.0
            ..setFloat(1, size.width) // uResolution.x
            ..setFloat(2, size.height) // uResolution.y
            ..setImageSampler(0, _loadedImage!); // uTexture

          return CustomPaint(
            size: Size(size.width, size.height),
            painter: ShaderPainter(shader),
          );
        });
      },
    );
  }

  Widget _buildImageSelector() {
    return DropdownButton<String>(
      dropdownColor: Colors.black.withOpacity(0.8),
      value: _selectedImage,
      icon: const Icon(Icons.arrow_downward, color: Colors.white),
      elevation: 16,
      style: const TextStyle(color: Colors.white),
      underline: Container(height: 2, color: Colors.white),
      onChanged: (String? value) {
        if (value != null && value != _selectedImage) {
          setState(() {
            _selectedImage = value;
          });
          _loadImage();
        }
      },
      items: _availableImages.map<DropdownMenuItem<String>>((String value) {
        final filename = value.split('/').last.split('.').first;
        return DropdownMenuItem<String>(value: value, child: Text(filename));
      }).toList(),
    );
  }
}

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
