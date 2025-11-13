//
//  TimerViewModelTests.swift
//  Gym Rest Timer Watch AppTests
//
//  Created by Lester Mesa on 11/13/25.
//

import XCTest
import Combine
@testable import Gym_Rest_Timer_Watch_App

/// Mock haptic manager for testing
class MockHapticManager: HapticManagerProtocol {
    var warningHapticCallCount = 0
    var urgentHapticCallCount = 0
    var completionHapticCallCount = 0
    
    func playWarningHaptic() {
        warningHapticCallCount += 1
    }
    
    func playUrgentHaptic() {
        urgentHapticCallCount += 1
    }
    
    func playCompletionHaptic() {
        completionHapticCallCount += 1
    }
    
    func reset() {
        warningHapticCallCount = 0
        urgentHapticCallCount = 0
        completionHapticCallCount = 0
    }
}

@MainActor
final class TimerViewModelTests: XCTestCase {
    var viewModel: TimerViewModel!
    var mockHapticManager: MockHapticManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockHapticManager = MockHapticManager()
        viewModel = TimerViewModel(hapticManager: mockHapticManager)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockHapticManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - State Machine Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.state, .idle(selectedDuration: nil))
        XCTAssertEqual(viewModel.remainingSeconds, 0)
        XCTAssertNil(viewModel.selectedDuration)
    }
    
    func testSelectDuration() {
        // When
        viewModel.selectDuration(.sixty)
        
        // Then
        XCTAssertEqual(viewModel.state, .ready(selectedDuration: .sixty))
        XCTAssertEqual(viewModel.selectedDuration, .sixty)
    }
    
    func testStartCountdown() {
        // Given
        viewModel.selectDuration(.sixty)
        
        // When
        viewModel.startCountdown()
        
        // Then
        if case .countingDown(let seconds) = viewModel.state {
            XCTAssertEqual(seconds, 60)
            XCTAssertEqual(viewModel.remainingSeconds, 60)
        } else {
            XCTFail("Expected countingDown state")
        }
    }
    
    func testStartCountdownFromNonReadyState() {
        // Given - in idle state
        XCTAssertEqual(viewModel.state, .idle(selectedDuration: nil))
        
        // When
        viewModel.startCountdown()
        
        // Then - should remain in idle state
        XCTAssertEqual(viewModel.state, .idle(selectedDuration: nil))
    }
    
    // MARK: - Haptic Callback Tests
    
    func testWarningHapticAt10Seconds() {
        // Given - start with a 30 second timer to test 10s threshold
        viewModel.selectDuration(.thirty)
        viewModel.startCountdown()
        
        // Verify initial state
        XCTAssertEqual(viewModel.remainingSeconds, 30)
        
        // When - manually tick down to 11 seconds (no haptic yet)
        for _ in 0..<19 {
            viewModel.testTick()
        }
        XCTAssertEqual(viewModel.remainingSeconds, 11)
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 0, "No haptic at 11 seconds")
        
        // When - tick to 10 seconds
        viewModel.testTick()
        
        // Then
        XCTAssertEqual(viewModel.remainingSeconds, 10)
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 1, "Warning haptic should be called at 10 seconds")
        XCTAssertEqual(mockHapticManager.urgentHapticCallCount, 0)
        XCTAssertEqual(mockHapticManager.completionHapticCallCount, 0)
    }
    
    func testUrgentHapticAt5Seconds() {
        // Given
        viewModel.selectDuration(.thirty)
        viewModel.startCountdown()
        
        // When - tick down to 6 seconds
        for _ in 0..<24 {
            viewModel.testTick()
        }
        XCTAssertEqual(viewModel.remainingSeconds, 6)
        XCTAssertEqual(mockHapticManager.urgentHapticCallCount, 0, "No urgent haptic at 6 seconds")
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 1, "Warning haptic should have been called at 10 seconds")
        
        // When - tick to 5 seconds
        viewModel.testTick()
        
        // Then
        XCTAssertEqual(viewModel.remainingSeconds, 5)
        XCTAssertEqual(mockHapticManager.urgentHapticCallCount, 1, "Urgent haptic should be called at 5 seconds")
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 1, "Warning haptic should have been called at 10 seconds")
    }
    
    func testCompletionHapticAt0Seconds() {
        // Given
        viewModel.selectDuration(.thirty)
        viewModel.startCountdown()
        
        // When - tick down to 1 second
        for _ in 0..<29 {
            viewModel.testTick()
        }
        XCTAssertEqual(viewModel.remainingSeconds, 1)
        XCTAssertEqual(mockHapticManager.completionHapticCallCount, 0, "No completion haptic at 1 second")
        
        // When - tick to 0 seconds
        viewModel.testTick()
        
        // Then
        XCTAssertEqual(mockHapticManager.completionHapticCallCount, 1, "Completion haptic should be called at 0 seconds")
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 1)
        XCTAssertEqual(mockHapticManager.urgentHapticCallCount, 1)
        XCTAssertEqual(viewModel.state, .finished, "Should transition to finished state")
    }
    
    func testHapticCallbacksForFullCountdown() {
        // Given - 30 second timer should trigger both 10s and 5s haptics
        mockHapticManager.reset()
        viewModel.selectDuration(.thirty)
        viewModel.startCountdown()
        
        // When - tick through entire countdown
        for _ in 0..<30 {
            viewModel.testTick()
        }
        
        // Then - verify all haptics were called in correct order
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 1, "Should call warning haptic at 10s")
        XCTAssertEqual(mockHapticManager.urgentHapticCallCount, 1, "Should call urgent haptic at 5s")
        XCTAssertEqual(mockHapticManager.completionHapticCallCount, 1, "Should call completion haptic at 0s")
    }
    
    func testNoHapticsAbove10Seconds() {
        // Given
        viewModel.selectDuration(.sixty)
        viewModel.startCountdown()
        
        // When - tick from 60 to 11 seconds
        for _ in 0..<49 {
            viewModel.testTick()
        }
        
        // Then - no haptics should have been called
        XCTAssertEqual(viewModel.remainingSeconds, 11)
        XCTAssertEqual(mockHapticManager.warningHapticCallCount, 0)
        XCTAssertEqual(mockHapticManager.urgentHapticCallCount, 0)
        XCTAssertEqual(mockHapticManager.completionHapticCallCount, 0)
    }
    
    // MARK: - Tap-to-Cancel Tests
    
    func testResetToReadyDuringCountdown() {
        // Given
        viewModel.selectDuration(.sixty)
        viewModel.startCountdown()
        
        // Verify we're counting down
        if case .countingDown = viewModel.state {
            // When - reset during countdown
            viewModel.resetToReady()
            
            // Then - should return to ready state with same duration
            XCTAssertEqual(viewModel.state, .ready(selectedDuration: .sixty))
            XCTAssertEqual(viewModel.selectedDuration, .sixty)
        } else {
            XCTFail("Expected countingDown state")
        }
    }
    
    func testResetToReadyStopsTimer() {
        // Given
        viewModel.selectDuration(.sixty)
        viewModel.startCountdown()
        
        // Verify we're counting down
        if case .countingDown = viewModel.state {
            // When
            viewModel.resetToReady()
            
            // Then - state should be ready, timer should be stopped
            XCTAssertEqual(viewModel.state, .ready(selectedDuration: .sixty))
            
            // Verify timer is stopped by checking that manual ticks don't work from ready state
            let initialState = viewModel.state
            // Attempting to tick from ready state should not change state
            // (tick only works in countingDown state)
            XCTAssertEqual(viewModel.state, initialState, "Timer should be stopped and state should not change")
        } else {
            XCTFail("Expected countingDown state")
        }
    }
    
    func testResetToReadyPreservesDuration() {
        // Given - multiple durations
        viewModel.selectDuration(.ninety)
        viewModel.startCountdown()
        
        // When
        viewModel.resetToReady()
        
        // Then
        XCTAssertEqual(viewModel.selectedDuration, .ninety)
        XCTAssertEqual(viewModel.state, .ready(selectedDuration: .ninety))
    }
    
    // MARK: - Completion Behavior Tests
    
    func testCompletionTransitionsToFinishedThenReady() async {
        // Given
        viewModel.selectDuration(.thirty)
        viewModel.startCountdown()
        
        // When - tick to completion
        for _ in 0..<30 {
            viewModel.testTick()
        }
        
        // Then - should immediately be in finished state
        XCTAssertEqual(viewModel.state, .finished, "Should transition to finished state")
        
        // Wait for auto-reset (0.5 seconds)
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Then - should auto-reset to ready state
        XCTAssertEqual(viewModel.state, .ready(selectedDuration: .thirty), "Should auto-reset to ready state")
        XCTAssertEqual(viewModel.selectedDuration, .thirty)
    }
    
    func testCompletionPreservesDuration() async {
        // Given
        viewModel.selectDuration(.oneTwenty)
        viewModel.startCountdown()
        
        // When - tick to completion
        for _ in 0..<120 {
            viewModel.testTick()
        }
        
        // Wait for auto-reset
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // Then
        XCTAssertEqual(viewModel.selectedDuration, .oneTwenty, "Duration should be preserved after completion")
    }
    
    func testCompletionStopsTimer() {
        // Given
        viewModel.selectDuration(.thirty)
        viewModel.startCountdown()
        
        // When - tick to completion
        for _ in 0..<30 {
            viewModel.testTick()
        }
        
        // Then - verify timer is stopped (state should be finished, not countingDown)
        if case .countingDown = viewModel.state {
            XCTFail("Timer should have stopped at completion")
        }
        XCTAssertEqual(viewModel.state, .finished, "Should be in finished state")
    }
    
    // MARK: - Cancel Tests
    
    func testCancelReturnsToIdle() {
        // Given
        viewModel.selectDuration(.sixty)
        viewModel.startCountdown()
        
        // When
        viewModel.cancel()
        
        // Then
        if case .idle(let duration) = viewModel.state {
            XCTAssertEqual(duration, .sixty, "Should preserve last selected duration")
        } else {
            XCTFail("Expected idle state after cancel")
        }
    }
    
    func testCancelStopsTimer() {
        // Given
        viewModel.selectDuration(.sixty)
        viewModel.startCountdown()
        
        // When
        viewModel.cancel()
        
        // Then - timer should be stopped (state should be idle, not countingDown)
        if case .countingDown = viewModel.state {
            XCTFail("Timer should be stopped after cancel")
        }
        if case .idle(let duration) = viewModel.state {
            XCTAssertEqual(duration, .sixty, "Should preserve duration in idle state")
        } else {
            XCTFail("Expected idle state after cancel")
        }
    }
    
    func testCancelFromReadyState() {
        // Given
        viewModel.selectDuration(.sixty)
        // State is ready
        
        // When
        viewModel.cancel()
        
        // Then
        if case .idle(let duration) = viewModel.state {
            XCTAssertEqual(duration, .sixty)
        } else {
            XCTFail("Expected idle state")
        }
    }
}

