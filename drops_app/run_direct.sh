#!/bin/bash

# Configure the device you want to use
DEVICE_NAME="iPhone SE (3rd generation)"
DEVICE_ID="27680D94-B56E-4319-AD48-EC8DA5D437ED"

# Completely kill any running simulator processes
echo "Shutting down all simulator processes..."
xcrun simctl shutdown all 2>/dev/null
killall Simulator CoreSimulatorBridge SimulatorTrampoline 2>/dev/null || true
sleep 3

# First, start the Simulator app without specifying a device
echo "Starting Simulator app..."
open -a Simulator
sleep 5

# Now ensure the specific device is booted and visible
echo "Activating specific device: $DEVICE_NAME"
osascript -e 'tell application "Simulator" to activate'
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
sleep 2

# Force the simulator to show the device by setting it as current
echo "Setting device as current..."
xcrun simctl shutdown all 2>/dev/null
xcrun simctl boot "$DEVICE_ID"
open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID"
sleep 3

# Make absolutely sure the simulator window is in front
osascript -e 'tell application "Simulator" to activate'
sleep 2

# Check if the simulator booted successfully
if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
  echo "Error: Failed to boot the simulator. Trying one more approach..."
  
  # Kill simulator completely and try once more
  killall Simulator 2>/dev/null || true
  sleep 3
  open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID"
  sleep 5
  xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
  
  # Check one last time
  if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
    echo "Error: Could not get the simulator running properly."
    exit 1
  fi
fi

echo "Simulator is now booted. Checking if UI is visible..."
osascript -e 'tell application "Simulator" to activate'
echo "If you don't see the simulator window, try manually opening:"
echo "open -a Simulator --args -CurrentDeviceUDID $DEVICE_ID"

echo "Waiting 5 seconds before launching the app..."
sleep 5

# Run the Flutter app
echo "Launching Flutter app on $DEVICE_NAME..."
flutter run -d "$DEVICE_ID" 