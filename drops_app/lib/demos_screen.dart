import 'package:flutter/material.dart';
import 'shader_demo.dart';
import 'shader_demo2.dart';

class DemosScreen extends StatelessWidget {
  const DemosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demos'),
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.blueGrey, Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoCard(
                context,
                'Advanced Shader Demo',
                'Image display with advanced shader effects',
                Icons.blur_on,
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
                'Simple Shader Demo',
                'Image display with simple bitmap shader',
                Icons.auto_fix_high,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShaderDemo2(),
                    ),
                  );
                },
              ),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.black.withOpacity(0.7),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
