//
//  SearchViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation
import Observation

/// ViewModel managing data for the SearchView.
/// Handles loading of services, formations, and categories.
@Observable
final class SearchViewModel {
    // MARK: - Published Properties

    /// All loaded services
    private(set) var services: [Service] = []

    /// All loaded formations
    private(set) var formations: [Formation] = []

    /// All loaded categories
    private(set) var categories: [FormationCategory] = []

    /// Current loading state (using Void as data is stored separately)
    private(set) var loadingState: LoadingState<Void> = .idle

    /// Search query text
    var searchQuery: String = ""

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Computed Properties

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

    // MARK: - Data Loading

    /// Loads all data (services, formations, categories) in parallel
    @MainActor
    func loadData() async {
        loadingState = .loading

        do {
            async let servicesTask = apiService.fetchServices()
            async let formationsTask = apiService.fetchFormations()
            async let categoriesTask = apiService.fetchCategories()

            let (loadedServices, loadedFormations, loadedCategories) = try await (
                servicesTask,
                formationsTask,
                categoriesTask
            )

            services = loadedServices
            formations = loadedFormations
            categories = loadedCategories
            loadingState = .loaded(())
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    /// Refreshes all data
    @MainActor
    func refresh() async {
        await loadData()
    }
}
