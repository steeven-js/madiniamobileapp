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
    func sendMessage(_ message: String, formations: [Formation], favoriteIds: Set<Int>) async throws -> MadiMessage

    /// Generate contextual response based on user context
    func generateContextualResponse(formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage?
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

// MARK: - ChatGPT API Response Types

/// Response from ChatGPT backend API
struct ChatGPTResponse: Codable {
    let success: Bool
    let data: ChatGPTResponseData?
}

/// ChatGPT response data payload
struct ChatGPTResponseData: Codable {
    let content: String
    let formationRecommendation: ChatGPTFormationRec?

    enum CodingKeys: String, CodingKey {
        case content
        case formationRecommendation = "formation_recommendation"
    }
}

/// Formation recommendation from ChatGPT
struct ChatGPTFormationRec: Codable {
    let formationId: Int
    let formationSlug: String
    let formationTitle: String

    enum CodingKeys: String, CodingKey {
        case formationId = "formation_id"
        case formationSlug = "formation_slug"
        case formationTitle = "formation_title"
    }
}

/// Service for Madi AI coach conversations.
/// Uses ChatGPT backend via API proxy with local fallback.
final class MadiService: MadiServiceProtocol {
    /// Shared singleton instance
    static let shared = MadiService()

    /// Context service for user behavior tracking
    private let contextService = MadiContextService.shared

    /// API configuration
    private let baseURL = "https://madinia.fr/api/v1"
    private var apiKey: String { SecretsManager.apiKey }
    private let session: URLSession

    /// Whether to use ChatGPT backend (can be disabled for testing)
    var useChatGPTBackend = true

    private init() {
        self.session = .shared
    }

    /// Sends a message to Madi and returns the AI response.
    /// Tries ChatGPT backend first, falls back to local responses if unavailable.
    func sendMessage(_ message: String, formations: [Formation], favoriteIds: Set<Int> = []) async throws -> MadiMessage {
        let lowercaseMessage = message.lowercased()

        // Handle special commands locally (quiz, etc.)
        if let localResponse = handleLocalCommands(message: lowercaseMessage, formations: formations, favoriteIds: favoriteIds) {
            return localResponse
        }

        // Try ChatGPT backend
        if useChatGPTBackend {
            do {
                return try await sendMessageToBackend(message, formations: formations, favoriteIds: favoriteIds)
            } catch {
                #if DEBUG
                print("ChatGPT backend error, using local fallback: \(error)")
                #endif
                // Fall through to local response
            }
        }

        // Local fallback
        return generateLocalResponse(for: lowercaseMessage, formations: formations, favoriteIds: favoriteIds)
    }

    // MARK: - ChatGPT Backend

    private func sendMessageToBackend(_ message: String, formations: [Formation], favoriteIds: Set<Int>) async throws -> MadiMessage {
        let url = URL(string: "\(baseURL)/madi/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        // Build conversation history
        let conversationHistory = contextService.loadConversation().suffix(10).map { msg in
            ["content": msg.content, "isFromUser": msg.isFromUser] as [String: Any]
        }

        // Build user context
        let viewedFormations = contextService.recentlyViewedFormations(limit: 5).map { viewed in
            ["formation_title": viewed.formationTitle] as [String: Any]
        }

        let favoriteNames = formations.filter { favoriteIds.contains($0.id) }.map { $0.title }

        let userContext: [String: Any] = [
            "favorites": favoriteNames,
            "viewed_formations": viewedFormations
        ]

        let body: [String: Any] = [
            "device_uuid": contextService.deviceUUID,
            "message": message,
            "conversation_history": Array(conversationHistory),
            "user_context": userContext
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MadiError.networkError
        }

        if httpResponse.statusCode == 503 {
            throw MadiError.serviceUnavailable
        }

        if httpResponse.statusCode >= 400 {
            throw MadiError.invalidResponse
        }

        // Parse response
        let result = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

        guard result.success, let responseData = result.data else {
            throw MadiError.invalidResponse
        }

        // Build formation recommendation if provided
        var formationRecommendation: FormationRecommendation?
        if let rec = responseData.formationRecommendation {
            formationRecommendation = FormationRecommendation(
                formationId: rec.formationId,
                formationSlug: rec.formationSlug,
                formationTitle: rec.formationTitle
            )
        }

        return MadiMessage(
            content: responseData.content,
            isFromUser: false,
            formationRecommendation: formationRecommendation,
            quickActions: [
                QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations),
                QuickAction(label: "Quiz IA", icon: "brain.head.profile", actionType: .startQuiz)
            ]
        )
    }

    // MARK: - Local Commands

    private func handleLocalCommands(message: String, formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage? {
        // Check for quiz request
        if message.contains("quiz") || message.contains("test") {
            return MadiMessage(
                content: "Super ! Testons vos connaissances en IA. Appuyez sur le bouton ci-dessous pour démarrer le quiz.",
                isFromUser: false,
                messageType: .quizStart,
                quickActions: [
                    QuickAction(label: "Démarrer le quiz", icon: "brain.head.profile", actionType: .startQuiz)
                ]
            )
        }

        // Check for recommendations request
        if message.contains("recommand") || message.contains("suggère") || message.contains("conseil") {
            return generateRecommendationsMessage(formations: formations, favoriteIds: favoriteIds)
        }

        // Check for favorites request
        if message.contains("favoris") || message.contains("sauvegardé") {
            return generateFavoritesMessage(formations: formations, favoriteIds: favoriteIds)
        }

        return nil
    }

    // MARK: - Local Fallback

    private func generateLocalResponse(for message: String, formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage {
        // Check for formation-related keywords and provide recommendations
        if let recommendation = findFormationRecommendation(for: message, in: formations, favoriteIds: favoriteIds) {
            return MadiMessage(
                content: recommendation.response,
                isFromUser: false,
                formationRecommendation: recommendation.formation,
                quickActions: recommendation.quickActions
            )
        }

        // Check for specific question patterns
        if let response = handleSpecificQuestions(message) {
            return MadiMessage(content: response, isFromUser: false)
        }

        // Default helpful response with quick actions
        return MadiMessage(
            content: generateDefaultResponse(for: message),
            isFromUser: false,
            quickActions: [
                QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations),
                QuickAction(label: "Quiz IA", icon: "brain.head.profile", actionType: .startQuiz)
            ]
        )
    }

    /// Generate a contextual response based on user behavior
    func generateContextualResponse(formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage? {
        // Check if user has favorites
        if !favoriteIds.isEmpty {
            let favoriteFormations = formations.filter { favoriteIds.contains($0.id) }
            let categoryNames = Set(favoriteFormations.compactMap { $0.category?.name })

            if let firstCategory = categoryNames.first {
                let message: String
                if categoryNames.count > 1 {
                    let categoryList = Array(categoryNames.prefix(2)).joined(separator: " et ")
                    message = "Je vois que vous vous intéressez à \(categoryList) ! Voulez-vous que je vous recommande des formations complémentaires ?"
                } else {
                    message = "Vous avez ajouté des formations en \(firstCategory) à vos favoris. Souhaitez-vous explorer d'autres formations dans ce domaine ?"
                }

                return MadiMessage(
                    content: message,
                    isFromUser: false,
                    quickActions: [
                        QuickAction(label: "Oui, montre-moi", icon: "sparkles", actionType: .showRecommendations),
                        QuickAction(label: "Faire un quiz", icon: "brain.head.profile", actionType: .startQuiz),
                        QuickAction(label: "Autre chose", icon: "ellipsis", actionType: .showRecommendations)
                    ]
                )
            }
        }

        // Check for recently viewed formations
        let recentlyViewed = contextService.recentlyViewedFormations(limit: 3)
        if let lastViewed = recentlyViewed.first {
            return MadiMessage(
                content: "Vous avez consulté récemment « \(lastViewed.formationTitle) ». Voulez-vous en savoir plus ou explorer des formations similaires ?",
                isFromUser: false,
                quickActions: [
                    QuickAction(label: "Formations similaires", icon: "sparkles", actionType: .showRecommendations),
                    QuickAction(label: "Tester mes connaissances", icon: "brain.head.profile", actionType: .startQuiz)
                ]
            )
        }

        return nil
    }

    // MARK: - Recommendations

    private func generateRecommendationsMessage(formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage {
        let recommendations = contextService.getRecommendations(from: formations, favoriteIds: favoriteIds)

        if let top = recommendations.first {
            return MadiMessage(
                content: "Basé sur votre profil, je vous recommande « \(top.formation.title) ». \(top.reason).",
                isFromUser: false,
                formationRecommendation: FormationRecommendation(
                    formationId: top.formation.id,
                    formationSlug: top.formation.slug,
                    formationTitle: top.formation.title
                ),
                quickActions: [
                    QuickAction(label: "Voir plus", icon: "list.bullet", actionType: .showRecommendations)
                ]
            )
        }

        // Fallback if no personalized recommendations
        if let first = formations.first(where: { $0.title.lowercased().contains("starter") }) {
            return MadiMessage(
                content: "Pour commencer, je vous recommande notre formation d'introduction : « \(first.title) ». C'est idéal pour découvrir les bases !",
                isFromUser: false,
                formationRecommendation: FormationRecommendation(
                    formationId: first.id,
                    formationSlug: first.slug,
                    formationTitle: first.title
                )
            )
        }

        return MadiMessage(
            content: "Explorez nos formations pour trouver celle qui vous correspond. Dites-moi quel est votre niveau (débutant, intermédiaire, avancé) et je vous guiderai !",
            isFromUser: false,
            quickActions: [
                QuickAction(label: "Débutant", icon: "1.circle", actionType: .showRecommendations),
                QuickAction(label: "Intermédiaire", icon: "2.circle", actionType: .showRecommendations),
                QuickAction(label: "Avancé", icon: "3.circle", actionType: .showRecommendations)
            ]
        )
    }

    private func generateFavoritesMessage(formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage {
        if favoriteIds.isEmpty {
            return MadiMessage(
                content: "Vous n'avez pas encore de formations en favoris. Explorez notre catalogue et ajoutez celles qui vous intéressent !",
                isFromUser: false,
                quickActions: [
                    QuickAction(label: "Voir les formations", icon: "book.fill", actionType: .showRecommendations)
                ]
            )
        }

        let favoriteFormations = formations.filter { favoriteIds.contains($0.id) }
        let count = favoriteFormations.count
        let names = favoriteFormations.prefix(2).map { $0.title }.joined(separator: ", ")

        return MadiMessage(
            content: "Vous avez \(count) formation\(count > 1 ? "s" : "") en favoris : \(names)\(count > 2 ? "..." : ""). Souhaitez-vous des recommandations complémentaires ?",
            isFromUser: false,
            quickActions: [
                QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations),
                QuickAction(label: "Mes favoris", icon: "heart.fill", actionType: .showFavorites)
            ]
        )
    }

    // MARK: - Private Helpers

    private struct RecommendationResult {
        let response: String
        let formation: FormationRecommendation?
        let quickActions: [QuickAction]?
    }

    private func findFormationRecommendation(
        for message: String,
        in formations: [Formation],
        favoriteIds: Set<Int> = []
    ) -> RecommendationResult? {
        // Keywords for different learning levels
        let starterKeywords = ["débuter", "commencer", "débutant", "bases", "initiation", "découvrir", "starter"]
        let performerKeywords = ["améliorer", "progresser", "intermédiaire", "approfondir", "performer"]
        let masterKeywords = ["expert", "avancé", "maîtriser", "master", "spécialiste"]
        let iaKeywords = ["ia", "intelligence artificielle", "ai", "chatgpt", "gpt", "claude", "automatiser"]

        // Find matching formation based on keywords
        var matchedFormation: Formation?
        var responsePrefix = ""
        var additionalContext = ""

        if starterKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.title.lowercased().contains("starter") }
            responsePrefix = "Pour bien débuter, je vous recommande notre "
            additionalContext = " C'est parfait pour acquérir les bases essentielles."
        } else if performerKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.title.lowercased().contains("performer") }
            responsePrefix = "Pour progresser efficacement, je vous conseille notre "
            additionalContext = " Vous approfondirez vos connaissances avec des cas pratiques."
        } else if masterKeywords.contains(where: message.contains) {
            matchedFormation = formations.first { $0.title.lowercased().contains("master") }
            responsePrefix = "Pour atteindre un niveau expert, notre "
            additionalContext = " Vous maîtriserez les techniques avancées."
        } else if iaKeywords.contains(where: message.contains) {
            // Check if user has favorites in IA category
            let favoriteFormations = formations.filter { favoriteIds.contains($0.id) }
            let hasIAFavorites = favoriteFormations.contains { $0.category?.name.lowercased().contains("ia") == true }

            if hasIAFavorites {
                // Recommend next level
                matchedFormation = formations.first { $0.title.lowercased().contains("performer") }
                    ?? formations.first { $0.category?.name.lowercased().contains("ia") == true }
                responsePrefix = "Vu votre intérêt pour l'IA, je vous recommande "
                additionalContext = " pour aller plus loin dans votre apprentissage."
            } else {
                matchedFormation = formations.first { $0.category?.name.lowercased().contains("ia") == true }
                    ?? formations.first
                responsePrefix = "L'IA est un domaine passionnant ! Je vous recommande "
                additionalContext = " pour découvrir ce domaine."
            }
        }

        guard let formation = matchedFormation else { return nil }

        let response = "\(responsePrefix)« \(formation.title) ».\(additionalContext)"

        let quickActions = [
            QuickAction(label: "Voir la formation", icon: "book.fill", actionType: .askAboutFormation(slug: formation.slug)),
            QuickAction(label: "Quiz IA", icon: "brain.head.profile", actionType: .startQuiz)
        ]

        return RecommendationResult(
            response: response,
            formation: FormationRecommendation(
                formationId: formation.id,
                formationSlug: formation.slug,
                formationTitle: formation.title
            ),
            quickActions: quickActions
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

    func sendMessage(_ message: String, formations: [Formation], favoriteIds: Set<Int> = []) async throws -> MadiMessage {
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw MadiError.serviceUnavailable
        }

        return MadiMessage(
            content: "Réponse de test pour: \(message)",
            isFromUser: false
        )
    }

    func generateContextualResponse(formations: [Formation], favoriteIds: Set<Int>) -> MadiMessage? {
        return nil
    }
}
