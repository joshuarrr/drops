#!/bin/bash

# First, shutdown all simulators to ensure a clean state
echo "Shutting down any running simulators..."
xcrun simctl shutdown all 2>/dev/null

# Wait a moment for shutdown to complete
sleep 3

# Function to check if simulator is booted
is_simulator_booted() {
  xcrun simctl list devices | grep -q "Booted"
  return $?
}

# Function to get the ID of the first booted simulator
get_booted_simulator_id() {
  DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -n 1 | sed -E 's/.*\(([A-Z0-9-]+)\).*/\1/')
  echo $DEVICE_ID
}

# Check for running simulator application first
if ! pgrep -q Simulator; then
  echo "Starting iOS Simulator application..."
  open -a Simulator
  # Give some time for the app to launch before checking device status
  sleep 5
else
  echo "Simulator application is already running"
fi

# Wait for simulator to boot (max 90 seconds)
COUNTER=0
MAX_TRIES=90
while ! is_simulator_booted && [ $COUNTER -lt $MAX_TRIES ]; do
  echo "Waiting for simulator to boot ($COUNTER/$MAX_TRIES)..."
  sleep 1
  COUNTER=$((COUNTER + 1))
  
  # Every 15 seconds, try to refresh the simulator state
  if [ $((COUNTER % 15)) -eq 0 ]; then
    echo "Attempting to refresh simulator state..."
    killall -HUP Simulator 2>/dev/null || true
    sleep 2
  fi
done

if ! is_simulator_booted; then
  echo "Error: Simulator did not boot in time."
  echo "Try manually opening the Simulator app first, then run this script again."
  exit 1
fi

# Get ID of booted simulator
DEVICE_ID=$(get_booted_simulator_id)

if [ -z "$DEVICE_ID" ]; then
  echo "Error: Could not determine simulator device ID."
  exit 1
fi

echo "Simulator booted with ID: $DEVICE_ID"

# Wait for the simulator to fully initialize
echo "Waiting 10 seconds for simulator to stabilize..."
sleep 10

# Run Flutter app on the booted simulator
echo "Launching Flutter app on simulator..."
flutter run -d "$DEVICE_ID" 