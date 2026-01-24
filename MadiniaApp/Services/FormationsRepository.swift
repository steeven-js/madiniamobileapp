//
//  FormationsRepository.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation

/// Shared repository for formations data with caching.
/// Prevents redundant API calls when switching between views.
@Observable
final class FormationsRepository {
    // MARK: - Singleton

    /// Shared instance for app-wide access
    static let shared = FormationsRepository()

    // MARK: - State

    /// Cached formations data
    private(set) var formations: [Formation] = []

    /// Cached categories data
    private(set) var categories: [FormationCategory] = []

    /// Current loading state for formations
    private(set) var loadingState: LoadingState<[Formation]> = .idle

    /// Current loading state for categories
    private(set) var categoriesLoadingState: LoadingState<[FormationCategory]> = .idle

    /// Timestamp of last successful formations fetch
    private var lastFormationsFetchTime: Date?

    /// Timestamp of last successful categories fetch
    private var lastCategoriesFetchTime: Date?

    /// Cache duration in seconds (5 minutes)
    private let cacheDuration: TimeInterval = 300

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties

    /// Whether the formations cache is still valid
    var isFormationsCacheValid: Bool {
        guard let lastFetch = lastFormationsFetchTime else { return false }
        return Date().timeIntervalSince(lastFetch) < cacheDuration
    }

    /// Whether the categories cache is still valid
    var isCategoriesCacheValid: Bool {
        guard let lastFetch = lastCategoriesFetchTime else { return false }
        return Date().timeIntervalSince(lastFetch) < cacheDuration
    }

    /// Whether formation data is available (either from cache or loaded)
    var hasFormationsData: Bool {
        !formations.isEmpty
    }

    /// Whether categories data is available (either from cache or loaded)
    var hasCategoriesData: Bool {
        !categories.isEmpty
    }

    /// Highlighted formations (first 3) for home screen
    var highlightedFormations: [Formation] {
        Array(formations.prefix(3))
    }

    /// Currently selected category filter for formations tab (shared state)
    var selectedCategoryFilter: FormationCategory?

    /// Sets the category filter and returns true (for navigation chaining)
    @discardableResult
    func setSelectedCategory(_ category: FormationCategory?) -> Bool {
        selectedCategoryFilter = category
        return true
    }

    // MARK: - Initialization

    private init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    /// For testing: create with custom API service
    static func createForTesting(apiService: APIServiceProtocol) -> FormationsRepository {
        let repo = FormationsRepository(apiService: apiService)
        return repo
    }

    // MARK: - Actions

    /// Fetches formations if cache is empty or expired.
    /// Returns immediately if valid cached data exists.
    @MainActor
    func fetchIfNeeded() async {
        // Return immediately if we have valid cached data
        if hasFormationsData && isFormationsCacheValid {
            loadingState = .loaded(formations)
            return
        }

        // Don't start a new fetch if one is already in progress
        guard !loadingState.isLoading else { return }

        await fetchFormations()
    }

    /// Fetches categories if cache is empty or expired.
    /// Returns immediately if valid cached data exists.
    @MainActor
    func fetchCategoriesIfNeeded() async {
        // Return immediately if we have valid cached data
        if hasCategoriesData && isCategoriesCacheValid {
            categoriesLoadingState = .loaded(categories)
            return
        }

        // Don't start a new fetch if one is already in progress
        guard !categoriesLoadingState.isLoading else { return }

        await fetchCategories()
    }

    /// Forces a fresh fetch from the API (for pull-to-refresh).
    @MainActor
    func refresh() async {
        // Reset cache timestamps to force refresh
        lastFormationsFetchTime = nil
        lastCategoriesFetchTime = nil
        await fetchFormations()
        await fetchCategories()
    }

    /// Internal fetch method for formations
    @MainActor
    private func fetchFormations() async {
        loadingState = .loading

        do {
            let fetchedFormations = try await apiService.fetchFormations()
            formations = fetchedFormations
            lastFormationsFetchTime = Date()
            loadingState = .loaded(fetchedFormations)
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Erreur inconnue")
        } catch {
            loadingState = .error("Erreur de chargement")
        }
    }

    /// Internal fetch method for categories
    @MainActor
    private func fetchCategories() async {
        categoriesLoadingState = .loading

        do {
            let fetchedCategories = try await apiService.fetchCategories()
            categories = fetchedCategories
            lastCategoriesFetchTime = Date()
            categoriesLoadingState = .loaded(fetchedCategories)
        } catch let error as APIError {
            categoriesLoadingState = .error(error.errorDescription ?? "Erreur inconnue")
        } catch {
            categoriesLoadingState = .error("Erreur de chargement des catégories")
        }
    }

    /// Clears the cache (useful for logout or testing)
    func clearCache() {
        formations = []
        categories = []
        lastFormationsFetchTime = nil
        lastCategoriesFetchTime = nil
        loadingState = .idle
        categoriesLoadingState = .idle
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
