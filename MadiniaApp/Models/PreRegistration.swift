//
//  PreRegistration.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import Foundation

/// Represents a user's pre-registration for a formation
struct PreRegistration: Codable, Identifiable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let formationId: Int
    let fundingMethod: String?
    let preferredFormat: String?
    let comments: String?
    let status: String
    let source: String?
    let deviceUUID: String?
    let createdAt: String?
    let formation: PreRegistrationFormation?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case formationId = "formation_id"
        case fundingMethod = "funding_method"
        case preferredFormat = "preferred_format"
        case comments
        case status
        case source
        case deviceUUID = "device_uuid"
        case createdAt = "created_at"
        case formation
    }

    /// Full name of the pre-registrant
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Formatted creation date
    var formattedDate: String {
        guard let dateStr = createdAt else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateStr) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateStr) else { return dateStr }
            return formatDate(date)
        }
        return formatDate(date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Status display label in French
    var statusLabel: String {
        switch status {
        case "en_attente":
            return "En attente"
        case "groupe_en_constitution":
            return "Groupe en constitution"
        case "groupe_complet":
            return "Groupe complet"
        case "session_planifiee":
            return "Session planifiée"
        case "inscrit":
            return "Inscrit"
        case "annule":
            return "Annulé"
        default:
            return status
        }
    }

    /// Funding method display label
    var fundingMethodLabel: String {
        switch fundingMethod {
        case "cpf":
            return "CPF"
        case "opco":
            return "OPCO"
        case "france_travail":
            return "France Travail"
        case "autofinancement":
            return "Autofinancement"
        case "autre":
            return "Autre"
        default:
            return fundingMethod ?? "Non spécifié"
        }
    }

    /// Preferred format display label
    var preferredFormatLabel: String {
        switch preferredFormat {
        case "presentiel":
            return "Présentiel"
        case "distanciel":
            return "Distanciel"
        case "hybride":
            return "Hybride"
        default:
            return preferredFormat ?? "Non spécifié"
        }
    }
}

/// Formation data embedded in pre-registration response
struct PreRegistrationFormation: Codable, Equatable {
    let id: Int
    let title: String
    let slug: String
    let duration: String?
    let level: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, duration, level
        case imageUrl = "image_url"
    }
}

// MARK: - API Response

/// API response for fetching pre-registrations list
struct PreRegistrationsListResponse: Decodable {
    let success: Bool
    let data: [PreRegistration]
    let count: Int
    let maxAllowed: Int

    enum CodingKeys: String, CodingKey {
        case success, data, count
        case maxAllowed = "max_allowed"
    }
}

/// API response for creating a pre-registration
struct PreRegistrationCreateResponse: Decodable {
    let success: Bool
    let message: String?
    let data: PreRegistration?
    let currentCount: Int?
    let maxAllowed: Int?
    let remaining: Int?
    let errorCode: String?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case currentCount = "current_count"
        case maxAllowed = "max_allowed"
        case remaining
        case errorCode = "error_code"
    }
}
