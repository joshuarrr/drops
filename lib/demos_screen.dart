import 'package:flutter/material.dart';
import 'shader_demo/shader_demo.dart';
import 'shader_demo_v2/views/shader_demo_screen.dart';
import 'shader_demo_v2/test_animation.dart';
import 'shader_demo_v3/index.dart';
import 'typography_demo.dart';
import 'cymatics_demo.dart';
import 'common/app_scaffold.dart';

class DemosScreen extends StatelessWidget {
  const DemosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Gradient colors based on theme
    final List<Color> gradientColors = isDarkMode
        ? [Colors.black, Colors.grey[800]!, Colors.black]
        : [Colors.white, Colors.grey[300]!, Colors.white];

    return AppScaffold(
      title: 'Demos',
      currentIndex: 1, // Demos tab
      showBackButton: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              _buildDemoCard(
                context,
                'Shaders',
                'Image display with simple bitmap shader',
                Icons.auto_fix_high,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShaderDemo()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDemoCard(
                context,
                'Shaders V2',
                'Advanced shader effects with enhanced controls',
                Icons.auto_awesome,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShaderDemoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDemoCard(
                context,
                'Fonts',
                'Explore text styles and typography options',
                Icons.text_fields,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TypographyDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDemoCard(
                context,
                'Cymatics',
                'Visualize sound waves and patterns',
                Icons.waves,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CymaticsDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDemoCard(
                context,
                'Shaders V3',
                'Simplified shader animation demo',
                Icons.animation,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShaderDemoV3(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDemoCard(
                context,
                'Animation Test',
                'Super simple animation test',
                Icons.bug_report,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnimationTestScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(icon, size: 40, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        child: Text(title),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        child: Text(description),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
