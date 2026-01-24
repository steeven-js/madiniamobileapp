//
//  ContactViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Contact form, managing form state and submission.
@Observable
final class ContactViewModel {
    // MARK: - Form Fields

    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
    var subject: String = ""
    var message: String = ""

    // MARK: - State

    enum SubmissionState: Equatable {
        case idle
        case submitting
        case success
        case error(String)
    }

    private(set) var state: SubmissionState = .idle

    // MARK: - Context

    var contextItem: NavigationContextItem?
    var showContext: Bool = true

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Validation

    var isFirstNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isLastNameValid: Bool {
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var emailValidation: EmailValidator.Result {
        EmailValidator.validate(email)
    }

    var isEmailValid: Bool {
        emailValidation == .valid
    }

    var isSubjectValid: Bool {
        !subject.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isMessageValid: Bool {
        message.trimmingCharacters(in: .whitespaces).count >= 10
    }

    var isFormValid: Bool {
        isFirstNameValid && isLastNameValid && isEmailValid && isSubjectValid && isMessageValid
    }

    // MARK: - Actions

    /// Sets up the form with context from NavigationContext
    func setupWithContext(_ context: NavigationContext) {
        contextItem = context.currentContext
        if contextItem != nil {
            subject = context.suggestedSubject
            message = context.suggestedMessage
            showContext = true
        }
    }

    /// Dismisses the context banner
    func dismissContext() {
        showContext = false
        contextItem = nil
        // Clear pre-filled subject and message if user dismisses context
        if subject == NavigationContext.shared.suggestedSubject {
            subject = ""
        }
        if message == NavigationContext.shared.suggestedMessage {
            message = ""
        }
    }

    /// Submits the contact form
    @MainActor
    func submit() async {
        guard isFormValid else { return }
        guard state != .submitting else { return }

        state = .submitting

        do {
            let contextString = showContext ? contextItem.map { "\($0.type.rawValue.capitalized): \($0.title)" } : nil

            try await apiService.submitContact(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                phone: phone.isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces),
                subject: subject.trimmingCharacters(in: .whitespaces),
                message: message.trimmingCharacters(in: .whitespaces),
                context: contextString
            )
            state = .success
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Erreur d'envoi")
        } catch {
            state = .error("Erreur de connexion")
        }
    }

    /// Resets the form for a new message
    func reset() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        subject = ""
        message = ""
        state = .idle
        contextItem = nil
        showContext = false
    }
}
