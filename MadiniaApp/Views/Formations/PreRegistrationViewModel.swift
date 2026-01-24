//
//  PreRegistrationViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for pre-registration submission.
/// Handles API submission, loading state, and error handling.
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

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties

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

    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Actions

    /// Submits pre-registration for the given formation
    /// - Parameters:
    ///   - formationId: The formation's ID
    ///   - email: User's email address
    @MainActor
    func submit(formationId: Int, email: String) async {
        guard state != .submitting else { return }

        state = .submitting

        do {
            try await apiService.submitPreRegistration(formationId: formationId, email: email)
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
}
