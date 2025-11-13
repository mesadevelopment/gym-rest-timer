# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Gym Rest Timer** is a watchOS-only Apple Watch app built with SwiftUI. It provides fast, one-tap rest timers for strength training workouts with preset durations (30, 60, 90, 120 seconds), visual cues (color transitions), and haptic alerts.

## Build & Test Commands

### Building
```bash
# Open the Xcode project
open "Gym Rest Timer/Gym Rest Timer.xcodeproj"
```

Note: This project requires Xcode (not just Command Line Tools) to build and run watchOS apps.

### Testing
- Run tests through Xcode: Product → Test (⌘U)
- Tests are located in `Gym Rest Timer Watch AppTests/`
- Main test file: `TimerViewModelTests.swift` (comprehensive unit tests for timer state machine)

## Architecture

### MVVM Pattern with State Machine
The app follows MVVM architecture with a centralized state machine pattern:

- **State Machine**: `TimerViewModel` manages all timer states: `idle`, `ready`, `countingDown`, `finished`
- **Views**: Lightweight SwiftUI views that react to state changes
- **Navigation**: State-based navigation in `ContentView` switches between views based on `TimerViewModel.state`

### Key State Flow
1. `idle` → User selects duration → `RestSelectionView`
2. `ready(duration)` → User taps to start → `ReadyView`
3. `countingDown(remaining)` → Active countdown → `CountdownView`
4. `finished` → Auto-resets to `ready` after 0.5 seconds
5. Tap "X" button during countdown → Returns to `idle`
6. Tap screen during countdown → Returns to `ready`

### File Structure
```
Gym Rest Timer Watch App/
├── Gym_Rest_TimerApp.swift          # Main app entry point
├── ContentView.swift                 # State-based navigation coordinator
├── Views/
│   ├── RestSelectionView.swift      # Preset timer selection (30/60/90/120s)
│   ├── ReadyView.swift               # Ready screen (tap to start)
│   └── CountdownView.swift           # Active countdown with alerts
├── ViewModels/
│   └── TimerViewModel.swift          # Timer state machine & logic
├── Models/
│   └── TimerModels.swift             # TimerDuration & TimerState enums
└── Utilities/
    ├── HapticManager.swift           # Haptic feedback (protocol-based for testing)
    └── ColorManager.swift            # Color transitions (orange @10s, red @5s)
```

## Critical Implementation Rules

### Timer Implementation
- **Use modern Swift concurrency**: Countdown uses `Task` with `Task.sleep(for: .seconds(1))` for precise ticking
- **Never use `Timer.scheduledTimer`** for countdown logic (only for UI flash animations)
- **MainActor isolation**: All timer logic runs on `@MainActor` for thread safety
- **Clean cancellation**: Timer tasks cancel properly when user resets or exits

### Haptic Feedback
- Haptics trigger at: 10 seconds (warning), 5 seconds (urgent), 0 seconds (completion)
- `HapticManager` uses protocol `HapticManagerProtocol` for testability
- Uses WatchKit haptic types: `.notification`, `.retry`, `.success`

### Visual Alerts
- Background colors via `ColorManager.backgroundColor(for:)`
  - Normal: `.black`
  - ≤10 seconds: `.orange`
  - ≤5 seconds: `.red`
- Flash animation starts at 10s threshold, continues to 0
- Flash rate: 2x per second (0.5s interval)

### Testing
- `TimerViewModel` includes `testTick()` method (debug-only) for controlled testing
- `MockHapticManager` for unit tests (no actual haptic playback)
- Tests verify: state transitions, haptic timing, countdown accuracy, cancellation behavior

## Design Principles

- **Minimal friction**: Large tap targets (≥44px), simple flows, no nested navigation
- **watchOS HIG compliance**: SF Rounded typography, appropriate haptics, readable fonts
- **Single responsibility**: Each file has focused purpose
- **Protocol-oriented**: Managers use protocols for testability (e.g., `HapticManagerProtocol`)

## Documentation References

The `docs/` directory contains:
- `prd-gym-rest-timer.md` - Product requirements & feature specs
- `design-specs-gym-rest-timer.md` - Design specifications
- `ai-rules.md` - Development guidelines (timer implementation, architecture rules)

FILE_STRUCTURE.md provides detailed component responsibilities and state flow diagram.

## Future Roadmap

### Version 1.1 (Planned)
- Custom durations
- Pause/resume functionality
- Loop mode

### Version 1.2 (Planned)
- iPhone companion app
- Session countdown with workout/rest cycles
- Heart rate tracking during workout/rest

### Version 2.0 (Planned)
- Online portal for session tracking
