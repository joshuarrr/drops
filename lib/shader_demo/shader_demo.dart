import 'package:flutter/material.dart';

import 'shader_demo_impl.dart';

// Export the implementation for use elsewhere in the app
export 'shader_demo_impl.dart';

class ShaderDemo extends StatelessWidget {
  const ShaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the shader demo implementation
    return const ShaderDemoImpl();
  }
}
