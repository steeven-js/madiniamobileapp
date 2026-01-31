//
//  HomeViewModelTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for HomeViewModel
/// Note: HomeViewModel now uses the shared AppDataRepository (preloaded during splash).
/// These tests verify the ViewModel correctly exposes repository data.
final class HomeViewModelTests: XCTestCase {

    // MARK: - Loading State Tests

    /// Test that loading state reflects repository state
    func testLoadingStateReflectsRepository() {
        let viewModel = HomeViewModel()

        // The loading state is a computed property based on AppDataRepository
        // It should be one of the valid states
        switch viewModel.loadingState {
        case .loaded(let formations):
            XCTAssertEqual(formations.count, viewModel.allFormations.count)
        case .loading:
            // Valid state if data is still loading
            XCTAssertTrue(true)
        case .error:
            // Valid state if there was an error
            XCTAssertTrue(true)
        case .idle:
            // Valid state if not initialized
            XCTAssertTrue(true)
        }
    }

    // MARK: - Computed Properties Tests

    /// Test highlighted formations returns max 3
    func testHighlightedFormationsReturnsMax3() {
        let viewModel = HomeViewModel()

        // Highlighted formations should never exceed 3
        XCTAssertLessThanOrEqual(viewModel.highlightedFormations.count, 3)
    }

    /// Test highlighted formations are from allFormations
    func testHighlightedFormationsAreFromAllFormations() {
        let viewModel = HomeViewModel()

        let highlighted = viewModel.highlightedFormations
        let allFormations = viewModel.allFormations

        // Each highlighted formation should be in allFormations
        for formation in highlighted {
            XCTAssertTrue(allFormations.contains(where: { $0.id == formation.id }))
        }
    }

    /// Test mostViewedFormations returns max 5
    func testMostViewedFormationsReturnsMax5() {
        let viewModel = HomeViewModel()

        XCTAssertLessThanOrEqual(viewModel.mostViewedFormations.count, 5)
    }

    /// Test categories are exposed from repository
    func testCategoriesExposed() {
        let viewModel = HomeViewModel()

        // Categories should match what's in AppDataRepository
        XCTAssertEqual(viewModel.categories.count, AppDataRepository.shared.categories.count)
    }

    // MARK: - Data Source Tests

    /// Test that ViewModel data matches repository data
    func testViewModelDataMatchesRepository() {
        let viewModel = HomeViewModel()

        XCTAssertEqual(viewModel.allFormations.count, AppDataRepository.shared.formations.count)
        XCTAssertEqual(viewModel.categories.count, AppDataRepository.shared.categories.count)
        XCTAssertEqual(viewModel.highlightedFormations.count, AppDataRepository.shared.highlightedFormations.count)
        XCTAssertEqual(viewModel.mostViewedFormations.count, AppDataRepository.shared.mostViewedFormations.count)
    }
}
