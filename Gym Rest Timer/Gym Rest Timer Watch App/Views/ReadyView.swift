//
//  ReadyView.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import SwiftUI

/// Screen 2: Ready screen showing selected time, tap to start
struct ReadyView: View {
    @ObservedObject var viewModel: TimerViewModel
    let duration: TimerDuration
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
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
                
                // Large timer display
                Text(duration.displayText)
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .onTapGesture {
            viewModel.startCountdown()
        }
    }
}

#Preview {
    let viewModel = TimerViewModel()
    viewModel.selectDuration(.sixty)
    return ReadyView(viewModel: viewModel, duration: .sixty)
}

