//
//  TimerModels.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

/// Represents the available preset rest timer durations
enum TimerDuration: Int, CaseIterable, Identifiable {
    case thirty = 30
    case sixty = 60
    case ninety = 90
    case oneTwenty = 120
    
    /// Unique identifier for SwiftUI ForEach
    var id: Int { rawValue }
    
    /// Human-readable display text (e.g., "30s", "60s")
    var displayText: String {
        "\(rawValue)s"
    }
}

/// Represents the current state of the timer state machine
enum TimerState {
    /// Initial state or after cancel, optionally preserves last selected duration
    case idle(selectedDuration: TimerDuration?)
    /// Timer duration selected, ready to start countdown
    case ready(selectedDuration: TimerDuration)
    /// Active countdown in progress
    case countingDown(remainingSeconds: Int)
    /// Countdown completed, will auto-transition to ready
    case finished
}

