//
//  ColorManager.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import SwiftUI

/// Manages color states for timer visual cues
struct ColorManager {
    /// Background color based on remaining seconds
    static func backgroundColor(for remainingSeconds: Int) -> Color {
        if remainingSeconds <= 5 {
            return .red
        } else if remainingSeconds <= 10 {
            return .orange
        } else {
            return .black
        }
    }
    
    /// Text color (always white for contrast)
    static let textColor = Color.white
    
    /// Button fill color (semi-transparent white)
    static let buttonFill = Color.white.opacity(0.08)
    
    /// Button border color
    static let buttonBorder = Color.white.opacity(0.20)
}

