# Rest Timer State Machine

## Overview

The `RestTimerStateMachine` is a pure, side-effect-free state machine that manages the countdown timer logic for the Gym Rest Timer app. It handles state transitions, tick logic, and determines when haptic feedback should be triggered.

## Design Principles

- **Pure Logic**: No side effects - all operations return results that inform callers about required actions
- **Testable**: Can be tested independently without mocking frameworks or MainActor isolation
- **Predictable**: Same inputs always produce same outputs
- **Isolated**: Timer logic separated from UI, async tasks, and haptic playback

## States

### 1. `idle(selectedDuration: TimerDuration?)`
**Description**: Initial state when no timer is active. User can select a duration from preset options.

**Properties**:
- `selectedDuration`: Optional - preserves the last selected duration (if any)
- `remainingSeconds`: 0

**Valid Transitions From**:
- Initial state
- From `countingDown` via `cancel()`
- From `ready` via `cancel()`

**Valid Transitions To**:
- `ready` via `selectDuration()`

---

### 2. `ready(selectedDuration: TimerDuration)`
**Description**: Timer is configured and ready to start. Displays the selected duration and waits for user to tap to begin.

**Properties**:
- `selectedDuration`: The chosen duration (30s, 60s, 90s, or 120s)
- `remainingSeconds`: 0 (not yet counting)

**Valid Transitions From**:
- From `idle` via `selectDuration()`
- From `countingDown` via `resetToReady()`
- From `finished` via `autoResetToReady()`

**Valid Transitions To**:
- `countingDown` via `startCountdown()`
- `idle` via `cancel()`

---

### 3. `countingDown(remainingSeconds: Int)`
**Description**: Active countdown in progress. Decrements every second until reaching zero.

**Properties**:
- `remainingSeconds`: Current countdown value (1 to 120 seconds)
- `selectedDuration`: Preserved from ready state (stored internally)

**Valid Transitions From**:
- From `ready` via `startCountdown()`

**Valid Transitions To**:
- `countingDown` (self-transition) via `tick()` - decrements remaining seconds
- `ready` via `resetToReady()` - user taps during countdown
- `finished` via `finish()` - countdown reaches 0
- `idle` via `cancel()` - user presses X button

**Haptic Triggers**:
- **10 seconds**: Warning haptic (first alert)
- **5 seconds**: Urgent haptic (second alert)
- **0 seconds**: Completion haptic (timer finished)

---

### 4. `finished`
**Description**: Countdown completed. Brief transitional state before auto-resetting to ready.

**Properties**:
- `remainingSeconds`: 0
- `selectedDuration`: Preserved for auto-reset

**Valid Transitions From**:
- From `countingDown` via `finish()`

**Valid Transitions To**:
- `ready` via `autoResetToReady()` - typically after 0.5 seconds
- `idle` via `cancel()` - if duration lost

**Duration**: Typically lasts 0.5 seconds before auto-reset

---

## Events & Transitions

### User-Initiated Events

| Event | From State(s) | To State | Description |
|-------|---------------|----------|-------------|
| `selectDuration(_:)` | `idle` | `ready` | User selects a timer duration (30/60/90/120s) |
| `startCountdown()` | `ready` | `countingDown` | User taps to start the countdown |
| `resetToReady()` | `countingDown` | `ready` | User taps screen during countdown to restart |
| `cancel()` | `ready`, `countingDown`, `finished` | `idle` | User presses X button to return to selection |

### System-Initiated Events

| Event | From State(s) | To State | Description |
|-------|---------------|----------|-------------|
| `tick()` | `countingDown` | `countingDown` or triggers `finish()` | Decrements counter every second |
| `finish()` | `countingDown` | `finished` | Countdown reaches 0 |
| `autoResetToReady()` | `finished` | `ready` | Auto-transition after 0.5s to allow another countdown |

### Failed Transitions

| Event | Current State | Result | Reason |
|-------|---------------|--------|--------|
| `startCountdown()` | `idle`, `countingDown`, `finished` | No change (returns `false`) | Can only start from `ready` |
| `tick()` | `idle`, `ready`, `finished` | No-op result | Tick only works in `countingDown` |

---

## Tick Logic & Side Effects

The `tick()` method is the core of the countdown mechanism. It returns a `TickResult` struct that indicates:

```swift
struct TickResult {
    let newState: TimerState
    let shouldPlayWarningHaptic: Bool    // true at 10s
    let shouldPlayUrgentHaptic: Bool     // true at 5s
    let shouldPlayCompletionHaptic: Bool // true at 0s
    let shouldFinish: Bool                // true at 0s
}
```

### Tick Behavior by Remaining Seconds

| Remaining Seconds | Action | Warning Haptic | Urgent Haptic | Completion Haptic | Should Finish |
|-------------------|--------|----------------|---------------|-------------------|---------------|
| 120 → 11 | Decrement | ❌ | ❌ | ❌ | ❌ |
| 11 → 10 | Decrement | ✅ | ❌ | ❌ | ❌ |
| 10 → 6 | Decrement | ❌ | ❌ | ❌ | ❌ |
| 6 → 5 | Decrement | ❌ | ✅ | ❌ | ❌ |
| 5 → 1 | Decrement | ❌ | ❌ | ❌ | ❌ |
| 1 → 0 | Finish | ❌ | ❌ | ✅ | ✅ |

**Note**: Haptics fire based on the **new value after decrement**, not before.

---

## State Transition Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────────┐  selectDuration()   ┌──────────────┐        │
│  │              │─────────────────────▶│              │        │
│  │     idle     │                      │    ready     │        │
│  │              │◀─────────────────────│              │        │
│  └──────────────┘       cancel()       └──────────────┘        │
│         ▲                                      │                │
│         │                                      │ startCountdown()│
│         │                                      ▼                │
│         │                              ┌──────────────┐        │
│         │                              │              │        │
│         │                              │ countingDown │◀───┐   │
│         │                              │              │    │   │
│         │                              └──────────────┘    │   │
│         │                                 │     │          │   │
│         │ cancel()                        │     │ tick()   │   │
│         └─────────────────────────────────┘     └──────────┘   │
│                                           │                    │
│                                           │ finish()           │
│                                           ▼                    │
│                                   ┌──────────────┐            │
│                                   │              │            │
│                                   │   finished   │            │
│                                   │              │            │
│                                   └──────────────┘            │
│                                           │                    │
│                                           │ autoResetToReady() │
│                                           │                    │
│                                           └────────────────────┘
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Legend:
  ─▶ State transition
  ◀─ Bidirectional transition possible
  ◀┐ Self-loop (tick in countingDown)
```

---

## State Rules & Invariants

### Duration Preservation

1. **Selection**: When `selectDuration()` is called, the duration is stored and never lost until a new duration is selected
2. **Countdown**: During countdown, the original duration is preserved in `storedDuration`
3. **Reset**: `resetToReady()` preserves the last duration
4. **Cancel**: `cancel()` preserves the last duration in `idle(selectedDuration:)`
5. **Finish**: `finished` state preserves duration for auto-reset

### State Isolation

- State machine **does not** play haptics - it returns flags indicating when they should fire
- State machine **does not** handle async timing - caller manages `Task.sleep()` between ticks
- State machine **does not** auto-transition - caller must call `finish()` and `autoResetToReady()` at appropriate times

### Tick Constraints

- `tick()` only mutates state when in `countingDown`
- `tick()` from non-countdown states returns a no-op `TickResult` with current state unchanged
- Ticking from 1 → 0 does **not** automatically transition to `finished` - caller must invoke `finish()`

---

## Usage Examples

### Example 1: Complete 30-Second Countdown

```swift
var stateMachine = RestTimerStateMachine()

// 1. Select duration
stateMachine.selectDuration(.thirty)
// State: ready(selectedDuration: .thirty)

// 2. Start countdown
stateMachine.startCountdown()
// State: countingDown(remainingSeconds: 30)

// 3. Tick 30 times (simulated)
for i in 0..<30 {
    let result = stateMachine.tick()

    // At second 20 (30 → 10):
    if result.shouldPlayWarningHaptic {
        // Play warning haptic
    }

    // At second 25 (30 → 5):
    if result.shouldPlayUrgentHaptic {
        // Play urgent haptic
    }

    // At second 30 (1 → 0):
    if result.shouldFinish {
        // Play completion haptic
        stateMachine.finish()
        // State: finished

        // After 0.5s delay:
        stateMachine.autoResetToReady()
        // State: ready(selectedDuration: .thirty)
    }
}
```

### Example 2: User Resets During Countdown

```swift
var stateMachine = RestTimerStateMachine()

stateMachine.selectDuration(.sixty)
stateMachine.startCountdown()
// State: countingDown(remainingSeconds: 60)

// User lets 20 seconds elapse
for _ in 0..<20 {
    _ = stateMachine.tick()
}
// State: countingDown(remainingSeconds: 40)

// User taps screen to restart
stateMachine.resetToReady()
// State: ready(selectedDuration: .sixty)
// Duration preserved, ready to start again
```

### Example 3: User Cancels During Countdown

```swift
var stateMachine = RestTimerStateMachine()

stateMachine.selectDuration(.ninety)
stateMachine.startCountdown()
// State: countingDown(remainingSeconds: 90)

// User presses X button
stateMachine.cancel()
// State: idle(selectedDuration: .ninety)
// Returns to selection screen with last duration preserved
```

### Example 4: Failed Start Attempt

```swift
var stateMachine = RestTimerStateMachine()

// Attempt to start without selecting duration
let success = stateMachine.startCountdown()
// success == false
// State: idle(selectedDuration: nil) - unchanged
```

---

## Integration with TimerViewModel

The `TimerViewModel` uses `RestTimerStateMachine` as follows:

1. **Initialization**: Creates a `RestTimerStateMachine` instance
2. **State Publishing**: Syncs `@Published var state` with `stateMachine.state` after each transition
3. **Async Coordination**: Manages `Task` lifecycle for countdown loop
4. **Haptic Playback**: Interprets `TickResult` flags and calls `HapticManager` accordingly
5. **Timing**: Handles `Task.sleep(for: .seconds(1))` between ticks
6. **Auto-Reset**: Manages 0.5s delay before calling `autoResetToReady()`

### Separation of Concerns

| Concern | RestTimerStateMachine | TimerViewModel |
|---------|----------------------|----------------|
| State transitions | ✅ Pure logic | ❌ Delegates to state machine |
| Countdown math | ✅ Tick logic | ❌ Delegates to state machine |
| Haptic determination | ✅ Returns flags | ❌ Interprets flags |
| Haptic playback | ❌ No side effects | ✅ Calls HapticManager |
| Async timing | ❌ No async code | ✅ Manages Task.sleep |
| Task cancellation | ❌ No Task management | ✅ Cancels countdown tasks |
| SwiftUI publishing | ❌ Not @Observable | ✅ @Published state |

---

## Testing Strategy

### State Machine Tests (Pure Logic)

Test `RestTimerStateMachine` directly without mocks:

- ✅ All state transitions
- ✅ Tick logic and decrements
- ✅ Haptic flag triggers at 10s, 5s, 0s
- ✅ Duration preservation across transitions
- ✅ Edge cases (tick from non-countdown state, start without selection)
- ✅ Full countdown sequences

**Benefits**: Fast, deterministic, no MainActor required

### ViewModel Tests (Integration)

Test `TimerViewModel` with mock haptics:

- ✅ State synchronization with published property
- ✅ Haptic playback based on tick results
- ✅ Async countdown with `testTick()` helper
- ✅ Task cancellation on reset/cancel
- ✅ Auto-reset timing (0.5s delay)

**Benefits**: Verifies coordination between state machine and side effects

---

## Future Extensions

The state machine architecture makes these features easier to add:

### Pause/Resume
```swift
enum TimerState {
    // ...
    case paused(remainingSeconds: Int)
}

mutating func pause() { /* ... */ }
mutating func resume() { /* ... */ }
```

### Custom Durations
```swift
mutating func selectCustomDuration(seconds: Int) {
    // Validate and set custom duration
}
```

### Loop Mode
```swift
var loopCount: Int
var currentLoop: Int

mutating func enableLoop(count: Int) { /* ... */ }
```

---

## References

- **Implementation**: `Gym Rest Timer Watch App/Models/RestTimerStateMachine.swift`
- **ViewModel Integration**: `Gym Rest Timer Watch App/ViewModels/TimerViewModel.swift`
- **State Machine Tests**: `Gym Rest Timer Watch AppTests/RestTimerStateMachineTests.swift`
- **ViewModel Tests**: `Gym Rest Timer Watch AppTests/TimerViewModelTests.swift`
- **State Models**: `Gym Rest Timer Watch App/Models/TimerModels.swift`
