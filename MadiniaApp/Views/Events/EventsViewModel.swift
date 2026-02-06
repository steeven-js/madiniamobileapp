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

    // MARK: - State

    /// Current loading state
    private(set) var loadingState: LoadingState<[Event]> = .idle

    /// Selected event type filter
    var selectedEventType: EventType?

    // MARK: - Computed Properties

    /// All loaded events
    var events: [Event] {
        eventsService.events
    }

    /// Featured events for carousel
    var featuredEvents: [Event] {
        eventsService.featuredEvents
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

    init(eventsService: EventsService = .shared) {
        self.eventsService = eventsService
    }

    // MARK: - Actions

    /// Loads events from the API
    @MainActor
    func loadEvents() async {
        // If already loading or loaded, skip
        if case .loading = loadingState { return }

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
