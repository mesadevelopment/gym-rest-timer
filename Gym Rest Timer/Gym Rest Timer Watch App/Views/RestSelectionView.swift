//
//  RestSelectionView.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import SwiftUI

/// Screen 1: Preset timer selection (30s, 60s, 90s, 120s)
struct RestSelectionView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(TimerDuration.allCases) { duration in
                RestButton(
                    duration: duration,
                    action: {
                        viewModel.selectDuration(duration)
                    }
                )
            }
        }
        .padding()
    }
}

/// Large, tappable button for rest duration selection
struct RestButton: View {
    let duration: TimerDuration
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(duration.displayText)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .background(ColorManager.buttonFill)
                .cornerRadius(34)
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .stroke(ColorManager.buttonBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RestSelectionView(viewModel: TimerViewModel())
}

