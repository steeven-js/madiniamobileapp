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

    /// Progress tracking service for recently viewed formations
    private let progressService: ProgressTrackingService

    /// Home preferences service for section customization
    private let preferencesService: HomePreferencesService

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

    /// Upcoming events for home display (from cached repository data)
    var upcomingEvents: [Event] {
        Array(dataRepository.upcomingEvents.prefix(5))
    }

    /// Recently viewed formations (for "Continue Learning" section)
    var recentlyViewedFormations: [Formation] {
        // Get formation IDs sorted by last viewed date
        let recentProgress = progressService.formationProgress.values
            .sorted { $0.lastViewedAt > $1.lastViewedAt }
            .prefix(5)

        // Map to actual formations from repository
        return recentProgress.compactMap { progress in
            dataRepository.formations.first { $0.id == progress.formationId }
        }
    }

    /// Visible sections based on user preferences
    var visibleSections: [HomeSection] {
        preferencesService.visibleSections
    }

    /// Check if a section should be displayed
    func isSectionVisible(_ section: HomeSection) -> Bool {
        preferencesService.isSectionVisible(section)
    }

    // MARK: - Initialization

    /// Creates a HomeViewModel with the specified dependencies
    init(
        dataRepository: AppDataRepository = .shared,
        progressService: ProgressTrackingService = .shared,
        preferencesService: HomePreferencesService = .shared
    ) {
        self.dataRepository = dataRepository
        self.progressService = progressService
        self.preferencesService = preferencesService
    }

    // MARK: - Actions

    /// Called when view appears - data is already preloaded by AppDataRepository
    @MainActor
    func loadFormations() async {
        // Data is already preloaded by AppDataRepository during splash
        // Nothing to do here - computed properties read from repository
    }

    /// Refreshes data from API (pull-to-refresh)
    @MainActor
    func retry() async {
        await dataRepository.refresh()
    }
}
