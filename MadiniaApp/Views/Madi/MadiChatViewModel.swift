//
//  MadiChatViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Madi chat interface.
@Observable
final class MadiChatViewModel {
    // MARK: - State

    /// All messages in the conversation
    private(set) var messages: [MadiMessage] = []

    /// Current input text
    var inputText: String = ""

    /// Whether Madi is currently typing a response
    private(set) var isTyping: Bool = false

    /// Error message if something goes wrong
    private(set) var errorMessage: String?

    /// Available formations for recommendations
    private(set) var formations: [Formation] = []

    /// Whether the quiz sheet is showing
    var isQuizPresented: Bool = false

    /// Current quiz questions (when quiz is active)
    var currentQuizQuestions: [QuizQuestion] = []

    /// Quick actions to display below input
    private(set) var quickActions: [QuickAction] = []

    // MARK: - Dependencies

    private let madiService: MadiServiceProtocol
    private let apiService: APIServiceProtocol
    private let contextService = MadiContextService.shared
    private let favoritesService = FavoritesService.shared

    // MARK: - Initialization

    init(
        madiService: MadiServiceProtocol = MadiService.shared,
        apiService: APIServiceProtocol = APIService.shared
    ) {
        self.madiService = madiService
        self.apiService = apiService

        // Load conversation history
        loadConversationHistory()
    }

    // MARK: - Computed Properties

    /// Whether the send button should be enabled
    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }

    /// User's favorite formation IDs
    private var favoriteIds: Set<Int> {
        favoritesService.favoriteFormationIds
    }

    // MARK: - Actions

    /// Loads formations for recommendation context
    @MainActor
    func loadFormations() async {
        do {
            formations = try await apiService.fetchFormations()

            // Generate contextual greeting if we have context and no messages yet
            if messages.count <= 1 {
                if let contextualMessage = madiService.generateContextualResponse(
                    formations: formations,
                    favoriteIds: favoriteIds
                ) {
                    messages.append(contextualMessage)
                    saveConversation()
                }
            }
        } catch {
            // Silently fail - we can still chat without formations
            formations = []
        }

        updateQuickActions()
    }

    /// Sends the current input message to Madi
    @MainActor
    func sendMessage() async {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard !isTyping else { return }

        // Add user message
        let userMessage = MadiMessage(content: trimmedText, isFromUser: true)
        messages.append(userMessage)
        inputText = ""
        errorMessage = nil

        // Show typing indicator
        isTyping = true

        do {
            // Get Madi's response
            let response = try await madiService.sendMessage(
                trimmedText,
                formations: formations,
                favoriteIds: favoriteIds
            )
            messages.append(response)
        } catch let error as MadiError {
            errorMessage = error.errorDescription
            // Add fallback message
            messages.append(MadiMessage(
                content: "Désolé, je rencontre un petit problème technique. Pouvez-vous reformuler votre question ?",
                isFromUser: false
            ))
        } catch {
            errorMessage = "Une erreur est survenue"
            messages.append(MadiMessage(
                content: "Désolé, je rencontre un petit problème technique. Pouvez-vous reformuler votre question ?",
                isFromUser: false
            ))
        }

        isTyping = false
        saveConversation()
        updateQuickActions()
    }

    /// Handle a quick action tap
    @MainActor
    func handleQuickAction(_ action: QuickAction) async {
        switch action.actionType {
        case .startQuiz:
            startQuiz()

        case .showRecommendations:
            inputText = "Quelles formations me recommandes-tu ?"
            await sendMessage()

        case .askAboutFormation(let slug):
            if let formation = formations.first(where: { $0.slug == slug }) {
                inputText = "Parle-moi de la formation \(formation.title)"
                await sendMessage()
            }

        case .showFavorites:
            inputText = "Quels sont mes favoris ?"
            await sendMessage()

        case .clearHistory:
            clearHistory()
        }
    }

    /// Start a quiz session
    func startQuiz() {
        currentQuizQuestions = QuizQuestion.randomQuiz(count: 5)
        isQuizPresented = true
    }

    /// Handle quiz completion
    @MainActor
    func handleQuizComplete(score: Int, total: Int) {
        let percentage = Int((Double(score) / Double(total)) * 100)
        let feedback: String
        let recommendation: FormationRecommendation?

        if percentage >= 80 {
            feedback = "Excellent score ! Vous maîtrisez bien le sujet."
            recommendation = formations.first(where: { $0.title.lowercased().contains("master") }).map {
                FormationRecommendation(formationId: $0.id, formationSlug: $0.slug, formationTitle: $0.title)
            }
        } else if percentage >= 60 {
            feedback = "Bravo ! Vous avez de bonnes bases. Continuez à progresser."
            recommendation = formations.first(where: { $0.title.lowercased().contains("performer") }).map {
                FormationRecommendation(formationId: $0.id, formationSlug: $0.slug, formationTitle: $0.title)
            }
        } else {
            feedback = "C'est un début ! Je vous recommande de commencer par les bases."
            recommendation = formations.first(where: { $0.title.lowercased().contains("starter") }).map {
                FormationRecommendation(formationId: $0.id, formationSlug: $0.slug, formationTitle: $0.title)
            }
        }

        let resultMessage = MadiMessage(
            content: "Quiz terminé ! Score : \(score)/\(total) (\(percentage)%)\n\n\(feedback)",
            isFromUser: false,
            formationRecommendation: recommendation,
            messageType: .quizResult(score: score, total: total),
            quickActions: [
                QuickAction(label: "Refaire un quiz", icon: "arrow.counterclockwise", actionType: .startQuiz),
                QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations)
            ]
        )

        messages.append(resultMessage)
        saveConversation()
        isQuizPresented = false
    }

    /// Clears the error message
    func dismissError() {
        errorMessage = nil
    }

    /// Resets the conversation (new conversation)
    func resetConversation() {
        messages = [.welcomeMessage]
        inputText = ""
        errorMessage = nil
        isTyping = false
        saveConversation()
        updateQuickActions()
    }

    /// Clear all history including conversation and viewed formations
    func clearHistory() {
        contextService.clearAllHistory()
        resetConversation()

        // Add confirmation message
        messages.append(MadiMessage(
            content: "L'historique a été effacé. Comment puis-je vous aider ?",
            isFromUser: false,
            quickActions: [
                QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations),
                QuickAction(label: "Quiz IA", icon: "brain.head.profile", actionType: .startQuiz)
            ]
        ))
        saveConversation()
    }

    // MARK: - Private Helpers

    private func loadConversationHistory() {
        let savedMessages = contextService.loadConversation()
        if savedMessages.isEmpty {
            messages = [.welcomeMessage]
        } else {
            messages = savedMessages
        }
        updateQuickActions()
    }

    private func saveConversation() {
        contextService.saveConversation(messages)
    }

    private func updateQuickActions() {
        // Default quick actions
        var actions: [QuickAction] = []

        // If we have favorites, suggest based on them
        if !favoriteIds.isEmpty {
            actions.append(QuickAction(
                label: "Mes favoris",
                icon: "heart.fill",
                actionType: .showFavorites
            ))
        }

        // Always offer recommendations and quiz
        actions.append(QuickAction(
            label: "Recommandations",
            icon: "sparkles",
            actionType: .showRecommendations
        ))

        actions.append(QuickAction(
            label: "Quiz IA",
            icon: "brain.head.profile",
            actionType: .startQuiz
        ))

        quickActions = actions
    }
}
