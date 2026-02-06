//
//  Event.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation
import SwiftUI

/// Model representing an event from the API.
struct Event: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let shortDescription: String?
    let eventType: EventType
    let startDate: Date
    let endDate: Date?
    let location: String?
    let meetingUrl: String?
    let isOnline: Bool?
    let isHybrid: Bool?
    let maxParticipants: Int?
    let currentParticipants: Int?
    let availableSpots: Int?
    let isFull: Bool?
    let imageUrl: String?
    let isFeatured: Bool
    let tags: [String]?

    // Detail-only fields
    let description: String?
    let viewsCount: Int?
}

// MARK: - Event Type

enum EventType: String, Codable, CaseIterable, Hashable {
    case webinaire
    case atelier
    case meetup
    case conference

    var displayName: String {
        switch self {
        case .webinaire: return "Webinaire"
        case .atelier: return "Atelier"
        case .meetup: return "Meetup"
        case .conference: return "Conférence"
        }
    }

    var icon: String {
        switch self {
        case .webinaire: return "video.fill"
        case .atelier: return "hammer.fill"
        case .meetup: return "person.3.fill"
        case .conference: return "mic.fill"
        }
    }

    var color: Color {
        switch self {
        case .webinaire: return Color(hex: "#8B5CF6") ?? .purple
        case .atelier: return Color(hex: "#F59E0B") ?? .orange
        case .meetup: return Color(hex: "#10B981") ?? .green
        case .conference: return Color(hex: "#3B82F6") ?? .blue
        }
    }
}

// MARK: - Computed Properties

extension Event {
    /// Formatted start date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: startDate).capitalized
    }

    /// Formatted time for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH:mm"

        var time = formatter.string(from: startDate)
        if let endDate = endDate {
            time += " - \(formatter.string(from: endDate))"
        }
        return time
    }

    /// Short formatted date (for cards)
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: startDate)
    }

    /// Location display text
    var locationDisplay: String {
        if isOnline == true && location == nil {
            return "En ligne"
        } else if isHybrid == true {
            return "\(location ?? "") + En ligne"
        } else {
            return location ?? "Lieu à confirmer"
        }
    }

    /// Whether the event is in the past
    var isPast: Bool {
        startDate < Date()
    }

    /// Whether registration is available
    var canRegister: Bool {
        !isPast && !(isFull ?? false)
    }

    /// Spots remaining text
    var spotsRemainingText: String? {
        guard let available = availableSpots, let max = maxParticipants else {
            return nil
        }
        if available == 0 {
            return "Complet"
        }
        return "\(available)/\(max) places"
    }
}

// MARK: - Sample Data

extension Event {
    /// Sample event for previews
    static let sample = Event(
        id: 1,
        title: "Introduction à l'IA Générative",
        slug: "introduction-ia-generative",
        shortDescription: "Découvrez les bases de l'IA générative et ses applications concrètes dans le monde professionnel.",
        eventType: .webinaire,
        startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)!,
        location: nil,
        meetingUrl: "https://meet.google.com/abc-defg-hij",
        isOnline: true,
        isHybrid: false,
        maxParticipants: 50,
        currentParticipants: 32,
        availableSpots: 18,
        isFull: false,
        imageUrl: nil,
        isFeatured: true,
        tags: ["IA", "Débutant", "Gratuit"],
        description: "Rejoignez-nous pour une introduction complète à l'IA générative. Ce webinaire couvrira les fondamentaux, les outils disponibles et les cas d'usage professionnels.",
        viewsCount: 156
    )

    /// Sample events for previews
    static let samples: [Event] = [
        sample,
        Event(
            id: 2,
            title: "Atelier Prompt Engineering",
            slug: "atelier-prompt-engineering",
            shortDescription: "Apprenez à rédiger des prompts efficaces pour ChatGPT et autres LLMs.",
            eventType: .atelier,
            startDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            endDate: Calendar.current.date(byAdding: .hour, value: 3, to: Calendar.current.date(byAdding: .day, value: 14, to: Date())!)!,
            location: "Fort-de-France, Martinique",
            meetingUrl: nil,
            isOnline: false,
            isHybrid: false,
            maxParticipants: 20,
            currentParticipants: 18,
            availableSpots: 2,
            isFull: false,
            imageUrl: nil,
            isFeatured: true,
            tags: ["ChatGPT", "Prompts", "Présentiel"],
            description: nil,
            viewsCount: 89
        ),
        Event(
            id: 3,
            title: "Meetup IA Martinique",
            slug: "meetup-ia-martinique",
            shortDescription: "Rencontrez la communauté IA locale et partagez vos expériences.",
            eventType: .meetup,
            startDate: Calendar.current.date(byAdding: .day, value: 21, to: Date())!,
            endDate: nil,
            location: "Le Lamentin, Martinique",
            meetingUrl: "https://zoom.us/j/123456789",
            isOnline: false,
            isHybrid: true,
            maxParticipants: nil,
            currentParticipants: 45,
            availableSpots: nil,
            isFull: false,
            imageUrl: nil,
            isFeatured: false,
            tags: ["Networking", "Communauté"],
            description: nil,
            viewsCount: 234
        ),
        Event(
            id: 4,
            title: "Conférence IA & Business",
            slug: "conference-ia-business",
            shortDescription: "Comment l'IA transforme les entreprises martiniquaises.",
            eventType: .conference,
            startDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .hour, value: 4, to: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)!,
            location: "Palais des Congrès, Fort-de-France",
            meetingUrl: nil,
            isOnline: false,
            isHybrid: false,
            maxParticipants: 200,
            currentParticipants: 120,
            availableSpots: 80,
            isFull: false,
            imageUrl: nil,
            isFeatured: true,
            tags: ["Business", "Innovation", "Keynote"],
            description: nil,
            viewsCount: 567
        )
    ]
}
