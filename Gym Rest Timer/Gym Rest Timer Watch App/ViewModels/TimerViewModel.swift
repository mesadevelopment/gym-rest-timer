//
//  TimerViewModel.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import Combine
import WatchKit
import HealthKit

/// Manages timer state and countdown logic, coordinating with RestTimerStateMachine
@MainActor
class TimerViewModel: ObservableObject, HKWorkoutSessionDelegate {
    /// Published state that drives the UI
    @Published var state: TimerState = .idle(selectedDuration: nil)

    /// Pure state machine that manages timer logic without side effects
    private var stateMachine: RestTimerStateMachine
    /// Async task that runs the countdown loop
    private var countdownTask: Task<Void, Never>?
    /// Haptic feedback manager (injectable for testing)
    private let hapticManager: HapticManagerProtocol
    /// Workout session to keep app active during countdown (prevents suspension when screen is off)
    private var workoutSession: HKWorkoutSession?
    private var workoutConfiguration: HKWorkoutConfiguration?
    /// HealthKit store for workout session management
    private let healthStore = HKHealthStore()

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

        // Start workout session to keep app active during countdown
        // This prevents the app from being suspended when the screen turns off
        startWorkoutSession()

        // Start async countdown task with high priority to prevent suspension
        // This ensures the timer continues even when the watch screen is off
        countdownTask = Task(priority: .userInitiated) { @MainActor [weak self] in
            await self?.runCountdown()
        }
    }

    /// Async countdown loop using Task.sleep
    /// This continues running even when the watch screen is off, ensuring haptics work as designed
    private func runCountdown() async {
        while case .countingDown = stateMachine.state {
            // Sleep for 1 second using continuous clock for better accuracy
            // This ensures the timer continues even when the app is backgrounded
            try? await ContinuousClock().sleep(for: .seconds(1))

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

            // Update published state (this will update UI when screen is active)
            state = result.newState

            // Trigger haptics based on tick result
            // Haptics work even when the screen is off, alerting the user
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

        // Stop workout session
        stopWorkoutSession()

        // Delegate to state machine
        stateMachine.resetToReady()
        state = stateMachine.state
    }

    /// Finish countdown and transition to finished state, then auto-reset to ready
    private func finishCountdown() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil

        // Stop workout session
        stopWorkoutSession()

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

        // Stop workout session
        stopWorkoutSession()

        // Delegate to state machine
        stateMachine.cancel()
        state = stateMachine.state
    }

    // MARK: - Workout Session Management
    
    /// Start a workout session to keep the app active during countdown
    /// This prevents the app from being suspended when the screen turns off
    private func startWorkoutSession() {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            // If HealthKit is not available, continue without workout session
            // The timer will still work, but may pause when screen is off
            return
        }

        // Stop any existing session
        stopWorkoutSession()

        // Request HealthKit authorization (required for workout sessions)
        // We request minimal permissions - just workout data write
        let workoutType = HKObjectType.workoutType()
        healthStore.requestAuthorization(toShare: [workoutType], read: []) { [weak self] success, error in
            guard let self = self, success else {
                // If authorization fails, continue without workout session
                // Timer will still work but may pause when screen is off
                if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
                return
            }

            Task { @MainActor in
                // Create a minimal workout configuration
                // We use "Other" activity type to avoid tracking actual workout data
                let configuration = HKWorkoutConfiguration()
                configuration.activityType = .other
                configuration.locationType = .indoor

                // Create and start the workout session
                do {
                    let session = try HKWorkoutSession(healthStore: self.healthStore, configuration: configuration)
                    session.delegate = self
                    self.workoutSession = session
                    self.workoutConfiguration = configuration
                    
                    // Start the session to keep app active
                    self.healthStore.start(session)
                } catch {
                    // If session creation fails, continue without it
                    // Timer will still work but may pause when screen is off
                    print("Failed to start workout session: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Stop the workout session
    private func stopWorkoutSession() {
        guard let session = workoutSession else { return }
        
        // End the session
        healthStore.end(session)
        workoutSession = nil
        workoutConfiguration = nil
    }
    
    // MARK: - HKWorkoutSessionDelegate
    
    /// Called when workout session state changes
    /// Note: This may be called on a background thread
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle workout session state changes if needed
        // For our use case, we just need the session to keep the app active
        // No UI updates needed, so we can handle this on any thread
    }
    
    /// Called when workout session fails
    /// Note: This may be called on a background thread
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // If workout session fails, continue without it
        // Timer will still work but may pause when screen is off
        print("Workout session failed: \(error.localizedDescription)")
        
        // Dispatch to main actor to stop the session safely
        Task { @MainActor [weak self] in
            self?.stopWorkoutSession()
        }
    }

    deinit {
        countdownTask?.cancel()
        stopWorkoutSession()
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

