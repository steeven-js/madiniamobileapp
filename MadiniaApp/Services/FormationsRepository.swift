//
//  FormationsRepository.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation

/// Shared repository for formations data with category filtering.
/// Uses AppDataRepository as data source (preloaded during splash).
@Observable
final class FormationsRepository {
    // MARK: - Singleton

    /// Shared instance for app-wide access
    static let shared = FormationsRepository()

    // MARK: - Dependencies

    /// Centralized data repository (preloaded during splash)
    private let dataRepository: AppDataRepository

    // MARK: - State

    /// Currently selected category filter for formations tab (shared state)
    var selectedCategoryFilter: FormationCategory?

    // MARK: - Computed Properties

    /// Cached formations data (from AppDataRepository)
    var formations: [Formation] {
        dataRepository.formations
    }

    /// Cached categories data (from AppDataRepository)
    var categories: [FormationCategory] {
        dataRepository.categories
    }

    /// Current loading state for formations
    var loadingState: LoadingState<[Formation]> {
        if dataRepository.isLoading && !dataRepository.hasData {
            return .loading
        } else if let error = dataRepository.errorMessage, !dataRepository.hasData {
            return .error(error)
        } else {
            return .loaded(dataRepository.formations)
        }
    }

    /// Whether formation data is available
    var hasFormationsData: Bool {
        !formations.isEmpty
    }

    /// Whether categories data is available
    var hasCategoriesData: Bool {
        !categories.isEmpty
    }

    /// Highlighted formations (first 3) for home screen
    var highlightedFormations: [Formation] {
        Array(formations.prefix(3))
    }

    /// Sets the category filter and returns true (for navigation chaining)
    @discardableResult
    func setSelectedCategory(_ category: FormationCategory?) -> Bool {
        selectedCategoryFilter = category
        return true
    }

    // MARK: - Initialization

    private init(dataRepository: AppDataRepository = .shared) {
        self.dataRepository = dataRepository
    }

    /// For testing: create with custom data repository
    static func createForTesting(dataRepository: AppDataRepository) -> FormationsRepository {
        return FormationsRepository(dataRepository: dataRepository)
    }

    // MARK: - Actions

    /// Fetches formations if needed - data is already preloaded by AppDataRepository
    @MainActor
    func fetchIfNeeded() async {
        // Data is already preloaded by AppDataRepository during splash
        // Nothing to do here
    }

    /// Fetches categories if needed - data is already preloaded by AppDataRepository
    @MainActor
    func fetchCategoriesIfNeeded() async {
        // Data is already preloaded by AppDataRepository during splash
        // Nothing to do here
    }

    /// Refreshes data from API (for pull-to-refresh)
    @MainActor
    func refresh() async {
        await dataRepository.refresh()
    }

    /// Clears the category filter
    func clearFilter() {
        selectedCategoryFilter = nil
    }

    /// Finds a formation by slug
    func formation(bySlug slug: String) -> Formation? {
        formations.first { $0.slug == slug }
    }

    /// Finds a formation by ID
    func formation(byId id: Int) -> Formation? {
        formations.first { $0.id == id }
    }

    /// Filters formations by category
    func formations(inCategory category: FormationCategory?) -> [Formation] {
        guard let category = category else {
            return formations
        }
        return formations.filter { $0.category?.id == category.id }
    }
}
