//
//  MyPreRegistrationsViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import Foundation

/// ViewModel for the user's pre-registrations list.
@Observable
final class MyPreRegistrationsViewModel {
    // MARK: - State

    /// Loading state for the pre-registrations list
    var loadingState: LoadingState<[PreRegistration]> = .idle

    /// Convenience accessor for pre-registrations
    var preRegistrations: [PreRegistration] {
        loadingState.value ?? []
    }

    /// Number of pre-registrations used
    var usedCount: Int {
        preRegistrationsService.usedCount
    }

    /// Number of pre-registrations remaining
    var remainingCount: Int {
        preRegistrationsService.remainingCount
    }

    /// Maximum allowed pre-registrations
    var maxAllowed: Int {
        PreRegistrationsService.maxPreRegistrations
    }

    // MARK: - Dependencies

    private let preRegistrationsService: PreRegistrationsService

    // MARK: - Initialization

    init(preRegistrationsService: PreRegistrationsService = .shared) {
        self.preRegistrationsService = preRegistrationsService
    }

    // MARK: - Actions

    /// Loads pre-registrations from the API
    @MainActor
    func loadPreRegistrations() async {
        guard !loadingState.isLoading else { return }

        loadingState = .loading

        do {
            let registrations = try await preRegistrationsService.fetchPreRegistrations()
            loadingState = .loaded(registrations)
        } catch {
            loadingState = .error("Impossible de charger vos pré-inscriptions. Veuillez réessayer.")
        }
    }

    /// Refreshes pre-registrations
    @MainActor
    func refresh() async {
        do {
            let registrations = try await preRegistrationsService.fetchPreRegistrations()
            loadingState = .loaded(registrations)
        } catch {
            // Keep existing data on refresh failure
            if preRegistrations.isEmpty {
                loadingState = .error("Impossible de charger vos pré-inscriptions.")
            }
        }
    }
}
