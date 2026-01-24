//
//  HomeViewModelTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for HomeViewModel
final class HomeViewModelTests: XCTestCase {

    // MARK: - Initial State Tests

    /// Test that initial state is idle
    func testInitialStateIsIdle() {
        let viewModel = HomeViewModel()

        XCTAssertTrue(viewModel.loadingState.isIdle)
        XCTAssertTrue(viewModel.highlightedFormations.isEmpty)
        XCTAssertTrue(viewModel.allFormations.isEmpty)
    }

    // MARK: - Loading State Tests

    /// Test loading state transitions to loading when loadFormations is called
    func testLoadFormationsTransitionsToLoading() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 1.0 // Longer delay to catch loading state
        let viewModel = HomeViewModel(apiService: mockService)

        // Start loading in background
        let task = Task {
            await viewModel.loadFormations()
        }

        // Wait a bit for state to change to loading
        try? await Task.sleep(for: .milliseconds(50))

        XCTAssertTrue(viewModel.loadingState.isLoading)

        // Clean up
        task.cancel()
    }

    // MARK: - Success Tests

    /// Test successful data loading
    func testLoadFormationsSuccess() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        XCTAssertNotNil(viewModel.loadingState.value)
        XCTAssertEqual(viewModel.allFormations.count, Formation.samples.count)
    }

    /// Test highlighted formations returns max 3
    func testHighlightedFormationsReturnsMax3() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        XCTAssertLessThanOrEqual(viewModel.highlightedFormations.count, 3)

        // If we have at least 3 formations in samples, should return exactly 3
        if Formation.samples.count >= 3 {
            XCTAssertEqual(viewModel.highlightedFormations.count, 3)
        }
    }

    /// Test highlighted formations are first 3 from loaded data
    func testHighlightedFormationsAreFirstThree() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        let highlighted = viewModel.highlightedFormations
        let allFormations = viewModel.allFormations

        // Verify highlighted are the first formations
        for (index, formation) in highlighted.enumerated() {
            XCTAssertEqual(formation.id, allFormations[index].id)
        }
    }

    // MARK: - Error Tests

    /// Test error handling with MockAPIService
    func testLoadFormationsErrorHandling() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .networkError("Test error")

        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        XCTAssertNotNil(viewModel.loadingState.errorMessage)
        XCTAssertTrue(viewModel.highlightedFormations.isEmpty)
        XCTAssertTrue(viewModel.allFormations.isEmpty)
    }

    /// Test error message is in French for network error
    func testNetworkErrorMessageIsFrench() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .networkError("Test")

        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        let errorMessage = viewModel.loadingState.errorMessage ?? ""
        // Should contain French error message from APIError
        XCTAssertTrue(errorMessage.contains("connexion") || errorMessage.contains("Erreur"))
    }

    /// Test error message is in French for server error
    func testServerErrorMessageIsFrench() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .serverError(500)

        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        let errorMessage = viewModel.loadingState.errorMessage ?? ""
        // Should contain French error message
        XCTAssertTrue(errorMessage.contains("serveur") || errorMessage.contains("Erreur"))
    }

    /// Test error message is in French for invalid response
    func testInvalidResponseErrorMessageIsFrench() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .badRequest

        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        let errorMessage = viewModel.loadingState.errorMessage ?? ""
        // Should contain French error message
        XCTAssertTrue(errorMessage.contains("réponse") || errorMessage.contains("Erreur"))
    }

    /// Test error message is in French for decoding error
    func testDecodingErrorMessageIsFrench() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .decodingError("Invalid JSON")

        let viewModel = HomeViewModel(apiService: mockService)

        await viewModel.loadFormations()

        let errorMessage = viewModel.loadingState.errorMessage ?? ""
        // Should contain French error message
        XCTAssertTrue(errorMessage.contains("données") || errorMessage.contains("Erreur"))
    }

    // MARK: - Retry Tests

    /// Test retry after error
    func testRetryAfterError() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .serverError(500)

        let viewModel = HomeViewModel(apiService: mockService)

        // First call should fail
        await viewModel.loadFormations()
        XCTAssertNotNil(viewModel.loadingState.errorMessage)

        // Fix the mock
        mockService.shouldFail = false

        // Retry should succeed
        await viewModel.retry()
        XCTAssertNotNil(viewModel.loadingState.value)
        XCTAssertFalse(viewModel.allFormations.isEmpty)
    }

    // MARK: - Concurrent Loading Prevention Tests

    /// Test that concurrent loading is prevented
    func testConcurrentLoadingPrevented() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0.5
        let viewModel = HomeViewModel(apiService: mockService)

        // Start first load
        let task1 = Task {
            await viewModel.loadFormations()
        }

        // Small delay to ensure first task started
        try? await Task.sleep(for: .milliseconds(50))

        // Try to start second load while first is in progress
        await viewModel.loadFormations()

        // Should still be loading from first call
        XCTAssertTrue(viewModel.loadingState.isLoading)

        // Wait for first task to complete
        await task1.value

        XCTAssertNotNil(viewModel.loadingState.value)
    }
}
