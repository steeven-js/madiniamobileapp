//
//  HomeViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Home screen, managing formation data and loading state.
/// Uses the shared FormationsRepository to avoid redundant API calls.
@Observable
final class HomeViewModel {
    // MARK: - Dependencies

    /// Shared repository for formations data
    private let repository: FormationsRepository

    // MARK: - Computed Properties

    /// Current loading state (proxied from repository)
    var loadingState: LoadingState<[Formation]> {
        repository.loadingState
    }

    /// Returns the first 3 formations for the highlights section
    var highlightedFormations: [Formation] {
        repository.highlightedFormations
    }

    /// Returns all loaded formations
    var allFormations: [Formation] {
        repository.formations
    }

    /// Returns unique categories from loaded formations
    var categories: [FormationCategory] {
        repository.categories
    }

    // MARK: - Initialization

    /// Creates a HomeViewModel with the specified repository
    /// - Parameter repository: Shared formations repository (defaults to singleton)
    init(repository: FormationsRepository = .shared) {
        self.repository = repository
    }

    // MARK: - Actions

    /// Loads formations and categories if needed (uses cache if available)
    @MainActor
    func loadFormations() async {
        await repository.fetchIfNeeded()
        await repository.fetchCategoriesIfNeeded()
    }

    /// Retries loading formations and categories after an error
    @MainActor
    func retry() async {
        await repository.refresh()
    }
}
