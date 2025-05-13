#!/bin/bash

# =============================================================================
# run.sh - Flutter App Simulator Launcher
# =============================================================================
# 
# DESCRIPTION:
#   This script automates launching a Flutter app on a specific iOS simulator
#   device. It handles the complete workflow including:
#   - Shutting down existing simulator instances
#   - Starting the simulator with a specific device
#   - Ensuring the simulator is properly booted
#   - Launching the Flutter application
#
# CONFIGURATION:
#   - DEVICE_NAME: Friendly name of the iOS simulator
#   - DEVICE_ID: UDID of the iOS simulator device
#
# OPTIONS:
#   -q, --quiet     Run in quiet mode (simulator stays in background until loaded)
#   -h, --help      Show this help message
#
# REQUIREMENTS:
#   - macOS with Xcode and iOS simulators installed
#   - Flutter SDK installed and configured
#
# USAGE:
#   ./run.sh [options]
#
# TROUBLESHOOTING:
#   If the simulator fails to appear, you can manually open it with:
#   open -a Simulator --args -CurrentDeviceUDID <device-id>
#
# =============================================================================

# Default settings
QUIET_MODE=false

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -q|--quiet) QUIET_MODE=true ;;
        -h|--help) 
            echo "Usage: ./run.sh [options]"
            echo "Options:"
            echo "  -q, --quiet   Run in quiet mode (simulator stays in background until loaded)"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Configure the device you want to use
DEVICE_NAME="iPhone SE (3rd generation)"
DEVICE_ID="27680D94-B56E-4319-AD48-EC8DA5D437ED"

# Utility function to start/focus simulator only if not in quiet mode
activate_simulator() {
    if [ "$QUIET_MODE" = false ]; then
        osascript -e 'tell application "Simulator" to activate' &>/dev/null
    fi
}

# Completely kill any running simulator processes
echo "Shutting down all simulator processes..."
xcrun simctl shutdown all 2>/dev/null
killall Simulator CoreSimulatorBridge SimulatorTrampoline 2>/dev/null || true
sleep 2

# Boot the simulator in a more efficient way
echo "Starting simulator and booting device: $DEVICE_NAME..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true

# Only open the Simulator UI if not in quiet mode
if [ "$QUIET_MODE" = false ]; then
    open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID"
    sleep 2
else
    # In quiet mode, we still need the Simulator app running but don't need to show it
    open -a Simulator -g
    sleep 2
fi

# Check if the simulator booted successfully
if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
    echo "Error: Failed to boot the simulator. Trying one more approach..."
    
    # Kill simulator completely and try once more
    killall Simulator 2>/dev/null || true
    sleep 2
    
    # Try booting again with a cleaner approach
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    
    if [ "$QUIET_MODE" = false ]; then
        open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID"
    else
        open -a Simulator -g
    fi
    
    sleep 3
    
    # Check one last time
    if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
        echo "Error: Could not get the simulator running properly."
        exit 1
    fi
fi

echo "Simulator is now booted."

# Provide help message only if not in quiet mode
if [ "$QUIET_MODE" = false ]; then
    echo "If you don't see the simulator window, try manually opening:"
    echo "open -a Simulator --args -CurrentDeviceUDID $DEVICE_ID"
fi

# Reduced wait time
sleep 2

# Run the Flutter app and monitor for app loading completion
echo "Launching Flutter app on $DEVICE_NAME..."
if [ "$QUIET_MODE" = true ]; then
    # Create a temporary file for output
    TEMP_OUTPUT=$(mktemp)
    
    # Run Flutter in background and capture output
    flutter run -d "$DEVICE_ID" 2>&1 | tee "$TEMP_OUTPUT" &
    FLUTTER_PID=$!
    
    # Look for the message indicating app is loaded
    echo "Waiting for app to finish loading..."
    while true; do
        if grep -q "Flutter run key commands" "$TEMP_OUTPUT"; then
            echo "App is loaded. Bringing simulator to front..."
            osascript -e 'tell application "Simulator" to activate'
            break
        fi
        
        # Check if flutter process is still running
        if ! kill -0 $FLUTTER_PID 2>/dev/null; then
            echo "Flutter process ended unexpectedly."
            break
        fi
        
        sleep 0.5
    done
    
    # Wait for Flutter process to complete
    wait $FLUTTER_PID
    rm "$TEMP_OUTPUT"
else
    # If not in quiet mode, just run Flutter normally
    flutter run -d "$DEVICE_ID"
fi 