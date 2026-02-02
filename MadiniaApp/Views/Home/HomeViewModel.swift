//
//  HomeViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Home screen, managing formation data and loading state.
/// Uses the shared AppDataRepository - data is preloaded during splash.
@Observable
final class HomeViewModel {
    // MARK: - Dependencies

    /// Centralized data repository (preloaded during splash)
    private let dataRepository: AppDataRepository

    // MARK: - Computed Properties

    /// Current loading state based on repository
    var loadingState: LoadingState<[Formation]> {
        if dataRepository.isLoading && !dataRepository.hasData {
            return .loading
        } else if let error = dataRepository.errorMessage, !dataRepository.hasData {
            return .error(error)
        } else {
            return .loaded(dataRepository.formations)
        }
    }

    /// Returns the first 3 formations for the highlights section
    var highlightedFormations: [Formation] {
        dataRepository.highlightedFormations
    }

    /// Returns most viewed formations
    var mostViewedFormations: [Formation] {
        dataRepository.mostViewedFormations
    }

    /// Returns all loaded formations
    var allFormations: [Formation] {
        dataRepository.formations
    }

    /// Returns all categories
    var categories: [FormationCategory] {
        dataRepository.categories
    }

    /// Returns recent articles sorted by publication date (most recent first)
    var recentArticles: [Article] {
        dataRepository.recentArticles
    }

    // MARK: - Initialization

    /// Creates a HomeViewModel with the specified repository
    init(dataRepository: AppDataRepository = .shared) {
        self.dataRepository = dataRepository
    }

    // MARK: - Actions

    /// Called when view appears - data is already preloaded, nothing to do
    @MainActor
    func loadFormations() async {
        // Data is already preloaded by AppDataRepository during splash
        // This method exists for API compatibility but does nothing
    }

    /// Refreshes data from API (pull-to-refresh)
    @MainActor
    func retry() async {
        await dataRepository.refresh()
    }
}
