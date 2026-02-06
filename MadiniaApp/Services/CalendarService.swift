//
//  CalendarService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import EventKit
import Foundation

/// Service for integrating with iOS Calendar (EventKit).
/// Handles adding and removing event reminders to the user's calendar.
@Observable
final class CalendarService {
    /// Shared singleton instance
    static let shared = CalendarService()

    /// EventKit event store
    private let eventStore = EKEventStore()

    /// Current authorization status
    private(set) var authorizationStatus: EKAuthorizationStatus = .notDetermined

    /// Whether calendar access is authorized
    var isAuthorized: Bool {
        authorizationStatus == .fullAccess || authorizationStatus == .authorized
    }

    // MARK: - Initialization

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Checks the current calendar authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    /// Requests calendar access from the user
    /// - Returns: Whether access was granted
    @MainActor
    func requestAccess() async -> Bool {
        do {
            // iOS 17+ uses requestFullAccessToEvents
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                authorizationStatus = granted ? .fullAccess : .denied
                return granted
            } else {
                // Fallback for iOS 16
                let granted = try await eventStore.requestAccess(to: .event)
                authorizationStatus = granted ? .authorized : .denied
                return granted
            }
        } catch {
            print("Calendar access request failed: \(error)")
            authorizationStatus = .denied
            return false
        }
    }

    // MARK: - Event Management

    /// Adds an event to the user's calendar
    /// - Parameters:
    ///   - title: Event title
    ///   - startDate: Event start date
    ///   - endDate: Event end date (optional, defaults to 1 hour after start)
    ///   - location: Event location (optional)
    ///   - notes: Event notes/description (optional)
    ///   - url: Event URL for online meetings (optional)
    ///   - reminder: Minutes before event to trigger alarm (default: 15 minutes)
    /// - Returns: The calendar event identifier for later removal
    /// - Throws: CalendarError if the operation fails
    func addEventToCalendar(
        title: String,
        startDate: Date,
        endDate: Date?,
        location: String?,
        notes: String?,
        url: URL?,
        reminder: Int = 15
    ) async throws -> String {
        // Verify authorization
        if !isAuthorized {
            let granted = await requestAccess()
            guard granted else {
                throw CalendarError.accessDenied
            }
        }

        // Create calendar event
        let calendarEvent = EKEvent(eventStore: eventStore)
        calendarEvent.title = title
        calendarEvent.startDate = startDate
        calendarEvent.endDate = endDate ?? Calendar.current.date(byAdding: .hour, value: 1, to: startDate)
        calendarEvent.location = location
        calendarEvent.notes = notes
        calendarEvent.url = url
        calendarEvent.calendar = eventStore.defaultCalendarForNewEvents

        // Add alarm/reminder
        let alarm = EKAlarm(relativeOffset: TimeInterval(-reminder * 60))
        calendarEvent.addAlarm(alarm)

        // Save the event
        do {
            try eventStore.save(calendarEvent, span: .thisEvent)
            return calendarEvent.eventIdentifier
        } catch {
            throw CalendarError.saveFailed(error.localizedDescription)
        }
    }

    /// Adds a Madin.IA event to the calendar
    /// - Parameters:
    ///   - event: The Madin.IA event to add
    ///   - reminder: Minutes before event to trigger alarm (default: 15)
    /// - Returns: The calendar event identifier
    func addEventToCalendar(_ event: Event, reminder: Int = 15) async throws -> String {
        var notes = "Événement Madin.IA\n"
        if let description = event.shortDescription ?? event.description {
            notes += "\n\(description)"
        }
        if let meetingUrl = event.meetingUrl {
            notes += "\n\nLien de connexion: \(meetingUrl)"
        }

        let url: URL? = event.meetingUrl.flatMap { URL(string: $0) }

        return try await addEventToCalendar(
            title: "[\(event.eventType.displayName)] \(event.title)",
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            notes: notes,
            url: url,
            reminder: reminder
        )
    }

    /// Removes an event from the calendar
    /// - Parameter identifier: The calendar event identifier
    /// - Throws: CalendarError if the operation fails
    func removeEventFromCalendar(identifier: String) async throws {
        guard isAuthorized else {
            throw CalendarError.accessDenied
        }

        guard let event = eventStore.event(withIdentifier: identifier) else {
            // Event might have been deleted by user - not an error
            return
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            throw CalendarError.deleteFailed(error.localizedDescription)
        }
    }

    /// Checks if an event exists in the calendar
    /// - Parameter identifier: The calendar event identifier
    /// - Returns: Whether the event exists
    func eventExists(identifier: String) -> Bool {
        guard isAuthorized else { return false }
        return eventStore.event(withIdentifier: identifier) != nil
    }
}

// MARK: - Calendar Errors

enum CalendarError: LocalizedError {
    case accessDenied
    case saveFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "L'accès au calendrier n'est pas autorisé. Veuillez l'activer dans les réglages."
        case .saveFailed(let message):
            return "Impossible d'ajouter l'événement au calendrier: \(message)"
        case .deleteFailed(let message):
            return "Impossible de supprimer l'événement du calendrier: \(message)"
        }
    }
}
