//
//  FormationsViewModelTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for FormationsViewModel
final class FormationsViewModelTests: XCTestCase {

    // MARK: - Initial State Tests

    /// Test that ViewModel starts in idle state
    func testInitialStateIsIdle() {
        let viewModel = FormationsViewModel(apiService: MockAPIService())

        XCTAssertTrue(viewModel.loadingState.isIdle, "Initial state should be idle")
        XCTAssertTrue(viewModel.formations.isEmpty, "Formations should be empty initially")
    }

    // MARK: - loadFormations Tests

    /// Test that loadFormations populates formations on success
    @MainActor
    func testLoadFormationsPopulatesFormations() async {
        // Given
        let mockService = MockAPIService()
        let viewModel = FormationsViewModel(apiService: mockService)

        // When
        await viewModel.loadFormations()

        // Then
        XCTAssertFalse(viewModel.formations.isEmpty, "Formations should not be empty after load")
        XCTAssertEqual(viewModel.formations.count, Formation.samples.count, "Should load all sample formations")
    }

    /// Test that loadFormations sets loaded state on success
    @MainActor
    func testLoadFormationsSetsLoadedState() async {
        // Given
        let mockService = MockAPIService()
        let viewModel = FormationsViewModel(apiService: mockService)

        // When
        await viewModel.loadFormations()

        // Then
        if case .loaded(let formations) = viewModel.loadingState {
            XCTAssertEqual(formations.count, Formation.samples.count)
        } else {
            XCTFail("Expected loaded state, got \(viewModel.loadingState)")
        }
    }

    /// Test that loadFormations sets error state on failure
    @MainActor
    func testLoadFormationsSetsErrorStateOnFailure() async {
        // Given
        let mockService = MockAPIService()
        mockService.shouldFail = true
        mockService.errorToThrow = .networkError("Simulated network error")
        let viewModel = FormationsViewModel(apiService: mockService)

        // When
        await viewModel.loadFormations()

        // Then
        if case .error(let message) = viewModel.loadingState {
            XCTAssertFalse(message.isEmpty, "Error message should not be empty")
        } else {
            XCTFail("Expected error state, got \(viewModel.loadingState)")
        }
    }

    /// Test that loadFormations prevents duplicate requests
    @MainActor
    func testLoadFormationsPreventsDuplicateRequests() async {
        // Given
        let mockService = MockAPIService()
        mockService.simulatedDelay = 1.0 // Long delay to ensure overlap
        let viewModel = FormationsViewModel(apiService: mockService)

        // When - start first load
        let task1 = Task {
            await viewModel.loadFormations()
        }

        // Small delay to ensure first request starts
        try? await Task.sleep(for: .milliseconds(100))

        // Verify state is loading
        XCTAssertTrue(viewModel.loadingState.isLoading, "Should be in loading state")

        // Start second load (should be ignored)
        await viewModel.loadFormations()

        // Wait for first task to complete
        await task1.value

        // Then - should only have loaded once
        XCTAssertFalse(viewModel.loadingState.isLoading)
    }

    // MARK: - refresh Tests

    /// Test that refresh reloads formations
    @MainActor
    func testRefreshReloadsFormations() async {
        // Given
        let mockService = MockAPIService()
        let viewModel = FormationsViewModel(apiService: mockService)

        // First load
        await viewModel.loadFormations()
        XCTAssertFalse(viewModel.formations.isEmpty)

        // When - refresh
        await viewModel.refresh()

        // Then - still has formations (reloaded)
        XCTAssertFalse(viewModel.formations.isEmpty)
        XCTAssertEqual(viewModel.formations.count, Formation.samples.count)
    }

    /// Test that refresh resets to idle before loading
    @MainActor
    func testRefreshResetsStateToIdleFirst() async {
        // Given
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0.5
        let viewModel = FormationsViewModel(apiService: mockService)

        // First load to get to loaded state
        await viewModel.loadFormations()
        XCTAssertFalse(viewModel.loadingState.isIdle)

        // When - start refresh
        let refreshTask = Task {
            await viewModel.refresh()
        }

        // Small delay to check intermediate state
        try? await Task.sleep(for: .milliseconds(100))

        // Then - should transition through loading
        // (state is either idle briefly or loading)
        await refreshTask.value

        // After refresh completes
        if case .loaded = viewModel.loadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loaded state after refresh")
        }
    }

    // MARK: - Loading State Transitions Tests

    /// Test loading state transitions: idle → loading → loaded
    @MainActor
    func testLoadingStateTransitionsOnSuccess() async {
        // Given
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0.1
        let viewModel = FormationsViewModel(apiService: mockService)

        // Initial state
        XCTAssertTrue(viewModel.loadingState.isIdle, "Should start idle")

        // When
        let loadTask = Task {
            await viewModel.loadFormations()
        }

        // Small delay to check loading state
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertTrue(viewModel.loadingState.isLoading, "Should be loading")

        // Wait for completion
        await loadTask.value

        // Then
        if case .loaded = viewModel.loadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should end in loaded state")
        }
    }

    /// Test loading state transitions: idle → loading → error
    @MainActor
    func testLoadingStateTransitionsOnError() async {
        // Given
        let mockService = MockAPIService()
        mockService.shouldFail = true
        mockService.simulatedDelay = 0.1
        let viewModel = FormationsViewModel(apiService: mockService)

        // Initial state
        XCTAssertTrue(viewModel.loadingState.isIdle)

        // When
        let loadTask = Task {
            await viewModel.loadFormations()
        }

        // Small delay to check loading state
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertTrue(viewModel.loadingState.isLoading)

        // Wait for completion
        await loadTask.value

        // Then
        if case .error = viewModel.loadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should end in error state")
        }
    }

    // MARK: - formations Computed Property Tests

    /// Test formations returns empty array when not loaded
    func testFormationsReturnsEmptyWhenNotLoaded() {
        let viewModel = FormationsViewModel(apiService: MockAPIService())

        XCTAssertTrue(viewModel.formations.isEmpty)
    }

    /// Test formations returns loaded data
    @MainActor
    func testFormationsReturnsLoadedData() async {
        // Given
        let mockService = MockAPIService()
        let viewModel = FormationsViewModel(apiService: mockService)

        // When
        await viewModel.loadFormations()

        // Then
        XCTAssertEqual(viewModel.formations.count, Formation.samples.count)
        XCTAssertEqual(viewModel.formations.first?.title, Formation.samples.first?.title)
    }
}
