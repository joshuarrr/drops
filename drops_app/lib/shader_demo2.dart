import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ShaderDemo2 extends StatefulWidget {
  const ShaderDemo2({super.key});

  @override
  State<ShaderDemo2> createState() => _ShaderDemo2State();
}

enum ShaderEffect { none, wave, color, pixelate }

class _ShaderDemo2State extends State<ShaderDemo2>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  late AnimationController _controller;

  // Currently selected shader effect
  ShaderEffect _selectedEffect = ShaderEffect.wave;

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

    // Create animation controller for simple shader effect
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Delay full immersive mode until after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up system UI to be fully immersive
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
            // Animated shader effect
            _buildShaderEffect(),

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
                  child: Column(
                    children: [
                      Row(
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
                      const SizedBox(height: 8),
                      _buildEffectSelector(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShaderEffect() {
    if (_selectedEffect == ShaderEffect.none) {
      return Image.asset(
        _selectedImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (_selectedEffect) {
          case ShaderEffect.wave:
            return _buildWaveEffect();
          case ShaderEffect.color:
            return _buildColorEffect();
          case ShaderEffect.pixelate:
            return _buildPixelateEffect();
          default:
            return Image.asset(
              _selectedImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
        }
      },
    );
  }

  Widget _buildWaveEffect() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return ui.Gradient.linear(
          Offset(bounds.width * _controller.value, 0),
          Offset(bounds.width * (_controller.value + 0.2), bounds.height),
          [
            Colors.white.withOpacity(1.0),
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
          [0.0, 0.5, 1.0],
          TileMode.mirror,
        );
      },
      child: Image.asset(
        _selectedImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildColorEffect() {
    final hue = (_controller.value * 360).toInt();
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        0.5 + 0.5 * _controller.value,
        0.5 - 0.5 * _controller.value,
        0,
        0,
        0,
        0,
        0.5 + 0.5 * _controller.value,
        0.5 - 0.5 * _controller.value,
        0,
        0,
        0.5 - 0.5 * _controller.value,
        0,
        0.5 + 0.5 * _controller.value,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: Image.asset(
        _selectedImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildPixelateEffect() {
    final pixels = 100 + 100 * (1 - _controller.value.abs());

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: 0.5 + 1.5 * _controller.value,
        sigmaY: 0.5 + 1.5 * _controller.value,
      ),
      child: Image.asset(
        _selectedImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
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
        }
      },
      items: _availableImages.map<DropdownMenuItem<String>>((String value) {
        final filename = value.split('/').last.split('.').first;
        return DropdownMenuItem<String>(value: value, child: Text(filename));
      }).toList(),
    );
  }

  Widget _buildEffectSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEffectButton(ShaderEffect.none, Icons.panorama, 'None'),
        _buildEffectButton(ShaderEffect.wave, Icons.waves, 'Wave'),
        _buildEffectButton(ShaderEffect.color, Icons.color_lens, 'Color'),
        _buildEffectButton(ShaderEffect.pixelate, Icons.grain, 'Blur'),
      ],
    );
  }

  Widget _buildEffectButton(ShaderEffect effect, IconData icon, String label) {
    final isSelected = _selectedEffect == effect;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedEffect = effect;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
