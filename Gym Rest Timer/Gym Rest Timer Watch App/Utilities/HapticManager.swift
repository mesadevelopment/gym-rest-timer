//
//  HapticManager.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import WatchKit

/// Manages haptic feedback for timer alerts
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Play subtle haptic at 10 seconds remaining
    func playWarningHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    /// Play stronger haptic at 5 seconds remaining
    func playUrgentHaptic() {
        WKInterfaceDevice.current().play(.retry)
    }
    
    /// Play completion haptic when timer ends
    func playCompletionHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
}

