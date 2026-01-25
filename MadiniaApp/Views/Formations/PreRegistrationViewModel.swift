//
//  PreRegistrationViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

// MARK: - Enums

/// Available funding methods for pre-registration
enum FundingMethod: String, CaseIterable, Identifiable {
    case cpf = "cpf"
    case opco = "opco"
    case franceTravail = "france_travail"
    case selfFunding = "autofinancement"
    case other = "autre"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cpf:
            return "CPF (Compte Personnel de Formation)"
        case .opco:
            return "OPCO (Opérateur de Compétences)"
        case .franceTravail:
            return "France Travail (Pôle Emploi)"
        case .selfFunding:
            return "Autofinancement"
        case .other:
            return "Autre moyen de financement"
        }
    }
}

/// Preferred training format
enum PreferredFormat: String, CaseIterable, Identifiable {
    case inPerson = "presentiel"
    case remote = "distanciel"
    case hybrid = "hybride"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .inPerson:
            return "Présentiel"
        case .remote:
            return "Distanciel (en ligne)"
        case .hybrid:
            return "Hybride (présentiel + distanciel)"
        }
    }
}

// MARK: - ViewModel

/// ViewModel for pre-registration submission.
/// Handles form fields, validation, API submission, loading state, and error handling.
@Observable
final class PreRegistrationViewModel {
    // MARK: - State

    /// Current submission state
    enum SubmissionState: Equatable {
        case idle
        case submitting
        case success
        case error(String)
    }

    /// Current state of the submission
    private(set) var state: SubmissionState = .idle

    // MARK: - Form Fields

    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
    var fundingMethod: FundingMethod?
    var preferredFormat: PreferredFormat?
    var comments: String = ""

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties - State

    /// Whether a submission is in progress
    var isSubmitting: Bool {
        state == .submitting
    }

    /// Whether submission succeeded
    var isSuccess: Bool {
        state == .success
    }

    /// Error message if submission failed
    var errorMessage: String? {
        if case .error(let message) = state {
            return message
        }
        return nil
    }

    // MARK: - Computed Properties - Validation

    /// Whether the first name is valid (non-empty after trim)
    var isFirstNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether the last name is valid (non-empty after trim)
    var isLastNameValid: Bool {
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether the email is valid
    var isEmailValid: Bool {
        EmailValidator.validate(email) == .valid
    }

    /// Whether the phone is valid (at least 8 characters)
    var isPhoneValid: Bool {
        phone.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
    }

    /// Whether a funding method is selected
    var isFundingMethodValid: Bool {
        fundingMethod != nil
    }

    /// Whether a preferred format is selected
    var isPreferredFormatValid: Bool {
        preferredFormat != nil
    }

    /// Whether the entire form is valid
    var isFormValid: Bool {
        isFirstNameValid &&
        isLastNameValid &&
        isEmailValid &&
        isPhoneValid &&
        isFundingMethodValid &&
        isPreferredFormatValid
    }

    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Actions

    /// Submits pre-registration for the given formation
    /// - Parameter formationId: The formation's ID
    @MainActor
    func submit(formationId: Int) async {
        guard state != .submitting else { return }
        guard isFormValid else { return }
        guard let funding = fundingMethod, let format = preferredFormat else { return }

        state = .submitting

        do {
            try await apiService.submitPreRegistration(
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                formationId: formationId,
                fundingMethod: funding.rawValue,
                preferredFormat: format.rawValue,
                comments: comments.isEmpty ? nil : comments.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            state = .success
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Erreur lors de l'envoi")
        } catch {
            state = .error("Erreur de connexion. Veuillez réessayer.")
        }
    }

    /// Resets the state to idle for retry
    func reset() {
        state = .idle
    }

    /// Resets all form fields
    func resetForm() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        fundingMethod = nil
        preferredFormat = nil
        comments = ""
        state = .idle
    }
}
