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
#   Default device is iPhone 16 Pro
#
# OPTIONS:
#   -q, --quiet         Run in quiet mode (simulator stays in background until loaded)
#   -d, --debug         Enable debug mode with verbose logging and shader diagnostics
#   -s, --shader-debug  Enable shader diagnostics only (without verbose Flutter logs)
#   -l, --logs          Enable developer logs mode (shows debugPrint/dart:developer logs only)
#   -i, --iphone        Specify iPhone model (15, 16, SE3, 16Pro, 16Max)
#   -l, --list          List available simulator devices
#   -h, --help          Show this help message
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
DEBUG_MODE=false
SHADER_DEBUG_MODE=false
LOGS_MODE=false
SELECTED_DEVICE=""

# Function to get device ID based on model name
get_device_id() {
    local model="$1"
    case "$model" in
        "16Pro")
            echo "55DC84A5-9855-46BA-906A-FC8AA774DB00"  # iPhone 16 Pro
            ;;
        "16Max")
            echo "019DF323-26E7-452B-87E2-D1AF527DB6F5"  # iPhone 16 Pro Max
            ;;
        "16")
            echo "0F0A90ED-27EA-4F1A-8481-D7965E95249D"  # iPhone 16
            ;;
        "16Plus")
            echo "EF6F8C93-CB6F-4785-91CA-9736F4DB0222"  # iPhone 16 Plus
            ;;
        "SE3")
            echo "27680D94-B56E-4319-AD48-EC8DA5D437ED"  # iPhone SE (3rd generation)
            ;;
        *)
            echo ""  # Return empty for unknown devices
            ;;
    esac
}

# Function to get device name based on model code
get_device_name() {
    local model="$1"
    case "$model" in
        "16Pro")
            echo "iPhone 16 Pro"
            ;;
        "16Max")
            echo "iPhone 16 Pro Max"
            ;;
        "16")
            echo "iPhone 16"
            ;;
        "16Plus")
            echo "iPhone 16 Plus"
            ;;
        "SE3")
            echo "iPhone SE (3rd generation)"
            ;;
        *)
            echo "Unknown Device"
            ;;
    esac
}

# Function to list available devices
list_devices() {
    echo "Available iPhone simulators:"
    echo "  16Pro    : iPhone 16 Pro (default)"
    echo "  16Max    : iPhone 16 Pro Max"
    echo "  16       : iPhone 16"
    echo "  16Plus   : iPhone 16 Plus"
    echo "  SE3      : iPhone SE (3rd generation)"
    echo ""
    echo "Usage example: ./run.sh -i 16Max"
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -q|--quiet) QUIET_MODE=true ;;
        -d|--debug) DEBUG_MODE=true ;;
        -s|--shader-debug) SHADER_DEBUG_MODE=true ;;
        -l|--logs) LOGS_MODE=true ;;
        -i|--iphone) 
            SELECTED_DEVICE="$2"
            shift
            ;;
        -l|--list) list_devices ;;
        -h|--help) 
            echo "Usage: ./run.sh [options]"
            echo "Options:"
            echo "  -q, --quiet              Run in quiet mode (simulator stays in background until loaded)"
            echo "  -d, --debug              Enable debug mode with verbose logging and shader diagnostics"
            echo "  -s, --shader-debug       Enable shader diagnostics only (without verbose Flutter logs)"
            echo "  -l, --logs               Enable developer logs mode (shows debugPrint/dart:developer logs)"
            echo "  -i, --iphone <model>     Specify iPhone model (16Pro, 16Max, 16, 16Plus, SE3)"
            echo "  -l, --list               List available simulator devices"
            echo "  -h, --help               Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./run.sh -q                      Run in quiet mode with default device"
            echo "  ./run.sh -i 16Max -q             Run on iPhone 16 Pro Max in quiet mode"
            echo "  ./run.sh -i SE3 -d               Run on iPhone SE 3rd gen with debug logs"
            echo "  ./run.sh -s                      Run with shader debug only (less verbose)"
            echo "  ./run.sh -l                      Run showing developer logs only"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Set device to use (default to iPhone 16 Pro if not specified)
if [[ -z "$SELECTED_DEVICE" ]]; then
    SELECTED_DEVICE="16Pro"  # Default device
fi

# Get device ID and name
DEVICE_ID=$(get_device_id "$SELECTED_DEVICE")
DEVICE_NAME=$(get_device_name "$SELECTED_DEVICE")

# Verify device ID was found
if [[ -z "$DEVICE_ID" ]]; then
    echo "Warning: Unknown device '$SELECTED_DEVICE'. Using default iPhone 16 Pro."
    echo "Run with --list to see available devices."
    SELECTED_DEVICE="16Pro"
    DEVICE_ID=$(get_device_id "$SELECTED_DEVICE")
    DEVICE_NAME=$(get_device_name "$SELECTED_DEVICE")
fi

echo "Using device: $DEVICE_NAME (ID: $DEVICE_ID)"

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

# Build Flutter run command with appropriate options
FLUTTER_CMD="flutter run -d \"$DEVICE_ID\""

# Add debug flags if debug mode is enabled
if [ "$DEBUG_MODE" = true ]; then
    echo "Debug mode enabled: Verbose logging and shader diagnostics activated"
    FLUTTER_CMD="$FLUTTER_CMD --verbose"
    # Set environment variables to show all logs including developer logs
    export FLUTTER_LOG_LEVEL=verbose
    export DART_VM_OPTIONS="-DLOG_LEVEL=ALL"
    # Enable shader debugging
    export ENABLE_SHADER_DEBUG=true
elif [ "$SHADER_DEBUG_MODE" = true ]; then
    echo "Shader debug mode enabled: Only shader diagnostics activated"
    # Only enable shader debugging without verbose Flutter logs
    export ENABLE_SHADER_DEBUG=true
elif [ "$LOGS_MODE" = true ]; then
    echo "Developer logs mode enabled: Showing debug and developer logs only"
    # Set environment variables to show developer logs
    export DART_VM_OPTIONS="-DLOG_LEVEL=ALL"
    # Increase print buffer to ensure logs aren't truncated
    export FLUTTER_CMD="$FLUTTER_CMD --dart-define=flutter.debugprint.maxlen=9999999"
fi

# Run the Flutter app and monitor for app loading completion
echo "Launching Flutter app on $DEVICE_NAME..."
if [ "$QUIET_MODE" = true ]; then
    # Create a temporary file for output
    TEMP_OUTPUT=$(mktemp)
    
    # Run Flutter in background and capture output
    if [ "$DEBUG_MODE" = true ] || [ "$LOGS_MODE" = true ]; then
        # With debug/logs mode, show all output to terminal
        eval "$FLUTTER_CMD" 2>&1 | tee "$TEMP_OUTPUT" &
    else
        eval "$FLUTTER_CMD" 2>&1 | tee "$TEMP_OUTPUT" &
    fi
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
    eval "$FLUTTER_CMD"
fi 