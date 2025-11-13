# Gym Rest Timer - File Structure

## Proposed Architecture

This document outlines the file structure for the Gym Rest Timer watchOS app, following MVVM architecture and watchOS best practices.

## Directory Structure

```
Gym Rest Timer Watch App/
├── App/
│   └── Gym_Rest_TimerApp.swift          # Main app entry point
│
├── Views/
│   ├── ContentView.swift                 # Main coordinator view (state-based navigation)
│   ├── RestSelectionView.swift           # Screen 1: Preset timer selection (30s, 60s, 90s, 120s)
│   ├── ReadyView.swift                    # Screen 2: Ready screen (shows selected time, tap to start)
│   └── CountdownView.swift                # Screen 3: Active countdown with visual/haptic alerts
│
├── ViewModels/
│   └── TimerViewModel.swift               # Timer state machine and countdown logic
│
├── Models/
│   ├── TimerModels.swift                  # TimerDuration enum, TimerState enum
│   └── RestTimerStateMachine.swift        # Pure state machine logic (no side effects)
│
├── Utilities/
│   ├── HapticManager.swift                # Haptic feedback management
│   └── ColorManager.swift                 # Color state management for visual cues
│
└── Assets.xcassets/                       # App icons and colors
```

## Component Responsibilities

### Views
- **ContentView**: Main coordinator that switches between views based on `TimerViewModel.state`
- **RestSelectionView**: Displays four large buttons for preset durations (30s, 60s, 90s, 120s)
- **ReadyView**: Shows selected duration in large text, ready to start on tap. Includes X button to cancel.
- **CountdownView**: Displays active countdown with color transitions (orange at 10s, red at 5s) and haptic alerts

### ViewModels
- **TimerViewModel**: Coordinates between RestTimerStateMachine, async countdown tasks, and haptic feedback. Publishes state changes for SwiftUI views.

### Models
- **RestTimerStateMachine**: Pure state machine managing timer logic and state transitions without side effects. Returns results indicating required haptic actions.
- **TimerDuration**: Enum representing preset durations (30, 60, 90, 120 seconds)
- **TimerState**: Enum representing current timer state with associated values

### Utilities
- **HapticManager**: Singleton for managing haptic feedback (warning, urgent, completion)
- **ColorManager**: Static methods for determining background colors based on remaining time

## State Flow

1. **idle** → User opens app, sees `RestSelectionView`
2. **ready(duration)** → User selects duration, sees `ReadyView`
3. **countingDown(remaining, total)** → User taps to start, sees `CountdownView`
4. **ready(duration)** → Timer completes, auto-resets to ready state
5. **idle** → User taps X button, returns to selection

## Design Principles

- **MVVM Architecture**: Clear separation between views and business logic
- **State Machine**: Timer state is managed centrally in `TimerViewModel`
- **SwiftUI Best Practices**: Views are lightweight and declarative
- **watchOS HIG Compliance**: Large tap targets (≥44px), appropriate haptics, readable fonts
- **Single Responsibility**: Each file has a clear, focused purpose

## Next Steps

1. Implement precise timer using `WKWorkoutSession` or `Timer` API
2. Add progress ring visualization (optional)
3. Implement flash animation for 10s/5s thresholds
4. Add complication support
5. Add unit tests for `TimerViewModel`
6. Add accessibility support

