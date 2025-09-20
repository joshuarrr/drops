// This is a barrel file that exports all shader-related components

// First export the debug flags to avoid conflicts
export 'debug_flags.dart'
    show enableShaderDebugLogs, enableAnimationDebugLogs, AnimationLogger;

// Export individual shader effect widgets
export 'blur_effect_shader.dart'
    hide enableShaderDebugLogs, enableAnimationDebugLogs;
export 'color_effect_shader.dart'
    hide enableShaderDebugLogs, enableAnimationDebugLogs;
export 'noise_effect_shader.dart' hide enableShaderDebugLogs;
export 'rain_effect_shader.dart' hide enableShaderDebugLogs;
export 'chromatic_effect_shader.dart' hide enableShaderDebugLogs;
export 'ripple_effect_shader.dart' hide enableShaderDebugLogs;
export 'sketch_effect_shader.dart' hide enableShaderDebugLogs;
export 'edge_effect_shader.dart' hide enableShaderDebugLogs;
export 'glitch_shader.dart' hide enableShaderDebugLogs;
export 'vhs_shader.dart' hide enableShaderDebugLogs;

// Export utility classes
export 'custom_shader_builder.dart';

// Helper functions
export 'blur_effect_shader.dart' show applyBlurEffect;
export 'sketch_effect_shader.dart' show applySketchEffect;
export 'edge_effect_shader.dart' show applyEdgeEffect;
export 'glitch_shader.dart' show applyGlitchEffect;
export 'vhs_shader.dart' show applyVHSEffect;
