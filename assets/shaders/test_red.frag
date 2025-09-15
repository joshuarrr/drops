#version 320 es

#include <flutter/runtime_effect.glsl>

precision highp float;

// Define output
out vec4 fragColor;

void main() {
    // Just output a solid red color
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
