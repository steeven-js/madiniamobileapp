//
//  Formation.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Represents a training formation offered by Madinia.
/// Conforms to Codable for JSON parsing, Identifiable for SwiftUI lists,
/// and Hashable for comparison and use in sets.
struct Formation: Codable, Identifiable, Hashable {
    /// Unique identifier for the formation
    let id: Int

    /// Title of the formation
    let title: String

    /// URL-friendly slug
    let slug: String

    /// Short description for cards and lists
    let shortDescription: String?

    /// Formatted duration (e.g., "14 heures")
    let duration: String

    /// Duration in hours
    let durationHours: Int?

    /// Level code (e.g., "debutant", "intermediaire", "avance")
    let level: String

    /// Human-readable level label (e.g., "Débutant", "Intermédiaire", "Avancé")
    let levelLabel: String

    /// Whether the formation is certified
    let certification: Bool?

    /// Certification label (e.g., "Certifiante", "Non certifiante")
    let certificationLabel: String?

    /// URL to the formation image
    let imageUrl: String?

    /// Category information
    let category: FormationCategory?

    // MARK: - Detail-only fields (nil in list responses)

    /// Full description (HTML)
    let description: String?

    /// Learning objectives (HTML)
    let objectives: String?

    /// Prerequisites (HTML)
    let prerequisites: String?

    /// Program content (HTML)
    let program: String?

    /// Target audience description
    let targetAudience: String?

    /// Training methods description
    let trainingMethods: String?

    /// URL to PDF file
    let pdfFileUrl: String?

    /// Number of views
    let viewsCount: Int?

    /// Publication date
    let publishedAt: String?
}

/// Represents a formation category
struct FormationCategory: Codable, Hashable {
    let id: Int
    let name: String
    let slug: String?
    let color: String?
    let icon: String?
}

// MARK: - Preview/Mock Data

extension Formation {
    /// Sample formation for SwiftUI previews and testing
    static let sample = Formation(
        id: 1,
        title: "Starter Pack - IA Générative",
        slug: "starter-pack-ia-generative",
        shortDescription: "Découvrez les fondamentaux de l'IA générative et apprenez à utiliser les outils modernes.",
        duration: "14 heures",
        durationHours: 14,
        level: "debutant",
        levelLabel: "Débutant",
        certification: false,
        certificationLabel: "Non certifiante",
        imageUrl: nil,
        category: FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", color: "#8B5CF6", icon: nil),
        description: "Découvrez les fondamentaux de l'IA générative.",
        objectives: nil,
        prerequisites: nil,
        program: nil,
        targetAudience: nil,
        trainingMethods: nil,
        pdfFileUrl: nil,
        viewsCount: nil,
        publishedAt: nil
    )

    /// Array of sample formations for previews
    static let samples: [Formation] = [
        Formation(
            id: 1,
            title: "Starter Pack - IA Générative",
            slug: "starter-pack-ia-generative",
            shortDescription: "Découvrez les fondamentaux de l'IA générative.",
            duration: "14 heures",
            durationHours: 14,
            level: "debutant",
            levelLabel: "Débutant",
            certification: false,
            certificationLabel: "Non certifiante",
            imageUrl: nil,
            category: FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", color: "#8B5CF6", icon: nil),
            description: nil, objectives: nil, prerequisites: nil, program: nil,
            targetAudience: nil, trainingMethods: nil, pdfFileUrl: nil, viewsCount: nil, publishedAt: nil
        ),
        Formation(
            id: 2,
            title: "Performer Pack - IA Avancée",
            slug: "performer-pack-ia-avancee",
            shortDescription: "Maîtrisez les techniques avancées de prompt engineering.",
            duration: "21 heures",
            durationHours: 21,
            level: "intermediaire",
            levelLabel: "Intermédiaire",
            certification: false,
            certificationLabel: "Non certifiante",
            imageUrl: nil,
            category: FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", color: "#8B5CF6", icon: nil),
            description: nil, objectives: nil, prerequisites: nil, program: nil,
            targetAudience: nil, trainingMethods: nil, pdfFileUrl: nil, viewsCount: nil, publishedAt: nil
        ),
        Formation(
            id: 3,
            title: "Master Pack - Expert IA",
            slug: "master-pack-expert-ia",
            shortDescription: "Devenez expert en IA et automatisation.",
            duration: "35 heures",
            durationHours: 35,
            level: "avance",
            levelLabel: "Avancé",
            certification: true,
            certificationLabel: "Certifiante",
            imageUrl: nil,
            category: FormationCategory(id: 2, name: "Expert", slug: "expert", color: "#EF4444", icon: nil),
            description: nil, objectives: nil, prerequisites: nil, program: nil,
            targetAudience: nil, trainingMethods: nil, pdfFileUrl: nil, viewsCount: nil, publishedAt: nil
        )
    ]
}
