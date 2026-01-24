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
    private(set) var messages: [MadiMessage] = [.welcomeMessage]

    /// Current input text
    var inputText: String = ""

    /// Whether Madi is currently typing a response
    private(set) var isTyping: Bool = false

    /// Error message if something goes wrong
    private(set) var errorMessage: String?

    /// Available formations for recommendations
    private(set) var formations: [Formation] = []

    // MARK: - Dependencies

    private let madiService: MadiServiceProtocol
    private let apiService: APIServiceProtocol

    // MARK: - Initialization

    init(
        madiService: MadiServiceProtocol = MadiService.shared,
        apiService: APIServiceProtocol = APIService.shared
    ) {
        self.madiService = madiService
        self.apiService = apiService
    }

    // MARK: - Computed Properties

    /// Whether the send button should be enabled
    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }

    // MARK: - Actions

    /// Loads formations for recommendation context
    @MainActor
    func loadFormations() async {
        do {
            formations = try await apiService.fetchFormations()
        } catch {
            // Silently fail - we can still chat without formations
            formations = []
        }
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
            let response = try await madiService.sendMessage(trimmedText, formations: formations)
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
    }

    /// Clears the error message
    func dismissError() {
        errorMessage = nil
    }

    /// Resets the conversation
    func resetConversation() {
        messages = [.welcomeMessage]
        inputText = ""
        errorMessage = nil
        isTyping = false
    }
}
