//
//  CountdownView.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import SwiftUI

/// Screen 3: Active countdown with visual and haptic alerts
struct CountdownView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    @State private var isFlashing = false
    @State private var flashTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background color changes based on remaining time
            ColorManager.backgroundColor(for: viewModel.remainingSeconds)
                .ignoresSafeArea()
                .opacity(isFlashing ? 0.5 : 1.0)
                .animation(.easeOut(duration: 0.3), value: isFlashing)
            
            VStack {
                // X button in top-right corner
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.cancel()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                Spacer()
                
                // Large countdown display
                Text("\(viewModel.remainingSeconds)")
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(isFlashing ? 1.05 : 1.0)
                    .animation(.easeOut(duration: 0.3), value: isFlashing)
                
                Spacer()
            }
        }
        .onTapGesture {
            viewModel.resetToReady()
        }
        .onChange(of: viewModel.remainingSeconds) { oldValue, newValue in
            // Start flash animation at 10s threshold, continue until 0
            // Flash continues through 5s (color changes from orange to red via ColorManager)
            if newValue == 10 {
                startFlashAnimation()
            } else if newValue > 10 {
                // Stop flashing when above 10 seconds
                stopFlashAnimation()
            }
            // Note: Flash continues from 10s down to 0, color changes at 5s are handled by ColorManager
        }
        .onDisappear {
            stopFlashAnimation()
        }
    }
    
    /// Start flash animation (2x per second as per design specs)
    private func startFlashAnimation() {
        stopFlashAnimation() // Clear any existing timer
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                isFlashing.toggle()
            }
        }
        RunLoop.current.add(flashTimer!, forMode: .common)
    }
    
    /// Stop flash animation
    private func stopFlashAnimation() {
        flashTimer?.invalidate()
        flashTimer = nil
        isFlashing = false
    }
}

#Preview {
    let viewModel = TimerViewModel()
    viewModel.selectDuration(.sixty)
    viewModel.startCountdown()
    return CountdownView(viewModel: viewModel)
}

