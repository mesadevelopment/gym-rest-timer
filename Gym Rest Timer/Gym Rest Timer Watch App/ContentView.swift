//
//  ContentView.swift
//  Gym Rest Timer Watch App
//
//  Created by Lester Mesa on 11/13/25.
//

import SwiftUI

/// Main coordinator view that manages navigation between timer screens
struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                RestSelectionView(viewModel: viewModel)
                
            case .ready(let selectedDuration):
                ReadyView(viewModel: viewModel, duration: selectedDuration)
                
            case .countingDown:
                CountdownView(viewModel: viewModel)
                
            case .finished:
                // Brief finished state - will auto-transition to ready
                if let duration = viewModel.selectedDuration {
                    ReadyView(viewModel: viewModel, duration: duration)
                } else {
                    RestSelectionView(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
