// This is a barrel file that exports all shader-related components

// First export the debug flag to avoid conflicts
export 'debug_flags.dart' show enableShaderDebugLogs;

// Export individual shader effect widgets
export 'blur_effect_shader.dart' hide enableShaderDebugLogs;
export 'color_effect_shader.dart' hide enableShaderDebugLogs;
export 'noise_effect_shader.dart' hide enableShaderDebugLogs;
export 'rain_effect_shader.dart' hide enableShaderDebugLogs;
export 'chromatic_effect_shader.dart' hide enableShaderDebugLogs;
export 'ripple_effect_shader.dart' hide enableShaderDebugLogs;
export 'cymatics_effect_shader.dart' hide enableShaderDebugLogs;

// Export utility classes
export 'custom_shader_builder.dart';

// Helper functions
export 'blur_effect_shader.dart' show applyBlurEffect;
export 'cymatics_effect_shader.dart' show applyCymaticsEffect;
