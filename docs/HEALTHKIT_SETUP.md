# HealthKit Setup for Timer Continuity

## Overview

Gym Rest Timer uses HealthKit's `HKWorkoutSession` to keep the app active during countdown, ensuring the timer continues running even when the watch screen turns off or becomes inactive.

## Why HealthKit?

On watchOS, apps are suspended when the screen turns off to conserve battery. To keep a timer running continuously, we use `HKWorkoutSession` which:
- Prevents app suspension during countdown
- Keeps the timer running accurately
- Ensures haptic alerts work even when screen is off
- Follows Apple's recommended approach for timer apps

## Setup Required

### 1. Enable HealthKit Capability in Xcode

1. Open the project in Xcode
2. Select the **Gym Rest Timer Watch App** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **HealthKit** capability
6. Ensure **Workout Processing** is enabled

### 2. Info.plist Keys (Already Added)

The following keys have been added to the project:
- `NSHealthShareUsageDescription`: Explains why we need HealthKit read access
- `NSHealthUpdateUsageDescription`: Explains why we need HealthKit write access

### 3. First Launch Behavior

On first launch when starting a timer:
- The app will request HealthKit authorization
- User will see a permission prompt
- Once authorized, the workout session starts automatically
- Timer will continue running even when screen is off

## Implementation Details

- **Activity Type**: `.other` - We don't track actual workout data
- **Location Type**: `.indoor` - Appropriate for gym use
- **Minimal Permissions**: Only requests workout write permission
- **No Data Tracking**: We don't save any workout data to HealthKit

## Fallback Behavior

If HealthKit is unavailable or authorization is denied:
- Timer will still function normally
- May pause when screen turns off (watchOS limitation)
- Haptics will work when screen is active

## Testing

1. Start a timer countdown
2. Wait for HealthKit authorization prompt (first time only)
3. Authorize HealthKit access
4. Put watch down or let screen turn off
5. Verify timer continues running
6. Verify haptics fire at 10s and 5s even when screen is off

## Privacy

- We request minimal HealthKit permissions
- We don't read or write any health data
- We only use the workout session to keep the app active
- No personal health information is accessed or stored

