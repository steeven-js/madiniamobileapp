//
//  EventRegistration.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation

/// Model representing an event registration request to be sent to the API.
struct EventRegistrationRequest: Encodable {
    let eventId: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let company: String?
    let deviceUuid: String
    let enablePushReminder: Bool
    let enableCalendarReminder: Bool

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case company
        case deviceUuid = "device_uuid"
        case enablePushReminder = "enable_push_reminder"
        case enableCalendarReminder = "enable_calendar_reminder"
    }
}

/// Model representing an event registration received from the API.
struct EventRegistration: Codable, Identifiable, Hashable {
    let id: Int
    let eventId: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let company: String?
    let status: RegistrationStatus
    let statusLabel: String?
    let enablePushReminder: Bool
    let enableCalendarReminder: Bool
    let confirmedAt: Date?
    let createdAt: Date
    let event: EventSummary?

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

/// Registration status enum
enum RegistrationStatus: String, Codable, Hashable {
    case pending
    case confirmed
    case cancelled
    case attended

    var displayName: String {
        switch self {
        case .pending: return "En attente"
        case .confirmed: return "Confirmé"
        case .cancelled: return "Annulé"
        case .attended: return "Présent"
        }
    }
}

/// Lightweight event summary included in registration response
struct EventSummary: Codable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let startDate: Date
    let location: String?
    let eventType: EventType
}

// MARK: - API Response Types

/// Response for event registration creation
struct EventRegistrationResponse: Decodable {
    let success: Bool
    let message: String?
    let data: EventRegistration?
    let event: Event?
}

/// Response for fetching event registrations list
struct EventRegistrationsListResponse: Decodable {
    let success: Bool
    let data: [EventRegistration]
    let count: Int?
}

/// Response for event detail with registration info
struct EventDetailResponse: Decodable {
    let success: Bool
    let data: Event
    let related: [Event]?
    let isRegistered: Bool?
    let registration: EventRegistration?
}

/// Response for events list
struct EventsListResponse: Decodable {
    let success: Bool
    let data: [Event]
    let featured: [Event]?
    let count: Int?
}

// MARK: - Sample Data

extension EventRegistration {
    static let sample = EventRegistration(
        id: 1,
        eventId: 1,
        firstName: "Jean",
        lastName: "Dupont",
        email: "jean.dupont@example.com",
        phone: "0696123456",
        company: "Madin.IA",
        status: .confirmed,
        statusLabel: "Confirmé",
        enablePushReminder: true,
        enableCalendarReminder: true,
        confirmedAt: Date(),
        createdAt: Date(),
        event: EventSummary(
            id: 1,
            title: "Introduction à l'IA Générative",
            slug: "introduction-ia-generative",
            startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            location: nil,
            eventType: .webinaire
        )
    )
}
