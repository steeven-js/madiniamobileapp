//
//  MadiMessage.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

// MARK: - Message Type

/// Types of messages Madi can send
enum MadiMessageType: Codable, Equatable {
    case text
    case formationRecommendation
    case quickActions
    case quizStart
    case quizResult(score: Int, total: Int)

    // Custom coding for associated values
    enum CodingKeys: String, CodingKey {
        case type, score, total
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text": self = .text
        case "formationRecommendation": self = .formationRecommendation
        case "quickActions": self = .quickActions
        case "quizStart": self = .quizStart
        case "quizResult":
            let score = try container.decode(Int.self, forKey: .score)
            let total = try container.decode(Int.self, forKey: .total)
            self = .quizResult(score: score, total: total)
        default: self = .text
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text:
            try container.encode("text", forKey: .type)
        case .formationRecommendation:
            try container.encode("formationRecommendation", forKey: .type)
        case .quickActions:
            try container.encode("quickActions", forKey: .type)
        case .quizStart:
            try container.encode("quizStart", forKey: .type)
        case .quizResult(let score, let total):
            try container.encode("quizResult", forKey: .type)
            try container.encode(score, forKey: .score)
            try container.encode(total, forKey: .total)
        }
    }
}

// MARK: - Quick Action

/// Represents a quick action chip that users can tap
struct QuickAction: Identifiable, Codable, Equatable {
    let id: UUID
    let label: String
    let icon: String
    let actionType: MadiActionType

    init(id: UUID = UUID(), label: String, icon: String, actionType: MadiActionType) {
        self.id = id
        self.label = label
        self.icon = icon
        self.actionType = actionType
    }
}

/// Types of actions available from quick action chips
enum MadiActionType: Codable, Equatable {
    case startQuiz
    case showRecommendations
    case askAboutFormation(slug: String)
    case showFavorites
    case clearHistory

    enum CodingKeys: String, CodingKey {
        case type, slug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "startQuiz": self = .startQuiz
        case "showRecommendations": self = .showRecommendations
        case "askAboutFormation":
            let slug = try container.decode(String.self, forKey: .slug)
            self = .askAboutFormation(slug: slug)
        case "showFavorites": self = .showFavorites
        case "clearHistory": self = .clearHistory
        default: self = .showRecommendations
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .startQuiz:
            try container.encode("startQuiz", forKey: .type)
        case .showRecommendations:
            try container.encode("showRecommendations", forKey: .type)
        case .askAboutFormation(let slug):
            try container.encode("askAboutFormation", forKey: .type)
            try container.encode(slug, forKey: .slug)
        case .showFavorites:
            try container.encode("showFavorites", forKey: .type)
        case .clearHistory:
            try container.encode("clearHistory", forKey: .type)
        }
    }
}

// MARK: - Madi Message

/// Represents a message in the Madi chat conversation.
struct MadiMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let formationRecommendation: FormationRecommendation?
    let messageType: MadiMessageType
    let quickActions: [QuickAction]?

    init(
        id: UUID = UUID(),
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date(),
        formationRecommendation: FormationRecommendation? = nil,
        messageType: MadiMessageType = .text,
        quickActions: [QuickAction]? = nil
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.formationRecommendation = formationRecommendation
        self.messageType = messageType
        self.quickActions = quickActions
    }
}

// MARK: - Formation Recommendation

/// Represents a formation recommendation from Madi.
struct FormationRecommendation: Equatable, Codable {
    let formationId: Int
    let formationSlug: String
    let formationTitle: String
}

// MARK: - Sample Data

extension MadiMessage {
    static let welcomeMessage = MadiMessage(
        content: "Bonjour ! Je suis Madi, votre coach IA. Je suis là pour vous aider à trouver la formation idéale pour atteindre vos objectifs. Que souhaitez-vous apprendre ?",
        isFromUser: false,
        quickActions: [
            QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations),
            QuickAction(label: "Quiz IA", icon: "brain.head.profile", actionType: .startQuiz),
            QuickAction(label: "Mes favoris", icon: "heart.fill", actionType: .showFavorites)
        ]
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
