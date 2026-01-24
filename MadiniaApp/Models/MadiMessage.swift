//
//  MadiMessage.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Represents a message in the Madi chat conversation.
struct MadiMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let formationRecommendation: FormationRecommendation?

    init(
        id: UUID = UUID(),
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date(),
        formationRecommendation: FormationRecommendation? = nil
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.formationRecommendation = formationRecommendation
    }
}

/// Represents a formation recommendation from Madi.
struct FormationRecommendation: Equatable {
    let formationId: Int
    let formationSlug: String
    let formationTitle: String
}

// MARK: - Sample Data

extension MadiMessage {
    static let welcomeMessage = MadiMessage(
        content: "Bonjour ! Je suis Madi, votre coach IA. Je suis là pour vous aider à trouver la formation idéale pour atteindre vos objectifs. Que souhaitez-vous apprendre ?",
        isFromUser: false
    )

    static let samples: [MadiMessage] = [
        welcomeMessage,
        MadiMessage(
            content: "Je veux apprendre à utiliser l'IA dans mon travail",
            isFromUser: true
        ),
        MadiMessage(
            content: "Excellent choix ! L'IA transforme de nombreux secteurs. Je vous recommande de commencer par notre pack Starter qui vous donnera les bases essentielles.",
            isFromUser: false,
            formationRecommendation: FormationRecommendation(
                formationId: 1,
                formationSlug: "starter-ia",
                formationTitle: "Pack Starter IA"
            )
        )
    ]
}
