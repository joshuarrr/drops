import 'package:flutter/material.dart';

import 'cymatics_demo/cymatics_demo_impl.dart';

// Export the implementation for use elsewhere in the app
export 'cymatics_demo/cymatics_demo_impl.dart';

class CymaticsDemo extends StatefulWidget {
  const CymaticsDemo({super.key});

  @override
  State<CymaticsDemo> createState() => _CymaticsDemoState();
}

class _CymaticsDemoState extends State<CymaticsDemo> {
  @override
  Widget build(BuildContext context) {
    // Wrap the implementation with a WillPopScope to ensure audio is stopped
    return WillPopScope(
      onWillPop: () async {
        // Use the static method to stop any playing audio
        await CymaticsDemoImpl.stopAudio();
        return true;
      },
      child: const CymaticsDemoImpl(),
    );
  }
}
