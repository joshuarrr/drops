#!/bin/bash

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

# Make sure simulator is open
echo "Starting iOS Simulator..."
open -a Simulator

# Wait for simulator to boot (max 30 seconds)
COUNTER=0
MAX_TRIES=30
while ! is_simulator_booted && [ $COUNTER -lt $MAX_TRIES ]; do
  echo "Waiting for simulator to boot ($COUNTER/$MAX_TRIES)..."
  sleep 1
  COUNTER=$((COUNTER + 1))
done

if ! is_simulator_booted; then
  echo "Error: Simulator did not boot in time."
  exit 1
fi

# Get ID of booted simulator
DEVICE_ID=$(get_booted_simulator_id)

if [ -z "$DEVICE_ID" ]; then
  echo "Error: Could not determine simulator device ID."
  exit 1
fi

echo "Simulator booted with ID: $DEVICE_ID"

# Run Flutter app on the booted simulator
echo "Launching Flutter app on simulator..."
flutter run -d "$DEVICE_ID" 