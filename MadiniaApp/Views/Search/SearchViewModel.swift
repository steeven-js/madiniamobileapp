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

    /// Search filters
    var filters = SearchFilters()

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

    /// Filtered services based on search query and sorting
    var filteredServices: [Service] {
        var result = services

        // Apply text search
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                ($0.shortDescription?.lowercased().contains(query) ?? false)
            }
        }

        // Apply sorting (only alphabetical applies to services)
        result = sortServices(result)

        return result
    }

    /// Sort services based on selected sort option
    private func sortServices(_ services: [Service]) -> [Service] {
        switch filters.sortOption {
        case .relevance:
            // Default order
            return services

        case .popularity:
            return services.sorted { ($0.viewsCount ?? 0) > ($1.viewsCount ?? 0) }

        case .dateNewest:
            return services.sorted { (s1, s2) in
                guard let d1 = s1.publishedAt, let d2 = s2.publishedAt else { return false }
                return d1 > d2
            }

        case .dateOldest:
            return services.sorted { (s1, s2) in
                guard let d1 = s1.publishedAt, let d2 = s2.publishedAt else { return false }
                return d1 < d2
            }

        case .alphabetical:
            return services.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        case .durationShortest, .durationLongest:
            // Duration doesn't apply to services
            return services
        }
    }

    /// Filtered formations based on search query and filters
    var filteredFormations: [Formation] {
        var result = formations

        // Apply text search
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                ($0.shortDescription?.lowercased().contains(query) ?? false) ||
                ($0.category?.name.lowercased().contains(query) ?? false)
            }
        }

        // Apply level filter
        if let levelValue = filters.levelFilter.apiValue {
            result = result.filter { $0.level == levelValue }
        }

        // Apply duration filter
        if filters.durationFilter != .all {
            result = result.filter { filters.durationFilter.matches(hours: $0.durationHours) }
        }

        // Apply certification filter
        if filters.certificationOnly {
            result = result.filter { $0.certification == true }
        }

        // Apply category filter
        if let categoryId = filters.selectedCategoryId {
            result = result.filter { $0.category?.id == categoryId }
        }

        // Apply sorting
        result = sortFormations(result)

        return result
    }

    /// Sort formations based on selected sort option
    private func sortFormations(_ formations: [Formation]) -> [Formation] {
        switch filters.sortOption {
        case .relevance:
            // Default order (as returned by API)
            return formations

        case .popularity:
            return formations.sorted { ($0.viewsCount ?? 0) > ($1.viewsCount ?? 0) }

        case .dateNewest:
            return formations.sorted { (f1, f2) in
                guard let d1 = f1.publishedAt, let d2 = f2.publishedAt else { return false }
                return d1 > d2
            }

        case .dateOldest:
            return formations.sorted { (f1, f2) in
                guard let d1 = f1.publishedAt, let d2 = f2.publishedAt else { return false }
                return d1 < d2
            }

        case .durationShortest:
            return formations.sorted { ($0.durationHours ?? 0) < ($1.durationHours ?? 0) }

        case .durationLongest:
            return formations.sorted { ($0.durationHours ?? 0) > ($1.durationHours ?? 0) }

        case .alphabetical:
            return formations.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
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

    /// Whether filters or search are affecting results
    var isFiltering: Bool {
        isSearching || filters.hasActiveFilters
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
