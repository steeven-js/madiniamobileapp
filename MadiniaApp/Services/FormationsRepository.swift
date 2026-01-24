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

    /// Current loading state
    private(set) var loadingState: LoadingState<[Formation]> = .idle

    /// Timestamp of last successful fetch
    private var lastFetchTime: Date?

    /// Cache duration in seconds (5 minutes)
    private let cacheDuration: TimeInterval = 300

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties

    /// Whether the cache is still valid
    var isCacheValid: Bool {
        guard let lastFetch = lastFetchTime else { return false }
        return Date().timeIntervalSince(lastFetch) < cacheDuration
    }

    /// Whether data is available (either from cache or loaded)
    var hasData: Bool {
        !formations.isEmpty
    }

    /// Unique categories extracted from formations
    var categories: [FormationCategory] {
        let allCategories = formations.compactMap { $0.category }
        var seen = Set<Int>()
        return allCategories.filter { category in
            guard !seen.contains(category.id) else { return false }
            seen.insert(category.id)
            return true
        }.sorted { $0.name < $1.name }
    }

    /// Highlighted formations (first 3) for home screen
    var highlightedFormations: [Formation] {
        Array(formations.prefix(3))
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
        if hasData && isCacheValid {
            loadingState = .loaded(formations)
            return
        }

        // Don't start a new fetch if one is already in progress
        guard !loadingState.isLoading else { return }

        await fetchFormations()
    }

    /// Forces a fresh fetch from the API (for pull-to-refresh).
    @MainActor
    func refresh() async {
        // Reset cache timestamp to force refresh
        lastFetchTime = nil
        await fetchFormations()
    }

    /// Internal fetch method
    @MainActor
    private func fetchFormations() async {
        loadingState = .loading

        do {
            let fetchedFormations = try await apiService.fetchFormations()
            formations = fetchedFormations
            lastFetchTime = Date()
            loadingState = .loaded(fetchedFormations)
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Erreur inconnue")
        } catch {
            loadingState = .error("Erreur de chargement")
        }
    }

    /// Clears the cache (useful for logout or testing)
    func clearCache() {
        formations = []
        lastFetchTime = nil
        loadingState = .idle
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
