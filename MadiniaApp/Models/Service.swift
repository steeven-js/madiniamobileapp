//
//  Service.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation

/// Represents a service offered by Madinia (conferences, audits, coaching).
/// Conforms to Codable for JSON parsing, Identifiable for SwiftUI lists,
/// and Hashable for comparison and use in sets.
struct Service: Codable, Identifiable, Hashable {
    /// Unique identifier for the service
    let id: Int

    /// Name of the service
    let name: String

    /// URL-friendly slug
    let slug: String

    /// Short description for cards and lists
    let shortDescription: String?

    /// Full description (HTML)
    let description: String?

    /// Icon name (heroicon format)
    let icon: String?

    /// URL to the service image
    let imageUrl: String?

    /// Relative href for navigation
    let href: String?
}

// MARK: - Preview/Mock Data

extension Service {
    /// Sample service for SwiftUI previews and testing
    static let sample = Service(
        id: 1,
        name: "Conférences IA",
        slug: "conference-ia",
        shortDescription: "Sensibilisez vos équipes à l'intelligence artificielle",
        description: nil,
        icon: "heroicon-o-presentation-chart-line",
        imageUrl: "https://rrgxotnrwmjqnaugllks.supabase.co/storage/v1/object/public/formations/services/images/18e73051-e22e-457c-b380-0b859e4a3122.webp",
        href: "/services/conference-ia"
    )

    /// Array of sample services for previews
    static let samples: [Service] = [
        Service(
            id: 1,
            name: "Conférences IA",
            slug: "conference-ia",
            shortDescription: "Sensibilisez vos équipes à l'intelligence artificielle",
            description: nil,
            icon: "heroicon-o-presentation-chart-line",
            imageUrl: nil,
            href: "/services/conference-ia"
        ),
        Service(
            id: 2,
            name: "Audit & Conseils IA",
            slug: "audit-et-conseils-ia",
            shortDescription: "Optimisez vos processus avec l'IA",
            description: nil,
            icon: "heroicon-o-clipboard-document-check",
            imageUrl: nil,
            href: "/services/audit-et-conseils-ia"
        ),
        Service(
            id: 3,
            name: "Accompagnement Personnalisé",
            slug: "accompagnement-perso",
            shortDescription: "Un suivi sur mesure pour vos projets IA",
            description: nil,
            icon: "heroicon-o-user-group",
            imageUrl: nil,
            href: "/services/accompagnement-perso"
        )
    ]
}
