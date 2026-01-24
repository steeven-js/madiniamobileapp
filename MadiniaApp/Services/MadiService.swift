//
//  MadiService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Protocol for Madi AI service
protocol MadiServiceProtocol {
    /// Sends a message to Madi and returns the response
    func sendMessage(_ message: String, formations: [Formation]) async throws -> MadiMessage
}

/// Error types for Madi service
enum MadiError: Error, LocalizedError {
    case networkError
    case serviceUnavailable
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Erreur de connexion. Veuillez réessayer."
        case .serviceUnavailable:
            return "Le service Madi est temporairement indisponible."
        case .invalidResponse:
            return "Réponse invalide du serveur."
        }
    }
}

/// Service for Madi AI coach conversations.
/// Uses a local response system with optional AI backend integration.
final class MadiService: MadiServiceProtocol {
    /// Shared singleton instance
    static let shared = MadiService()

    private init() {}

    /// Sends a message to Madi and returns the AI response.
    /// Currently uses local response logic with formation matching.
    /// Can be extended to call an AI backend (OpenAI, Claude, etc.)
    func sendMessage(_ message: String, formations: [Formation]) async throws -> MadiMessage {
        // Simulate network delay for natural conversation feel
        try await Task.sleep(for: .milliseconds(800 + Int.random(in: 0...500)))

        let lowercaseMessage = message.lowercased()

        // Check for formation-related keywords and provide recommendations
        if let recommendation = findFormationRecommendation(for: lowercaseMessage, in: formations) {
            return MadiMessage(
                content: recommendation.response,
                isFromUser: false,
                formationRecommendation: recommendation.formation
            )
        }

        // Check for specific question patterns
        if let response = handleSpecificQuestions(lowercaseMessage) {
            return MadiMessage(content: response, isFromUser: false)
        }

        // Default helpful response
        return MadiMessage(
            content: generateDefaultResponse(for: lowercaseMessage),
            isFromUser: false
        )
    }

    // MARK: - Private Helpers

    private struct RecommendationResult {
        let response: String
        let formation: FormationRecommendation?
    }

    private func findFormationRecommendation(
        for message: String,
        in formations: [Formation]
    ) -> RecommendationResult? {
        // Keywords for different learning levels
        let starterKeywords = ["débuter", "commencer", "débutant", "bases", "initiation", "découvrir", "starter"]
        let performerKeywords = ["améliorer", "progresser", "intermédiaire", "approfondir", "performer"]
        let masterKeywords = ["expert", "avancé", "maîtriser", "master", "spécialiste"]
        let iaKeywords = ["ia", "intelligence artificielle", "ai", "chatgpt", "gpt", "claude", "automatiser"]

        // Find matching formation based on keywords
        var matchedFormation: Formation?
        var responsePrefix = ""

        if starterKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.title.lowercased().contains("starter") }
            responsePrefix = "Pour bien débuter, je vous recommande notre "
        } else if performerKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.title.lowercased().contains("performer") }
            responsePrefix = "Pour progresser efficacement, je vous conseille notre "
        } else if masterKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.title.lowercased().contains("master") }
            responsePrefix = "Pour atteindre un niveau expert, notre "
        } else if iaKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.category?.name.lowercased().contains("ia") == true }
                ?? formations.first
            responsePrefix = "L'IA est un domaine passionnant ! Je vous recommande "
        }

        guard let formation = matchedFormation else { return nil }

        let response = "\(responsePrefix)\(formation.title) est idéal pour vous. Cette formation vous permettra d'acquérir les compétences essentielles."

        return RecommendationResult(
            response: response,
            formation: FormationRecommendation(
                formationId: formation.id,
                formationSlug: formation.slug,
                formationTitle: formation.title
            )
        )
    }

    private func handleSpecificQuestions(_ message: String) -> String? {
        // Handle pack comparison questions
        if message.contains("différence") && (message.contains("pack") || message.contains("formation")) {
            return """
            Nos packs sont conçus pour accompagner votre progression :

            • **Starter** : Les fondamentaux pour débuter, idéal si vous découvrez le sujet
            • **Performer** : Approfondissement et mise en pratique, pour ceux qui ont déjà les bases
            • **Master** : Expertise avancée et cas complexes, pour devenir un expert

            Quel est votre niveau actuel ?
            """
        }

        // Handle pricing questions
        if message.contains("prix") || message.contains("coût") || message.contains("tarif") {
            return "Les tarifs varient selon les formations. Je vous invite à consulter les fiches détaillées pour voir les prix et les modalités de financement disponibles. Puis-je vous orienter vers une formation en particulier ?"
        }

        // Handle duration questions
        if message.contains("durée") || message.contains("combien de temps") {
            return "La durée dépend de la formation choisie. Nos formations Starter durent généralement quelques jours, tandis que les formations Master peuvent s'étendre sur plusieurs semaines. Quel type de formation vous intéresse ?"
        }

        // Handle greeting
        if message.contains("bonjour") || message.contains("salut") || message.contains("hello") {
            return "Bonjour ! Ravi de vous retrouver. Comment puis-je vous aider aujourd'hui dans votre parcours de formation ?"
        }

        // Handle thanks
        if message.contains("merci") {
            return "Avec plaisir ! N'hésitez pas si vous avez d'autres questions. Je suis là pour vous accompagner dans votre choix de formation."
        }

        return nil
    }

    private func generateDefaultResponse(for message: String) -> String {
        let responses = [
            "Je comprends votre intérêt. Pourriez-vous me préciser vos objectifs d'apprentissage ? Par exemple : souhaitez-vous débuter, vous perfectionner, ou devenir expert ?",
            "Intéressant ! Pour mieux vous orienter, pouvez-vous me dire quel est votre niveau actuel et ce que vous aimeriez accomplir ?",
            "Je suis là pour vous aider à trouver la formation parfaite. Dites-moi en plus sur vos besoins et vos objectifs professionnels.",
            "Chaque parcours est unique ! Parlez-moi de vos attentes et je vous guiderai vers la formation la plus adaptée."
        ]
        return responses.randomElement() ?? responses[0]
    }
}

// MARK: - Mock Service for Testing

final class MockMadiService: MadiServiceProtocol {
    var shouldFail = false
    var simulatedDelay: Double = 0.5

    func sendMessage(_ message: String, formations: [Formation]) async throws -> MadiMessage {
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw MadiError.serviceUnavailable
        }

        return MadiMessage(
            content: "Réponse de test pour: \(message)",
            isFromUser: false
        )
    }
}
