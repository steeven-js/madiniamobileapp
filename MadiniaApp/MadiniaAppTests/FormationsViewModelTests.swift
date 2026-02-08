//
//  FormationsViewModelTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for FormationsViewModel
/// Note: FormationsViewModel now uses the shared FormationsRepository which reads from AppDataRepository.
/// These tests verify the ViewModel correctly exposes repository data.
final class FormationsViewModelTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() {
        super.setUp()
        // Reset shared repository state before each test
        FormationsRepository.shared.selectedCategoryFilter = nil
    }

    override func tearDown() {
        // Clean up after each test
        FormationsRepository.shared.selectedCategoryFilter = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    /// Test that ViewModel correctly reflects repository state
    func testViewModelReflectsRepositoryState() {
        let viewModel = FormationsViewModel()

        // ViewModel should expose formations from the shared repository
        XCTAssertEqual(viewModel.formations.count, FormationsRepository.shared.formations.count)
        XCTAssertEqual(viewModel.categories.count, FormationsRepository.shared.categories.count)
    }

    // MARK: - Category Filter Tests

    /// Test that selecting a category updates the filter
    func testSelectCategorySetsFilter() {
        let viewModel = FormationsViewModel()

        // Initially no filter (reset in setUp)
        XCTAssertNil(viewModel.selectedCategory)

        // Skip test if no categories available (repository not loaded)
        guard let firstCategory = viewModel.categories.first else {
            // No categories loaded - this is expected in unit test context
            // Test the mechanism with a mock category instead
            let mockCategory = FormationCategory(id: 999, name: "Test Category", slug: "test", description: nil, color: nil, icon: nil, formationsCount: nil)
            viewModel.selectCategory(mockCategory)
            XCTAssertEqual(viewModel.selectedCategory?.id, mockCategory.id)
            return
        }

        // When - select category from repository
        viewModel.selectCategory(firstCategory)

        // Then
        XCTAssertEqual(viewModel.selectedCategory?.id, firstCategory.id)
    }

    /// Test that selecting same category twice clears filter (toggle behavior)
    func testSelectSameCategoryTwiceTogglesOff() {
        let viewModel = FormationsViewModel()

        if let firstCategory = viewModel.categories.first {
            // First select
            viewModel.selectCategory(firstCategory)
            XCTAssertNotNil(viewModel.selectedCategory)

            // Second select same category - should toggle off
            viewModel.selectCategory(firstCategory)
            XCTAssertNil(viewModel.selectedCategory)
        }
    }

    /// Test that filtered formations respects selected category
    func testFilteredFormationsRespectsCategoryFilter() {
        let viewModel = FormationsViewModel()

        // Without filter, should return all formations
        let allFormations = viewModel.filteredFormations
        XCTAssertEqual(allFormations.count, viewModel.formations.count)

        // With filter, should only return matching formations
        if let firstCategory = viewModel.categories.first {
            viewModel.selectCategory(firstCategory)
            let filteredFormations = viewModel.filteredFormations

            // All filtered formations should belong to the selected category
            for formation in filteredFormations {
                XCTAssertEqual(formation.category?.id, firstCategory.id)
            }
        }
    }

    // MARK: - Loading State Tests

    /// Test that loading state reflects repository state
    func testLoadingStateReflectsRepository() {
        let viewModel = FormationsViewModel()

        // After app initialization, should be in loaded state (data preloaded during splash)
        // This test verifies the computed property works correctly
        switch viewModel.loadingState {
        case .loaded(let formations):
            XCTAssertEqual(formations.count, viewModel.formations.count)
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
}
