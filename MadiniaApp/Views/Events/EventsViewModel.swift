//
//  EventsViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation

/// ViewModel for the Events screen, managing event list and loading state.
@Observable
final class EventsViewModel {
    // MARK: - Dependencies

    private let eventsService: EventsService
    private let dataRepository: AppDataRepository

    // MARK: - State

    /// Current loading state
    private(set) var loadingState: LoadingState<[Event]> = .idle

    /// Selected event type filter
    var selectedEventType: EventType?

    // MARK: - Computed Properties

    /// All loaded events (from cache via repository, or from service)
    var events: [Event] {
        // Prefer repository (cached) data, fallback to service
        if !dataRepository.events.isEmpty {
            return dataRepository.upcomingEvents
        }
        return eventsService.events
    }

    /// Featured events for carousel
    var featuredEvents: [Event] {
        // Prefer repository (cached) data, fallback to service
        if !dataRepository.featuredEvents.isEmpty {
            return dataRepository.featuredEvents.filter { !$0.isPast }
        }
        return eventsService.featuredEvents
    }

    /// Filtered events based on selected type
    var filteredEvents: [Event] {
        if let type = selectedEventType {
            return events.filter { $0.eventType == type }
        }
        return events
    }

    /// Whether there are any events
    var hasEvents: Bool {
        !events.isEmpty
    }

    /// Whether there are featured events
    var hasFeaturedEvents: Bool {
        !featuredEvents.isEmpty
    }

    // MARK: - Initialization

    init(eventsService: EventsService = .shared, dataRepository: AppDataRepository = .shared) {
        self.eventsService = eventsService
        self.dataRepository = dataRepository
    }

    // MARK: - Actions

    /// Loads events from the API
    @MainActor
    func loadEvents() async {
        // If already loading or loaded, skip
        if case .loading = loadingState { return }

        // Check if we have cached data from repository
        if !dataRepository.events.isEmpty {
            loadingState = .loaded(events)
            // Fetch registrations in background
            await eventsService.fetchRegistrations()
            return
        }

        if events.isEmpty {
            loadingState = .loading
        }

        await eventsService.fetchEvents()

        if let error = eventsService.lastError {
            if events.isEmpty {
                loadingState = .error(error.localizedDescription)
            }
        } else {
            loadingState = .loaded(events)
        }
    }

    /// Refreshes events from the API (for pull-to-refresh)
    @MainActor
    func refresh() async {
        await eventsService.fetchEvents()
        await eventsService.fetchRegistrations()
        loadingState = .loaded(events)
    }
}
