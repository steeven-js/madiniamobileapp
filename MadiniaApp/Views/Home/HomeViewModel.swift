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

    /// Events service for loading upcoming events
    private let eventsService: EventsService

    // MARK: - Events State

    /// Upcoming events for home display
    private(set) var upcomingEvents: [Event] = []

    /// Whether events are loading
    private(set) var isLoadingEvents = false

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
    init(dataRepository: AppDataRepository = .shared, eventsService: EventsService = .shared) {
        self.dataRepository = dataRepository
        self.eventsService = eventsService
    }

    // MARK: - Actions

    /// Called when view appears - loads formations and events
    @MainActor
    func loadFormations() async {
        // Data is already preloaded by AppDataRepository during splash
        // Load events separately
        await loadEvents()
    }

    /// Loads upcoming events for home display
    @MainActor
    func loadEvents() async {
        isLoadingEvents = true
        await eventsService.fetchEvents()
        // Get up to 5 upcoming events for home carousel
        upcomingEvents = Array(eventsService.upcomingEvents.prefix(5))
        isLoadingEvents = false
    }

    /// Refreshes data from API (pull-to-refresh)
    @MainActor
    func retry() async {
        await dataRepository.refresh()
        await loadEvents()
    }
}
