# Drops App

A Flutter application that demonstrates advanced visual effects using shaders and animations.

## Features

- Beautiful gradient animations
- GLSL shader integration for dynamic visual effects
- Interactive UI with bottom navigation
- iOS simulator support

## Getting Started

### Prerequisites

- Flutter SDK (^3.9.0)
- Xcode (for iOS development)
- iOS Simulator

### Running the App

The easiest way to run the app on iOS simulator is by using the provided script:

```bash
# Make sure the script is executable
chmod +x run_simulator.sh

# Run the app on iOS simulator
./run_simulator.sh
```

This script will:
1. Launch the iOS simulator
2. Wait for it to boot completely
3. Automatically deploy and run the app

### Manual Run

You can also run the app manually:

```bash
# Open the iOS simulator
open -a Simulator

# Run the app on the booted simulator
flutter run
```

## Development

- The main app UI is in `lib/main.dart`
- Shader effects are in `lib/shader_demo.dart`
- GLSL shader code is in `assets/simple_shader.frag`

## Controls

When running the app in debug mode:
- `r`: Hot reload
- `R`: Hot restart
- `q`: Quit
