//
//  TimerViewModel.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import Foundation
import Combine

/// Manages timer state and countdown logic, coordinating with RestTimerStateMachine
@MainActor
class TimerViewModel: ObservableObject {
    @Published var state: TimerState = .idle(selectedDuration: nil)

    private var stateMachine: RestTimerStateMachine
    private var countdownTask: Task<Void, Never>?
    private let hapticManager: HapticManagerProtocol

    /// Initialize with optional haptic manager (for testing)
    init(hapticManager: HapticManagerProtocol = HapticManager.shared) {
        self.hapticManager = hapticManager
        self.stateMachine = RestTimerStateMachine()
    }

    /// Computed property to get remaining seconds from state machine
    var remainingSeconds: Int {
        stateMachine.remainingSeconds
    }

    /// Computed property to get selected duration from state machine
    var selectedDuration: TimerDuration? {
        stateMachine.selectedDuration
    }

    /// Select a timer duration and move to ready state
    func selectDuration(_ duration: TimerDuration) {
        stateMachine.selectDuration(duration)
        state = stateMachine.state
    }

    /// Start the countdown from ready state
    func startCountdown() {
        guard stateMachine.startCountdown() else { return }

        // Cancel any existing countdown task
        countdownTask?.cancel()

        // Update published state
        state = stateMachine.state

        // Start async countdown task
        countdownTask = Task { @MainActor [weak self] in
            await self?.runCountdown()
        }
    }

    /// Async countdown loop using Task.sleep
    private func runCountdown() async {
        while case .countingDown = stateMachine.state {
            // Sleep for 1 second
            try? await Task.sleep(for: .seconds(1))

            // Check if task was cancelled
            if Task.isCancelled {
                return
            }

            // Check if we're still in countingDown state (user might have reset)
            guard case .countingDown = stateMachine.state else {
                return
            }

            // Tick the state machine
            let result = stateMachine.tick()

            // Update published state
            state = result.newState

            // Trigger haptics based on tick result
            if result.shouldPlayWarningHaptic {
                hapticManager.playWarningHaptic()
            }
            if result.shouldPlayUrgentHaptic {
                hapticManager.playUrgentHaptic()
            }
            if result.shouldPlayCompletionHaptic {
                hapticManager.playCompletionHaptic()
            }

            // Handle completion
            if result.shouldFinish {
                finishCountdown()
                return
            }
        }
    }

    /// Reset timer back to ready state (called when user taps during countdown)
    func resetToReady() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil

        // Delegate to state machine
        stateMachine.resetToReady()
        state = stateMachine.state
    }

    /// Finish countdown and transition to finished state, then auto-reset to ready
    private func finishCountdown() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil

        // Delegate to state machine
        stateMachine.finish()
        state = stateMachine.state

        // Auto-reset to ready state after a brief moment
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.5))
            guard let self = self else { return }
            self.stateMachine.autoResetToReady()
            self.state = self.stateMachine.state
        }
    }

    /// Cancel timer and return to selection screen
    func cancel() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil

        // Delegate to state machine
        stateMachine.cancel()
        state = stateMachine.state
    }

    deinit {
        countdownTask?.cancel()
    }

    #if DEBUG
    /// Test helper: Manually advance countdown by one second (only available in debug builds for testing)
    func testTick() {
        // Delegate to state machine
        let result = stateMachine.tick()

        // Update published state
        state = result.newState

        // Trigger haptics based on tick result
        if result.shouldPlayWarningHaptic {
            hapticManager.playWarningHaptic()
        }
        if result.shouldPlayUrgentHaptic {
            hapticManager.playUrgentHaptic()
        }
        if result.shouldPlayCompletionHaptic {
            hapticManager.playCompletionHaptic()
        }

        // Handle completion
        if result.shouldFinish {
            finishCountdown()
        }
    }
    #endif
}

