import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _loadImage();
  }

  void _loadImage() async {
    try {
      final ByteData data = await DefaultAssetBundle.of(
        context,
      ).load('assets/img/image1.jpg.webp');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();

      setState(() {
        _loadedImage = fi.image;
        _isLoading = false;
      });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shader Demo'), elevation: 0),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
            ..setFloat(0, _controller.value * 10.0) // uTime
            ..setFloat(1, size.width) // uResolution.x
            ..setFloat(2, size.height) // uResolution.y
            ..setImageSampler(0, _loadedImage!); // uTexture

          return SizedBox.expand(
            child: CustomPaint(painter: ShaderPainter(shader)),
          );
        });
      },
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
