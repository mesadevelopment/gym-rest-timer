//
//  RestTimerStateMachine.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import Foundation

/// Result of a tick operation, indicating what side effects should occur
struct TickResult {
    let newState: TimerState
    let shouldPlayWarningHaptic: Bool
    let shouldPlayUrgentHaptic: Bool
    let shouldPlayCompletionHaptic: Bool
    let shouldFinish: Bool
}

/// Pure state machine that manages timer states and transitions
/// This type contains no side effects and can be tested independently
struct RestTimerStateMachine {
    // MARK: - State

    private(set) var state: TimerState
    private var storedDuration: TimerDuration?

    // MARK: - Initialization

    init(initialState: TimerState = .idle(selectedDuration: nil)) {
        self.state = initialState
        self.storedDuration = nil
    }

    // MARK: - Computed Properties

    /// Get remaining seconds from current state
    var remainingSeconds: Int {
        if case .countingDown(let seconds) = state {
            return seconds
        }
        return 0
    }

    /// Get selected duration from current state
    var selectedDuration: TimerDuration? {
        switch state {
        case .idle(let duration):
            return duration
        case .ready(let duration):
            return duration
        case .countingDown, .finished:
            return storedDuration
        }
    }

    // MARK: - State Transitions

    /// Select a timer duration and transition to ready state
    mutating func selectDuration(_ duration: TimerDuration) {
        state = .ready(selectedDuration: duration)
        storedDuration = duration
    }

    /// Start countdown from ready state
    /// Returns true if transition was successful, false if not in ready state
    @discardableResult
    mutating func startCountdown() -> Bool {
        guard case .ready(let duration) = state else {
            return false
        }

        storedDuration = duration
        state = .countingDown(remainingSeconds: duration.rawValue)
        return true
    }

    /// Tick the countdown by one second
    /// Returns a TickResult indicating what happened and what side effects should occur
    mutating func tick() -> TickResult {
        guard case .countingDown(let currentSeconds) = state else {
            // Not in countdown state, return no-op result
            return TickResult(
                newState: state,
                shouldPlayWarningHaptic: false,
                shouldPlayUrgentHaptic: false,
                shouldPlayCompletionHaptic: false,
                shouldFinish: false
            )
        }

        let newSeconds = currentSeconds - 1

        // Determine which haptics should fire based on threshold crossings
        let shouldPlayWarning = newSeconds == 10
        let shouldPlayUrgent = newSeconds == 5
        let shouldPlayCompletion = newSeconds == 0
        let shouldFinish = newSeconds == 0

        // Update state
        if newSeconds > 0 {
            state = .countingDown(remainingSeconds: newSeconds)
        }
        // Note: If newSeconds == 0, we don't update state here
        // The caller should call finish() to transition to finished state

        return TickResult(
            newState: state,
            shouldPlayWarningHaptic: shouldPlayWarning,
            shouldPlayUrgentHaptic: shouldPlayUrgent,
            shouldPlayCompletionHaptic: shouldPlayCompletion,
            shouldFinish: shouldFinish
        )
    }

    /// Reset back to ready state (preserving selected duration)
    mutating func resetToReady() {
        guard let duration = storedDuration else {
            state = .idle(selectedDuration: nil)
            return
        }

        state = .ready(selectedDuration: duration)
    }

    /// Cancel timer and return to idle state (preserving last selected duration)
    mutating func cancel() {
        let lastDuration = storedDuration
        state = .idle(selectedDuration: lastDuration)
    }

    /// Transition to finished state
    mutating func finish() {
        state = .finished
    }

    /// Auto-reset from finished back to ready state
    mutating func autoResetToReady() {
        guard let duration = storedDuration else {
            state = .idle(selectedDuration: nil)
            return
        }

        state = .ready(selectedDuration: duration)
    }
}

// MARK: - Equatable Conformance

extension RestTimerStateMachine: Equatable {
    static func == (lhs: RestTimerStateMachine, rhs: RestTimerStateMachine) -> Bool {
        lhs.state == rhs.state && lhs.storedDuration == rhs.storedDuration
    }
}

// MARK: - TimerState Equatable

extension TimerState: Equatable {
    static func == (lhs: TimerState, rhs: TimerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle(let lDuration), .idle(let rDuration)):
            return lDuration == rDuration
        case (.ready(let lDuration), .ready(let rDuration)):
            return lDuration == rDuration
        case (.countingDown(let lSeconds), .countingDown(let rSeconds)):
            return lSeconds == rSeconds
        case (.finished, .finished):
            return true
        default:
            return false
        }
    }
}
