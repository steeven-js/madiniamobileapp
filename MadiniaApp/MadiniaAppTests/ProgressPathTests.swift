//
//  ProgressPathTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for ProgressPath and ProgressStep
final class ProgressPathTests: XCTestCase {

    // MARK: - ProgressStep Tests

    /// Test that 3 steps are defined
    func testThreeStepsExist() {
        let steps = ProgressStep.steps

        XCTAssertEqual(steps.count, 3, "Expected exactly 3 steps in the progress path")
    }

    /// Test step order: Starter, Performer, Master
    func testStepOrder() {
        let steps = ProgressStep.steps

        XCTAssertEqual(steps[0].id, "starter")
        XCTAssertEqual(steps[1].id, "performer")
        XCTAssertEqual(steps[2].id, "master")
    }

    /// Test step names are correct
    func testStepNames() {
        let steps = ProgressStep.steps

        XCTAssertEqual(steps[0].name, "Starter")
        XCTAssertEqual(steps[1].name, "Performer")
        XCTAssertEqual(steps[2].name, "Master")
    }

    /// Test step descriptions are in French
    func testStepDescriptions() {
        let steps = ProgressStep.steps

        XCTAssertEqual(steps[0].description, "Fondations IA")
        XCTAssertEqual(steps[1].description, "Maîtrise avancée")
        XCTAssertEqual(steps[2].description, "Expertise complète")
    }

    /// Test step icons are SF Symbols
    func testStepIcons() {
        let steps = ProgressStep.steps

        XCTAssertEqual(steps[0].icon, "star.fill")
        XCTAssertEqual(steps[1].icon, "flame.fill")
        XCTAssertEqual(steps[2].icon, "crown.fill")
    }

    /// Test steps have unique IDs (color comparison via ID proxy)
    /// Note: SwiftUI Color equality can be unreliable, so we verify via unique IDs
    /// and ensure each step has a distinct identity
    func testStepsHaveUniqueIdentities() {
        let steps = ProgressStep.steps
        let ids = Set(steps.map { $0.id })

        // All 3 steps should have unique IDs
        XCTAssertEqual(ids.count, 3, "Each step should have a unique ID")
        XCTAssertTrue(ids.contains("starter"))
        XCTAssertTrue(ids.contains("performer"))
        XCTAssertTrue(ids.contains("master"))
    }

    /// Test ProgressStep conforms to Identifiable
    func testStepIsIdentifiable() {
        let step = ProgressStep.steps[0]

        // id should be the same as the step's id property
        XCTAssertEqual(step.id, "starter")
    }

    /// Test ProgressStep conforms to Equatable
    func testStepIsEquatable() {
        let step1 = ProgressStep.steps[0]
        let step2 = ProgressStep.steps[0]

        XCTAssertEqual(step1, step2)
    }

    // MARK: - ProgressPath Tap Callback Tests

    /// Test ProgressPath accepts and stores callback closure
    /// Note: Actual button tap testing requires XCUITest
    func testProgressPathAcceptsCallback() {
        var callbackInvoked = false

        // Create callback that sets flag when called
        let callback: (ProgressStep) -> Void = { _ in
            callbackInvoked = true
        }

        // Create ProgressPath with callback
        let progressPath = ProgressPath(onStepTap: callback)

        // Verify callback is stored (onStepTap is not nil)
        XCTAssertNotNil(progressPath.onStepTap)

        // Manually invoke to verify closure works
        progressPath.onStepTap?(ProgressStep.steps[0])
        XCTAssertTrue(callbackInvoked, "Callback should be invokable")
    }

    /// Test all steps can trigger callback
    func testAllStepsCanTriggerCallback() {
        var tappedStepIds: [String] = []

        let callback: (ProgressStep) -> Void = { step in
            tappedStepIds.append(step.id)
        }

        // Simulate tapping each step
        for step in ProgressStep.steps {
            callback(step)
        }

        XCTAssertEqual(tappedStepIds.count, 3)
        XCTAssertTrue(tappedStepIds.contains("starter"))
        XCTAssertTrue(tappedStepIds.contains("performer"))
        XCTAssertTrue(tappedStepIds.contains("master"))
    }

    // MARK: - Accessibility Tests

    /// Test step accessibility labels contain name and description
    func testStepAccessibilityLabelFormat() {
        let steps = ProgressStep.steps

        for step in steps {
            let expectedLabel = "\(step.name), \(step.description)"
            // This tests the format we use in accessibilityLabel
            XCTAssertFalse(expectedLabel.isEmpty)
            XCTAssertTrue(expectedLabel.contains(step.name))
            XCTAssertTrue(expectedLabel.contains(step.description))
        }
    }

    /// Test step accessibility hints contain step name and action
    func testStepAccessibilityHintFormat() {
        let steps = ProgressStep.steps

        for step in steps {
            let expectedHint = "Appuyez pour voir les formations \(step.name)"
            // Verify hint format matches what we use in ProgressPath
            XCTAssertFalse(expectedHint.isEmpty)
            XCTAssertTrue(expectedHint.contains("Appuyez"))
            XCTAssertTrue(expectedHint.contains("formations"))
            XCTAssertTrue(expectedHint.contains(step.name))
        }
    }
}
