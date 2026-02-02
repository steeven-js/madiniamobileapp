//
//  AppDataRepository.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation
import Observation

/// Centralized repository for all app data with preloading support.
/// Handles formations, categories, services, and articles with local caching.
/// Used during splash screen to preload data before showing main content.
@Observable
final class AppDataRepository {
    // MARK: - Singleton

    static let shared = AppDataRepository()

    // MARK: - Data State

    /// All formations
    private(set) var formations: [Formation] = []

    /// All categories
    private(set) var categories: [FormationCategory] = []

    /// All services
    private(set) var services: [Service] = []

    /// All articles
    private(set) var articles: [Article] = []

    /// Overall loading state
    private(set) var isLoading = false

    /// Whether initial load has completed
    private(set) var isInitialized = false

    /// Error message if loading failed
    private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol
    private let cacheService: CacheService

    // MARK: - Computed Properties

    /// Whether data is available (from cache or API)
    var hasData: Bool {
        !formations.isEmpty || !categories.isEmpty || !services.isEmpty
    }

    /// Highlighted formations for home screen
    var highlightedFormations: [Formation] {
        Array(formations.prefix(3))
    }

    /// Most viewed formations (sorted by viewsCount, max 5)
    var mostViewedFormations: [Formation] {
        let sorted = self.formations.sorted(by: { ($0.viewsCount ?? 0) > ($1.viewsCount ?? 0) })
        return Array(sorted.prefix(5))
    }

    /// Recent articles sorted by publication date (most recent first)
    var recentArticles: [Article] {
        articles.sorted { article1, article2 in
            guard let date1 = parseDate(article1.publishedAt),
                  let date2 = parseDate(article2.publishedAt) else {
                return false
            }
            return date1 > date2
        }
    }

    /// Parses an ISO 8601 date string
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }

    // MARK: - Initialization

    private init(
        apiService: APIServiceProtocol = APIService.shared,
        cacheService: CacheService = .shared
    ) {
        self.apiService = apiService
        self.cacheService = cacheService

        // Load cached data immediately on init
        loadFromCache()
    }

    // MARK: - Cache Loading

    /// Loads all data from local cache synchronously
    private func loadFromCache() {
        if let cached = cacheService.loadFormations() {
            formations = cached
        }
        if let cached = cacheService.loadCategories() {
            categories = cached
        }
        if let cached = cacheService.loadServices() {
            services = cached
        }
        if let cached = cacheService.loadArticles() {
            articles = cached
        }

        #if DEBUG
        print("AppDataRepository: Loaded from cache - \(formations.count) formations, \(categories.count) categories, \(services.count) services, \(articles.count) articles")
        #endif
    }

    // MARK: - Preloading (Splash Screen)

    /// Preloads all data from API. Called during splash screen.
    /// Returns when data is ready (either from API or cache as fallback).
    @MainActor
    func preloadAllData() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Fetch all data in parallel (including articles now)
            async let formationsTask = apiService.fetchFormations()
            async let categoriesTask = apiService.fetchCategories()
            async let servicesTask = apiService.fetchServices()
            async let articlesTask = apiService.fetchArticles()

            let (loadedFormations, loadedCategories, loadedServices, loadedArticles) = try await (
                formationsTask,
                categoriesTask,
                servicesTask,
                articlesTask
            )

            // Update data
            formations = loadedFormations
            categories = loadedCategories
            services = loadedServices
            articles = loadedArticles

            // Save to cache in background
            Task.detached { [weak self] in
                self?.cacheService.saveFormations(loadedFormations)
                self?.cacheService.saveCategories(loadedCategories)
                self?.cacheService.saveServices(loadedServices)
                self?.cacheService.saveArticles(loadedArticles)
            }

            #if DEBUG
            print("AppDataRepository: Preloaded from API - \(formations.count) formations, \(categories.count) categories, \(services.count) services, \(articles.count) articles")
            #endif

        } catch {
            // If API fails but we have cached data, continue with cache
            if hasData {
                #if DEBUG
                print("AppDataRepository: API failed, using cached data - \(error)")
                #endif
            } else {
                errorMessage = error.localizedDescription
                #if DEBUG
                print("AppDataRepository: Preload failed - \(error)")
                #endif
            }
        }

        isLoading = false
        isInitialized = true
    }

    // MARK: - Refresh (Pull to Refresh)

    /// Refreshes all data from API. Used for pull-to-refresh.
    @MainActor
    func refresh() async {
        guard !isLoading else { return }

        isLoading = true

        do {
            async let formationsTask = apiService.fetchFormations()
            async let categoriesTask = apiService.fetchCategories()
            async let servicesTask = apiService.fetchServices()
            async let articlesTask = apiService.fetchArticles()

            let (loadedFormations, loadedCategories, loadedServices, loadedArticles) = try await (
                formationsTask,
                categoriesTask,
                servicesTask,
                articlesTask
            )

            formations = loadedFormations
            categories = loadedCategories
            services = loadedServices
            articles = loadedArticles

            // Save to cache
            Task.detached { [weak self] in
                self?.cacheService.saveFormations(loadedFormations)
                self?.cacheService.saveCategories(loadedCategories)
                self?.cacheService.saveServices(loadedServices)
                self?.cacheService.saveArticles(loadedArticles)
            }

        } catch {
            #if DEBUG
            print("AppDataRepository: Refresh failed - \(error)")
            #endif
        }

        isLoading = false
    }

    // MARK: - Articles Helper

    /// Loads articles on demand (fallback if not preloaded)
    @MainActor
    func loadArticlesIfNeeded() async {
        guard articles.isEmpty else { return }

        do {
            let loadedArticles = try await apiService.fetchArticles()
            articles = loadedArticles
            cacheService.saveArticles(loadedArticles)
        } catch {
            #if DEBUG
            print("AppDataRepository: Failed to load articles - \(error)")
            #endif
        }
    }

    // MARK: - Helpers

    /// Finds a formation by slug
    func formation(bySlug slug: String) -> Formation? {
        formations.first { $0.slug == slug }
    }

    /// Finds a formation by ID
    func formation(byId id: Int) -> Formation? {
        formations.first { $0.id == id }
    }

    /// Filters formations by category
    func filteredFormations(byCategory category: FormationCategory?) -> [Formation] {
        guard let category = category else { return self.formations }
        return self.formations.filter { $0.category?.id == category.id }
    }
}
