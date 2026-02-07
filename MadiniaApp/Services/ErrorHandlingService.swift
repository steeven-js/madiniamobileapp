//
//  ErrorHandlingService.swift
//  MadiniaApp
//
//  Service centralisé de gestion des erreurs avec retry automatique et mode dégradé.
//

import Foundation
import SwiftUI

// MARK: - Error Context

/// Contexte d'erreur pour des messages personnalisés
enum ErrorContext: String {
    case loadingFormations = "formations"
    case loadingArticles = "articles"
    case loadingEvents = "événements"
    case loadingServices = "services"
    case loadingCategories = "catégories"
    case sendingContact = "envoi du message"
    case registeringEvent = "inscription à l'événement"
    case downloadingContent = "téléchargement"
    case syncingData = "synchronisation"
    case general = "opération"

    /// Message d'erreur contextualisé
    func errorMessage(for error: APIError) -> String {
        switch error {
        case .networkError:
            return "Impossible de charger les \(rawValue). Vérifiez votre connexion."
        case .timeout:
            return "Le chargement des \(rawValue) a pris trop de temps."
        case .serverError:
            return "Erreur serveur lors du chargement des \(rawValue)."
        case .notFound:
            return "Les \(rawValue) demandées sont introuvables."
        case .noData:
            return "Aucune donnée reçue pour les \(rawValue)."
        default:
            return "Erreur lors du chargement des \(rawValue)."
        }
    }

    /// Icône SF Symbol pour le contexte
    var icon: String {
        switch self {
        case .loadingFormations: return "book.fill"
        case .loadingArticles: return "newspaper.fill"
        case .loadingEvents: return "calendar"
        case .loadingServices: return "briefcase.fill"
        case .loadingCategories: return "folder.fill"
        case .sendingContact: return "envelope.fill"
        case .registeringEvent: return "person.badge.plus"
        case .downloadingContent: return "arrow.down.circle.fill"
        case .syncingData: return "arrow.triangle.2.circlepath"
        case .general: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Retry State

/// État d'une tentative de retry
enum RetryState: Equatable {
    case idle
    case retrying(attempt: Int, maxAttempts: Int)
    case waiting(seconds: Int)
    case succeeded
    case failed(message: String)

    var isActive: Bool {
        switch self {
        case .retrying, .waiting: return true
        default: return false
        }
    }

    var statusMessage: String {
        switch self {
        case .idle:
            return ""
        case .retrying(let attempt, let maxAttempts):
            return "Tentative \(attempt)/\(maxAttempts)..."
        case .waiting(let seconds):
            return "Nouvelle tentative dans \(seconds)s..."
        case .succeeded:
            return "Connexion rétablie"
        case .failed(let message):
            return message
        }
    }
}

// MARK: - App Health State

/// État de santé global de l'application
enum AppHealthState {
    /// Tout fonctionne normalement
    case healthy
    /// Mode dégradé - données du cache uniquement
    case degraded(reason: String)
    /// Hors ligne
    case offline
    /// Erreur critique
    case error(message: String)

    var icon: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .degraded: return "exclamationmark.triangle.fill"
        case .offline: return "wifi.slash"
        case .error: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .healthy: return .green
        case .degraded: return .orange
        case .offline: return .gray
        case .error: return .red
        }
    }

    var message: String {
        switch self {
        case .healthy:
            return "Connecté"
        case .degraded(let reason):
            return reason
        case .offline:
            return "Mode hors ligne"
        case .error(let message):
            return message
        }
    }
}

// MARK: - Error Handling Service

/// Service centralisé de gestion des erreurs avec retry automatique
@Observable
final class ErrorHandlingService {
    // MARK: - Singleton

    static let shared = ErrorHandlingService()

    // MARK: - Dependencies

    private let networkMonitor = NetworkMonitorService.shared

    // MARK: - State

    /// État de santé global de l'app
    private(set) var healthState: AppHealthState = .healthy

    /// État du retry en cours
    private(set) var retryState: RetryState = .idle

    /// Dernière erreur rencontrée
    private(set) var lastError: APIError?

    /// Contexte de la dernière erreur
    private(set) var lastErrorContext: ErrorContext?

    /// Nombre de requêtes échouées consécutives
    private var consecutiveFailures = 0

    /// Seuil pour passer en mode dégradé
    private let degradedModeThreshold = 3

    // MARK: - Retry Configuration

    /// Nombre maximum de tentatives
    private let maxRetryAttempts = 3

    /// Délai initial entre les tentatives (en secondes)
    private let initialRetryDelay: TimeInterval = 2

    /// Multiplicateur pour le backoff exponentiel
    private let backoffMultiplier: Double = 2.0

    // MARK: - Initialization

    private init() {
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        networkMonitor.onConnectivityChange = { [weak self] isConnected in
            guard let self = self else { return }
            if !isConnected {
                self.healthState = .offline
            } else if self.consecutiveFailures >= self.degradedModeThreshold {
                self.healthState = .degraded(reason: "Connexion instable")
            } else {
                self.healthState = .healthy
            }
        }

        networkMonitor.onBackOnline = { [weak self] in
            self?.resetFailureCount()
        }
    }

    // MARK: - Public API

    /// Exécute une opération avec retry automatique
    @MainActor
    func executeWithRetry<T>(
        context: ErrorContext,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        retryState = .idle
        lastErrorContext = context

        var lastAttemptError: Error?

        for attempt in 1...maxRetryAttempts {
            do {
                retryState = .retrying(attempt: attempt, maxAttempts: maxRetryAttempts)

                let result = try await operation()

                // Succès
                retryState = .succeeded
                recordSuccess()
                HapticManager.success()

                // Reset après un court délai
                try? await Task.sleep(for: .seconds(1))
                retryState = .idle

                return result

            } catch let error as APIError {
                lastAttemptError = error
                lastError = error

                // Si l'erreur n'est pas retryable, échouer immédiatement
                if !error.isRetryable {
                    recordFailure(error)
                    retryState = .failed(message: context.errorMessage(for: error))
                    throw error
                }

                // Attendre avant la prochaine tentative (sauf pour la dernière)
                if attempt < maxRetryAttempts {
                    let delay = calculateDelay(for: attempt)
                    await countdownWait(seconds: Int(delay))
                }

            } catch {
                lastAttemptError = error
                let apiError = APIError.networkError(error.localizedDescription)
                lastError = apiError
                recordFailure(apiError)

                if attempt < maxRetryAttempts {
                    let delay = calculateDelay(for: attempt)
                    await countdownWait(seconds: Int(delay))
                }
            }
        }

        // Toutes les tentatives ont échoué
        let finalError = lastError ?? .networkError("Erreur inconnue")
        retryState = .failed(message: context.errorMessage(for: finalError))
        HapticManager.error()

        throw lastAttemptError ?? finalError
    }

    /// Enregistre un succès et réinitialise le compteur d'échecs
    func recordSuccess() {
        consecutiveFailures = 0
        if networkMonitor.isConnected {
            healthState = .healthy
        }
    }

    /// Enregistre un échec
    func recordFailure(_ error: APIError) {
        consecutiveFailures += 1

        if consecutiveFailures >= degradedModeThreshold {
            healthState = .degraded(reason: "API temporairement indisponible")
        }

        #if DEBUG
        print("[ErrorHandling] Failure recorded: \(error.debugDescription), consecutive: \(consecutiveFailures)")
        #endif
    }

    /// Réinitialise le compteur d'échecs
    func resetFailureCount() {
        consecutiveFailures = 0
        if networkMonitor.isConnected {
            healthState = .healthy
        }
    }

    /// Vérifie si l'app est en mode dégradé
    var isDegradedMode: Bool {
        if case .degraded = healthState { return true }
        return false
    }

    /// Vérifie si l'app est hors ligne
    var isOffline: Bool {
        if case .offline = healthState { return true }
        return !networkMonitor.isConnected
    }

    // MARK: - Private Helpers

    private func calculateDelay(for attempt: Int) -> TimeInterval {
        return initialRetryDelay * pow(backoffMultiplier, Double(attempt - 1))
    }

    @MainActor
    private func countdownWait(seconds: Int) async {
        for remaining in (1...seconds).reversed() {
            retryState = .waiting(seconds: remaining)
            try? await Task.sleep(for: .seconds(1))
        }
    }
}
