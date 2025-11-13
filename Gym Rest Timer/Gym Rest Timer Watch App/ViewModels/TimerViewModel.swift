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
    
    private var timer: Timer?
    private let hapticManager = HapticManager.shared
    
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
        
        storedDuration = duration
        state = .countingDown(remainingSeconds: duration.rawValue)
        
        // Start timer using Timer API for precise countdown
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        
        // Add timer to RunLoop to keep it active
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    /// Handle each second tick during countdown
    private func tick() {
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
    
    /// Reset timer back to ready state (called when user taps during countdown)
    func resetToReady() {
        timer?.invalidate()
        timer = nil
        
        guard let duration = storedDuration else {
            state = .idle(selectedDuration: nil)
            return
        }
        
        state = .ready(selectedDuration: duration)
    }
    
    /// Finish countdown and transition to finished state, then auto-reset to ready
    private func finishCountdown() {
        timer?.invalidate()
        timer = nil
        
        guard storedDuration != nil else {
            state = .idle(selectedDuration: nil)
            return
        }
        
        // Transition to finished state briefly, then auto-reset to ready
        state = .finished
        
        // Auto-reset to ready state after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            Task { @MainActor in
                guard let self = self, let duration = self.storedDuration else { return }
                self.state = .ready(selectedDuration: duration)
            }
        }
    }
    
    /// Cancel timer and return to selection screen
    func cancel() {
        timer?.invalidate()
        timer = nil
        
        // Preserve the last selected duration in idle state
        let lastDuration = storedDuration
        state = .idle(selectedDuration: lastDuration)
    }
    
    deinit {
        timer?.invalidate()
    }
}

