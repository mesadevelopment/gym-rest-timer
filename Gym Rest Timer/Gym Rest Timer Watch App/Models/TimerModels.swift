//
//  TimerModels.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import Foundation

/// Represents the available preset rest timer durations
enum TimerDuration: Int, CaseIterable, Identifiable {
    case thirty = 30
    case sixty = 60
    case ninety = 90
    case oneTwenty = 120
    
    var id: Int { rawValue }
    
    var displayText: String {
        "\(rawValue)s"
    }
}

/// Represents the current state of the timer
enum TimerState {
    case idle(selectedDuration: TimerDuration?)
    case ready(selectedDuration: TimerDuration)
    case countingDown(remainingSeconds: Int)
    case finished
}

