//
//  SearchViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation
import Observation

/// ViewModel managing data for the SearchView.
/// Uses AppDataRepository for preloaded data - no additional API calls needed.
@Observable
final class SearchViewModel {
    // MARK: - Dependencies

    /// Centralized data repository (preloaded during splash)
    private let dataRepository: AppDataRepository

    // MARK: - State

    /// Search query text
    var searchQuery: String = ""

    // MARK: - Initialization

    init(dataRepository: AppDataRepository = .shared) {
        self.dataRepository = dataRepository
    }

    // MARK: - Data Access (from preloaded repository)

    /// All services (preloaded)
    var services: [Service] {
        dataRepository.services
    }

    /// All formations (preloaded)
    var formations: [Formation] {
        dataRepository.formations
    }

    /// All categories (preloaded)
    var categories: [FormationCategory] {
        dataRepository.categories
    }

    /// Loading state based on repository
    var loadingState: LoadingState<Void> {
        if dataRepository.isLoading && !dataRepository.hasData {
            return .loading
        } else if let error = dataRepository.errorMessage, !dataRepository.hasData {
            return .error(error)
        } else {
            return .loaded(())
        }
    }

    // MARK: - Computed Properties (Filtering)

    /// Filtered services based on search query
    var filteredServices: [Service] {
        guard !searchQuery.isEmpty else { return services }
        let query = searchQuery.lowercased()
        return services.filter {
            $0.name.lowercased().contains(query) ||
            ($0.shortDescription?.lowercased().contains(query) ?? false)
        }
    }

    /// Filtered formations based on search query
    var filteredFormations: [Formation] {
        guard !searchQuery.isEmpty else { return formations }
        let query = searchQuery.lowercased()
        return formations.filter {
            $0.title.lowercased().contains(query) ||
            ($0.shortDescription?.lowercased().contains(query) ?? false) ||
            ($0.category?.name.lowercased().contains(query) ?? false)
        }
    }

    /// Filtered categories based on search query
    var filteredCategories: [FormationCategory] {
        guard !searchQuery.isEmpty else { return categories }
        let query = searchQuery.lowercased()
        return categories.filter {
            $0.name.lowercased().contains(query)
        }
    }

    /// Whether any search results exist
    var hasSearchResults: Bool {
        !filteredServices.isEmpty || !filteredFormations.isEmpty || !filteredCategories.isEmpty
    }

    /// Whether the search is active (non-empty query)
    var isSearching: Bool {
        !searchQuery.isEmpty
    }

    // MARK: - Actions

    /// Called when view appears - data is already preloaded, nothing to do
    @MainActor
    func loadData() async {
        // Data is already preloaded by AppDataRepository during splash
        // This method exists for API compatibility but does nothing
    }

    /// Refreshes data from API (pull-to-refresh)
    @MainActor
    func refresh() async {
        await dataRepository.refresh()
    }
}
