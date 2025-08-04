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

// Export utility classes
export 'custom_shader_builder.dart';

// Helper functions
export 'blur_effect_shader.dart' show applyBlurEffect;
