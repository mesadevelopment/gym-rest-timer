//
//  TimerViewModel.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import Foundation
import Combine
import WatchKit

/// Manages timer state and countdown logic
@MainActor
class TimerViewModel: ObservableObject {
    @Published var state: TimerState = .idle(selectedDuration: nil)
    
    private var countdownTask: Task<Void, Never>?
    private let hapticManager: HapticManagerProtocol
    
    /// Initialize with optional haptic manager (for testing)
    init(hapticManager: HapticManagerProtocol = HapticManager.shared) {
        self.hapticManager = hapticManager
    }
    
    /// Computed property to get remaining seconds from state
    var remainingSeconds: Int {
        if case .countingDown(let seconds) = state {
            return seconds
        }
        return 0
    }
    
    /// Computed property to get selected duration from state
    var selectedDuration: TimerDuration? {
        switch state {
        case .idle(let duration):
            return duration
        case .ready(let duration):
            return duration
        case .countingDown:
            // During countdown, we need to track the original duration
            // This is handled by storing it when transitioning to countingDown
            return storedDuration
        case .finished:
            return storedDuration
        }
    }
    
    /// Store the original duration when starting countdown
    private var storedDuration: TimerDuration?
    
    /// Select a timer duration and move to ready state
    func selectDuration(_ duration: TimerDuration) {
        state = .ready(selectedDuration: duration)
        storedDuration = duration
    }
    
    /// Start the countdown from ready state
    func startCountdown() {
        guard case .ready(let duration) = state else { return }
        
        // Cancel any existing countdown task
        countdownTask?.cancel()
        
        storedDuration = duration
        state = .countingDown(remainingSeconds: duration.rawValue)
        
        // Start async countdown task
        countdownTask = Task { @MainActor [weak self] in
            await self?.runCountdown()
        }
    }
    
    /// Async countdown loop using Task.sleep
    private func runCountdown() async {
        var currentSeconds: Int
        
        // Get initial seconds from state
        guard case .countingDown(let seconds) = state else { return }
        currentSeconds = seconds
        
        // Countdown loop
        while currentSeconds > 0 {
            // Sleep for 1 second
            try? await Task.sleep(for: .seconds(1))
            
            // Check if task was cancelled
            if Task.isCancelled {
                return
            }
            
            // Check if we're still in countingDown state (user might have reset)
            guard case .countingDown = state else {
                return
            }
            
            // Decrement seconds
            currentSeconds -= 1
            
            // Trigger haptics at thresholds (flash animation is handled by the view)
            if currentSeconds == 10 {
                hapticManager.playWarningHaptic()
            } else if currentSeconds == 5 {
                hapticManager.playUrgentHaptic()
            } else if currentSeconds == 0 {
                hapticManager.playCompletionHaptic()
                finishCountdown()
                return
            }
            
            // Update state
            state = .countingDown(remainingSeconds: currentSeconds)
        }
    }
    
    /// Reset timer back to ready state (called when user taps during countdown)
    func resetToReady() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil
        
        guard let duration = storedDuration else {
            state = .idle(selectedDuration: nil)
            return
        }
        
        state = .ready(selectedDuration: duration)
    }
    
    /// Finish countdown and transition to finished state, then auto-reset to ready
    private func finishCountdown() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil
        
        guard storedDuration != nil else {
            state = .idle(selectedDuration: nil)
            return
        }
        
        // Transition to finished state briefly, then auto-reset to ready
        state = .finished
        
        // Auto-reset to ready state after a brief moment
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.5))
            guard let self = self, let duration = self.storedDuration else { return }
            self.state = .ready(selectedDuration: duration)
        }
    }
    
    /// Cancel timer and return to selection screen
    func cancel() {
        // Cancel the countdown task
        countdownTask?.cancel()
        countdownTask = nil
        
        // Preserve the last selected duration in idle state
        let lastDuration = storedDuration
        state = .idle(selectedDuration: lastDuration)
    }
    
    deinit {
        countdownTask?.cancel()
    }
    
    #if DEBUG
    /// Test helper: Manually advance countdown by one second (only available in debug builds for testing)
    func testTick() {
        guard case .countingDown(let currentSeconds) = state else { return }
        
        let newSeconds = currentSeconds - 1
        
        // Trigger haptics at thresholds (flash animation is handled by the view)
        if newSeconds == 10 {
            hapticManager.playWarningHaptic()
        } else if newSeconds == 5 {
            hapticManager.playUrgentHaptic()
        } else if newSeconds == 0 {
            hapticManager.playCompletionHaptic()
            finishCountdown()
            return
        }
        
        state = .countingDown(remainingSeconds: newSeconds)
    }
    #endif
}

