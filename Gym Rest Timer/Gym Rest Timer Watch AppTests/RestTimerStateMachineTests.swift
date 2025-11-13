//
//  RestTimerStateMachineTests.swift
//  Gym Rest Timer Watch AppTests
//
//  Created by Lester Mesa on 11/13/25.
//

import XCTest
@testable import Gym_Rest_Timer_Watch_App

/// Unit tests for the pure RestTimerStateMachine
final class RestTimerStateMachineTests: XCTestCase {
    var stateMachine: RestTimerStateMachine!

    override func setUp() {
        super.setUp()
        stateMachine = RestTimerStateMachine()
    }

    override func tearDown() {
        stateMachine = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(stateMachine.state, .idle(selectedDuration: nil))
        XCTAssertEqual(stateMachine.remainingSeconds, 0)
        XCTAssertNil(stateMachine.selectedDuration)
    }

    // MARK: - State Transition Tests

    func testSelectDuration() {
        // When
        stateMachine.selectDuration(.sixty)

        // Then
        XCTAssertEqual(stateMachine.state, .ready(selectedDuration: .sixty))
        XCTAssertEqual(stateMachine.selectedDuration, .sixty)
    }

    func testStartCountdownFromReadyState() {
        // Given
        stateMachine.selectDuration(.sixty)

        // When
        let success = stateMachine.startCountdown()

        // Then
        XCTAssertTrue(success)
        if case .countingDown(let seconds) = stateMachine.state {
            XCTAssertEqual(seconds, 60)
            XCTAssertEqual(stateMachine.remainingSeconds, 60)
        } else {
            XCTFail("Expected countingDown state")
        }
    }

    func testStartCountdownFromNonReadyStateFails() {
        // Given - in idle state
        XCTAssertEqual(stateMachine.state, .idle(selectedDuration: nil))

        // When
        let success = stateMachine.startCountdown()

        // Then
        XCTAssertFalse(success)
        XCTAssertEqual(stateMachine.state, .idle(selectedDuration: nil))
    }

    func testResetToReady() {
        // Given
        stateMachine.selectDuration(.sixty)
        stateMachine.startCountdown()

        // When
        stateMachine.resetToReady()

        // Then
        XCTAssertEqual(stateMachine.state, .ready(selectedDuration: .sixty))
        XCTAssertEqual(stateMachine.selectedDuration, .sixty)
    }

    func testCancel() {
        // Given
        stateMachine.selectDuration(.sixty)
        stateMachine.startCountdown()

        // When
        stateMachine.cancel()

        // Then
        if case .idle(let duration) = stateMachine.state {
            XCTAssertEqual(duration, .sixty)
        } else {
            XCTFail("Expected idle state")
        }
    }

    func testFinish() {
        // Given
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()

        // When
        stateMachine.finish()

        // Then
        XCTAssertEqual(stateMachine.state, .finished)
    }

    func testAutoResetToReady() {
        // Given
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()
        stateMachine.finish()

        // When
        stateMachine.autoResetToReady()

        // Then
        XCTAssertEqual(stateMachine.state, .ready(selectedDuration: .thirty))
        XCTAssertEqual(stateMachine.selectedDuration, .thirty)
    }

    // MARK: - Tick Logic Tests

    func testTickDecrements() {
        // Given
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()

        // When
        let result = stateMachine.tick()

        // Then
        if case .countingDown(let seconds) = result.newState {
            XCTAssertEqual(seconds, 29)
        } else {
            XCTFail("Expected countingDown state")
        }
        XCTAssertFalse(result.shouldPlayWarningHaptic)
        XCTAssertFalse(result.shouldPlayUrgentHaptic)
        XCTAssertFalse(result.shouldPlayCompletionHaptic)
        XCTAssertFalse(result.shouldFinish)
    }

    func testTickFromNonCountdownStateReturnsNoOp() {
        // Given - in idle state

        // When
        let result = stateMachine.tick()

        // Then
        XCTAssertEqual(result.newState, .idle(selectedDuration: nil))
        XCTAssertFalse(result.shouldPlayWarningHaptic)
        XCTAssertFalse(result.shouldPlayUrgentHaptic)
        XCTAssertFalse(result.shouldPlayCompletionHaptic)
        XCTAssertFalse(result.shouldFinish)
    }

    func testTickAt10SecondsTriggersWarningHaptic() {
        // Given - countdown to 11 seconds
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()
        for _ in 0..<19 {
            _ = stateMachine.tick()
        }
        XCTAssertEqual(stateMachine.remainingSeconds, 11)

        // When - tick to 10 seconds
        let result = stateMachine.tick()

        // Then
        XCTAssertEqual(stateMachine.remainingSeconds, 10)
        XCTAssertTrue(result.shouldPlayWarningHaptic)
        XCTAssertFalse(result.shouldPlayUrgentHaptic)
        XCTAssertFalse(result.shouldPlayCompletionHaptic)
        XCTAssertFalse(result.shouldFinish)
    }

    func testTickAt5SecondsTriggersUrgentHaptic() {
        // Given - countdown to 6 seconds
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()
        for _ in 0..<24 {
            _ = stateMachine.tick()
        }
        XCTAssertEqual(stateMachine.remainingSeconds, 6)

        // When - tick to 5 seconds
        let result = stateMachine.tick()

        // Then
        XCTAssertEqual(stateMachine.remainingSeconds, 5)
        XCTAssertFalse(result.shouldPlayWarningHaptic)
        XCTAssertTrue(result.shouldPlayUrgentHaptic)
        XCTAssertFalse(result.shouldPlayCompletionHaptic)
        XCTAssertFalse(result.shouldFinish)
    }

    func testTickAt0SecondsTriggersCompletionHapticAndFinish() {
        // Given - countdown to 1 second
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()
        for _ in 0..<29 {
            _ = stateMachine.tick()
        }
        XCTAssertEqual(stateMachine.remainingSeconds, 1)

        // When - tick to 0 seconds
        let result = stateMachine.tick()

        // Then
        XCTAssertEqual(stateMachine.remainingSeconds, 0)
        XCTAssertFalse(result.shouldPlayWarningHaptic)
        XCTAssertFalse(result.shouldPlayUrgentHaptic)
        XCTAssertTrue(result.shouldPlayCompletionHaptic)
        XCTAssertTrue(result.shouldFinish)
    }

    func testFullCountdownSequence() {
        // Given
        stateMachine.selectDuration(.thirty)
        stateMachine.startCountdown()

        var warningHapticFired = false
        var urgentHapticFired = false
        var completionHapticFired = false

        // When - tick through entire countdown
        for _ in 0..<30 {
            let result = stateMachine.tick()

            if result.shouldPlayWarningHaptic {
                warningHapticFired = true
            }
            if result.shouldPlayUrgentHaptic {
                urgentHapticFired = true
            }
            if result.shouldPlayCompletionHaptic {
                completionHapticFired = true
            }
        }

        // Then
        XCTAssertTrue(warningHapticFired, "Warning haptic should fire at 10s")
        XCTAssertTrue(urgentHapticFired, "Urgent haptic should fire at 5s")
        XCTAssertTrue(completionHapticFired, "Completion haptic should fire at 0s")
        XCTAssertEqual(stateMachine.remainingSeconds, 0)
    }

    // MARK: - Duration Preservation Tests

    func testDurationPreservedThroughCountdown() {
        // Given
        stateMachine.selectDuration(.ninety)
        stateMachine.startCountdown()

        // When - tick a few times
        for _ in 0..<10 {
            _ = stateMachine.tick()
        }

        // Then
        XCTAssertEqual(stateMachine.selectedDuration, .ninety)
    }

    func testDurationPreservedAfterReset() {
        // Given
        stateMachine.selectDuration(.oneTwenty)
        stateMachine.startCountdown()

        // When
        stateMachine.resetToReady()

        // Then
        XCTAssertEqual(stateMachine.selectedDuration, .oneTwenty)
    }

    func testDurationPreservedAfterCancel() {
        // Given
        stateMachine.selectDuration(.sixty)
        stateMachine.startCountdown()

        // When
        stateMachine.cancel()

        // Then
        XCTAssertEqual(stateMachine.selectedDuration, .sixty)
    }

    // MARK: - Edge Cases

    func testResetFromIdleState() {
        // Given - in idle state with no duration

        // When
        stateMachine.resetToReady()

        // Then - should remain in idle
        XCTAssertEqual(stateMachine.state, .idle(selectedDuration: nil))
    }

    func testCancelPreservesDuration() {
        // Given
        stateMachine.selectDuration(.thirty)

        // When
        stateMachine.cancel()

        // Then - duration should be preserved in idle state
        if case .idle(let duration) = stateMachine.state {
            XCTAssertEqual(duration, .thirty)
        } else {
            XCTFail("Expected idle state with duration")
        }
    }
}
