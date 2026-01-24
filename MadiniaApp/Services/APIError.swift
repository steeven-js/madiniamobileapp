//
//  APIError.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Enum representing all possible API errors.
/// Conforms to LocalizedError for user-friendly French error messages.
enum APIError: LocalizedError, Equatable {
    /// Network connectivity issue
    case networkError(String)

    /// JSON decoding failed
    case decodingError(String)

    /// Server returned an error status code
    case serverError(Int)

    /// Invalid URL provided
    case invalidURL

    /// No data received from server
    case noData

    /// Request timeout
    case timeout

    /// Unauthorized access (401)
    case unauthorized

    /// Resource not found (404)
    case notFound

    /// Bad request (400)
    case badRequest

    /// Forbidden access (403)
    case forbidden

    // MARK: - LocalizedError

    /// User-friendly error description in French
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Erreur de connexion. Vérifiez votre connexion internet."
        case .decodingError:
            return "Erreur lors du traitement des données."
        case .serverError(let code):
            return "Erreur serveur (code: \(code)). Réessayez plus tard."
        case .invalidURL:
            return "URL invalide."
        case .noData:
            return "Aucune donnée reçue du serveur."
        case .timeout:
            return "La requête a pris trop de temps. Réessayez."
        case .unauthorized:
            return "Accès non autorisé."
        case .notFound:
            return "Ressource non trouvée."
        case .badRequest:
            return "Requête invalide."
        case .forbidden:
            return "Accès interdit."
        }
    }

    /// Recovery suggestion for the user
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Vérifiez que vous êtes connecté à Internet et réessayez."
        case .serverError:
            return "Le serveur rencontre un problème. Réessayez dans quelques instants."
        case .timeout:
            return "Vérifiez votre connexion et réessayez."
        case .badRequest:
            return "Vérifiez les données envoyées et réessayez."
        case .forbidden:
            return "Vous n'avez pas les permissions nécessaires."
        default:
            return "Veuillez réessayer ou contacter le support si le problème persiste."
        }
    }

    // MARK: - Debug Description

    /// Technical description for debugging
    var debugDescription: String {
        switch self {
        case .networkError(let details):
            return "NetworkError: \(details)"
        case .decodingError(let details):
            return "DecodingError: \(details)"
        case .serverError(let code):
            return "ServerError: HTTP \(code)"
        case .invalidURL:
            return "InvalidURL"
        case .noData:
            return "NoData"
        case .timeout:
            return "Timeout"
        case .unauthorized:
            return "Unauthorized (401)"
        case .notFound:
            return "NotFound (404)"
        case .badRequest:
            return "BadRequest (400)"
        case .forbidden:
            return "Forbidden (403)"
        }
    }

    // MARK: - Retry Support

    /// Indicates whether this error type should trigger a retry attempt.
    /// Network errors, timeouts, and server errors (5xx) are retryable.
    /// Client errors (4xx) and decoding errors are not retryable.
    var isRetryable: Bool {
        switch self {
        case .networkError, .timeout:
            return true
        case .serverError(let code):
            return (500...599).contains(code)
        case .decodingError, .invalidURL, .noData, .unauthorized, .notFound, .badRequest, .forbidden:
            return false
        }
    }

    // MARK: - Factory Methods

    /// Creates appropriate APIError from URLError
    static func from(_ urlError: URLError) -> APIError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkError("Pas de connexion internet")
        case .timedOut:
            return .timeout
        case .cannotFindHost, .cannotConnectToHost:
            return .networkError("Serveur inaccessible")
        default:
            return .networkError(urlError.localizedDescription)
        }
    }

    /// Creates appropriate APIError from HTTP status code
    static func from(statusCode: Int) -> APIError? {
        switch statusCode {
        case 200...299:
            return nil // Success
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500...599:
            return .serverError(statusCode)
        default:
            // Other 4xx errors treated as bad request
            if (400...499).contains(statusCode) {
                return .badRequest
            }
            return .serverError(statusCode)
        }
    }
}
