//
//  FormationsViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Formations screen, managing formation list and loading state.
/// Uses the shared FormationsRepository to avoid redundant API calls.
@Observable
final class FormationsViewModel {
    // MARK: - Dependencies

    /// Shared repository for formations data
    private let repository: FormationsRepository

    // MARK: - Computed Properties

    /// Currently selected category filter (synced with repository for cross-view access)
    var selectedCategory: FormationCategory? {
        get { repository.selectedCategoryFilter }
        set { repository.selectedCategoryFilter = newValue }
    }

    /// Current loading state (proxied from repository)
    var loadingState: LoadingState<[Formation]> {
        repository.loadingState
    }

    /// All loaded formations
    var formations: [Formation] {
        repository.formations
    }

    /// Unique categories extracted from loaded formations
    var categories: [FormationCategory] {
        repository.categories
    }

    /// Formations filtered by selected category
    var filteredFormations: [Formation] {
        repository.formations(inCategory: selectedCategory)
    }

    // MARK: - Initialization

    /// Creates a FormationsViewModel with the specified repository
    /// - Parameter repository: Shared formations repository (defaults to singleton)
    init(repository: FormationsRepository = .shared) {
        self.repository = repository
    }

    // MARK: - Actions

    /// Loads formations if needed (uses cache if available)
    @MainActor
    func loadFormations() async {
        await repository.fetchIfNeeded()
        await repository.fetchCategoriesIfNeeded()
    }

    /// Refreshes formations from the API (for pull-to-refresh)
    @MainActor
    func refresh() async {
        await repository.refresh()
    }

    /// Selects or deselects a category filter
    /// - Parameter category: The category to select, or nil to clear filter
    func selectCategory(_ category: FormationCategory?) {
        if selectedCategory?.id == category?.id {
            selectedCategory = nil  // Toggle off if same category
        } else {
            selectedCategory = category
        }
    }
}
