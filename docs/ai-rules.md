# AI Rules – Gym Rest Timer (watchOS-only SwiftUI App)

## Summary of App
Gym Rest Timer is a watchOS-only Apple Watch app built with SwiftUI.  
It provides a fast, tap-driven rest timer for workouts.  
User selects a rest duration (30s, 60s, 90s, 120s), then taps to start countdown.  
At 10 seconds remaining, background flashes orange + haptic.  
At 5 seconds remaining, background flashes red + stronger haptic.  
Tapping during countdown cancels and returns to ready screen.

## Platform
- watchOS-only (no iOS companion app).
- Watch App + Watch Extension structure.
- SwiftUI for all UI components.
- MVVM-style with a clean state machine for timer logic.

## Timer Implementation Rules
- Avoid using `Timer.scheduledTimer` for countdown logic.
- Implement countdown using modern Swift concurrency:
  - A `Task` with `Task.sleep(for: .seconds(1))` for precise ticking.
  - Update state on the MainActor after each tick.
- Keep all timer logic centralized inside the ViewModel/StateMachine.
- Ensure the timer cancels cleanly if the user taps during countdown.
- Do not use WKWorkoutSession unless we later expand the app into a full workout tracker.

## Required Flow
1. Rest Selection Screen  
2. Ready Screen (show selected time + tap to start)  
3. Countdown Screen (with 10s/5s flashes + haptics)  
4. Auto-reset to Ready Screen when finished  
5. Tap during countdown resets to Ready Screen  

## Use Documentation
- Follow `docs/prd-gym-rest-timer.md` for functional requirements.
- Follow `docs/design-specs-gym-rest-timer.md` for design rules.
- Maintain consistency with watchOS HIG and SF Rounded typography.

## Architectural Rules
- Use a single timer state machine (`idle`, `ready`, `countingDown`, `finished`).
- Keep logic in a ViewModel or StateMachine file, not inside views.
- Views should stay lightweight and declarative.
- Add unit tests later (XCTest).

## Special Notes for AI
- When asked to modify the project, update all relevant files consistently.
- Preserve architecture unless explicitly asked to refactor.
- When generating code, keep comments explaining major decisions.
