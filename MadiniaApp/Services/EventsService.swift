//
//  EventsService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation
import SwiftUI
import UIKit

/// Service for managing events and registrations.
/// Handles fetching events, registering for events, and tracking registrations.
@Observable
final class EventsService {
    /// Shared singleton instance
    static let shared = EventsService()

    // MARK: - State

    /// All upcoming events
    private(set) var events: [Event] = []

    /// Featured events for carousel
    private(set) var featuredEvents: [Event] = []

    /// User's registrations
    private(set) var registrations: [EventRegistration] = []

    /// Whether data is currently loading
    private(set) var isLoading = false

    /// Last error that occurred
    private(set) var lastError: Error?

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Local Storage Keys

    private let registrationsKey = "event_registrations"
    private let calendarEventIdsKey = "calendar_event_ids"

    // MARK: - Initialization

    private init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
        loadLocalRegistrations()
    }

    // MARK: - Device UUID

    /// Gets the device UUID for tracking registrations
    var deviceUUID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    // MARK: - Computed Properties

    /// Upcoming events (not past)
    var upcomingEvents: [Event] {
        events.filter { !$0.isPast }
    }

    /// Events filtered by type
    func events(ofType type: EventType) -> [Event] {
        events.filter { $0.eventType == type }
    }

    /// Registered event IDs for quick lookup
    private var registeredEventIds: Set<Int> {
        Set(registrations.map { $0.eventId })
    }

    /// Checks if the user is registered for an event
    func isRegistered(eventId: Int) -> Bool {
        registeredEventIds.contains(eventId)
    }

    /// Gets the registration for a specific event
    func registration(for eventId: Int) -> EventRegistration? {
        registrations.first { $0.eventId == eventId }
    }

    // MARK: - API Methods

    /// Fetches all events from the API
    @MainActor
    func fetchEvents() async {
        isLoading = true
        lastError = nil

        do {
            let response = try await apiService.fetchEvents()
            events = response.events
            featuredEvents = response.featured
            isLoading = false
        } catch {
            lastError = error
            isLoading = false
            print("Failed to fetch events: \(error)")
        }
    }

    /// Fetches a single event by slug
    @MainActor
    func fetchEvent(slug: String) async -> (event: Event, related: [Event], isRegistered: Bool)? {
        do {
            let result = try await apiService.fetchEvent(slug: slug, deviceUUID: deviceUUID)
            return result
        } catch {
            lastError = error
            print("Failed to fetch event: \(error)")
            return nil
        }
    }

    /// Fetches user's registrations from the API
    @MainActor
    func fetchRegistrations() async {
        do {
            registrations = try await apiService.fetchEventRegistrations(deviceUUID: deviceUUID)
            saveLocalRegistrations()
        } catch {
            print("Failed to fetch registrations: \(error)")
            // Keep local registrations as fallback
        }
    }

    /// Registers for an event
    /// - Parameters:
    ///   - event: The event to register for
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    ///   - email: User's email
    ///   - phone: User's phone (optional)
    ///   - company: User's company (optional)
    ///   - enablePushReminder: Whether to enable push notification reminder
    ///   - enableCalendarReminder: Whether to add to calendar
    /// - Returns: The created registration
    @MainActor
    func registerForEvent(
        _ event: Event,
        firstName: String,
        lastName: String,
        email: String,
        phone: String?,
        company: String?,
        enablePushReminder: Bool,
        enableCalendarReminder: Bool
    ) async throws -> EventRegistration {
        let request = EventRegistrationRequest(
            eventId: event.id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            company: company,
            deviceUuid: deviceUUID,
            enablePushReminder: enablePushReminder,
            enableCalendarReminder: enableCalendarReminder
        )

        let registration = try await apiService.registerForEvent(request)

        // Add to local registrations
        registrations.append(registration)
        saveLocalRegistrations()

        // Schedule push notification reminder if enabled
        if enablePushReminder {
            await scheduleEventReminder(for: event)
        }

        // Add to calendar if enabled
        if enableCalendarReminder {
            do {
                let calendarId = try await CalendarService.shared.addEventToCalendar(event)
                saveCalendarEventId(calendarId, for: event.id)
            } catch {
                print("Failed to add event to calendar: \(error)")
                // Don't throw - registration was successful
            }
        }

        return registration
    }

    /// Cancels a registration
    @MainActor
    func cancelRegistration(_ registration: EventRegistration) async throws {
        try await apiService.cancelEventRegistration(registrationId: registration.id, deviceUUID: deviceUUID)

        // Remove from local registrations
        registrations.removeAll { $0.id == registration.id }
        saveLocalRegistrations()

        // Remove from calendar if added
        if let calendarId = getCalendarEventId(for: registration.eventId) {
            try? await CalendarService.shared.removeEventFromCalendar(identifier: calendarId)
            removeCalendarEventId(for: registration.eventId)
        }

        // Cancel push notification reminder
        cancelEventReminder(eventId: registration.eventId)
    }

    // MARK: - Local Storage

    private func loadLocalRegistrations() {
        if let data = UserDefaults.standard.data(forKey: registrationsKey),
           let decoded = try? JSONDecoder().decode([EventRegistration].self, from: data) {
            registrations = decoded
        }
    }

    private func saveLocalRegistrations() {
        if let encoded = try? JSONEncoder().encode(registrations) {
            UserDefaults.standard.set(encoded, forKey: registrationsKey)
        }
    }

    // MARK: - Calendar Event ID Storage

    private func getCalendarEventIds() -> [Int: String] {
        guard let data = UserDefaults.standard.data(forKey: calendarEventIdsKey),
              let dict = try? JSONDecoder().decode([Int: String].self, from: data) else {
            return [:]
        }
        return dict
    }

    private func saveCalendarEventId(_ calendarId: String, for eventId: Int) {
        var ids = getCalendarEventIds()
        ids[eventId] = calendarId
        if let encoded = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(encoded, forKey: calendarEventIdsKey)
        }
    }

    private func getCalendarEventId(for eventId: Int) -> String? {
        getCalendarEventIds()[eventId]
    }

    private func removeCalendarEventId(for eventId: Int) {
        var ids = getCalendarEventIds()
        ids.removeValue(forKey: eventId)
        if let encoded = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(encoded, forKey: calendarEventIdsKey)
        }
    }

    // MARK: - Push Notification Reminders

    private func scheduleEventReminder(for event: Event) async {
        // Use local notifications for event reminders
        let center = UNUserNotificationCenter.current()

        // Schedule reminder 1 hour before event
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: event.startDate) ?? event.startDate

        // Only schedule if in the future
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Rappel: \(event.title)"
        content.body = "L'événement commence dans 1 heure"
        content.sound = .default
        content.userInfo = [
            "type": "event",
            "eventId": event.id,
            "slug": event.slug
        ]

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "event_reminder_\(event.id)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule event reminder: \(error)")
        }
    }

    private func cancelEventReminder(eventId: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["event_reminder_\(eventId)"])
    }
}

// MARK: - UNUserNotificationCenter import

import UserNotifications
