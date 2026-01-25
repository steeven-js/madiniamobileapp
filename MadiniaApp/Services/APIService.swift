//
//  APIService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

// MARK: - API Response Wrappers

/// Generic API response wrapper for list endpoints
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

/// API response for formation detail with related formations
struct FormationDetailResponse: Decodable {
    let success: Bool
    let data: Formation
    let related: [Formation]?
}

/// Request body for pre-registration submission
struct PreRegistrationRequest: Encodable {
    let email: String
    let formationId: Int

    enum CodingKeys: String, CodingKey {
        case email
        case formationId = "formation_id"
    }
}

/// API response for pre-registration submission
struct PreRegistrationResponse: Decodable {
    let success: Bool
    let message: String?
}

/// API response for article detail with related articles
struct ArticleDetailResponse: Decodable {
    let success: Bool
    let data: Article
    let related: [Article]?
}

/// Request payload for contact form submission
struct ContactRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let subject: String
    let message: String
    let context: String?
}

/// API response for contact form submission
struct ContactResponse: Decodable {
    let success: Bool
    let message: String?
}

/// Request payload for device token registration
struct DeviceTokenRequest: Encodable {
    let deviceToken: String
    let platform: String
    let appVersion: String
    let preferences: NotificationPreferences

    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
        case platform
        case appVersion = "app_version"
        case preferences
    }
}

// MARK: - API Service Protocol

/// Protocol defining the API service interface for testability
protocol APIServiceProtocol {
    /// Fetches all available formations from the API
    func fetchFormations() async throws -> [Formation]

    /// Fetches a single formation by slug
    func fetchFormation(slug: String) async throws -> Formation

    /// Fetches all formation categories from the API
    func fetchCategories() async throws -> [FormationCategory]

    /// Fetches all available services from the API
    func fetchServices() async throws -> [Service]

    /// Submits a pre-registration for a formation
    func submitPreRegistration(formationId: Int, email: String) async throws

    /// Fetches all published articles from the API
    func fetchArticles() async throws -> [Article]

    /// Fetches a single article by slug
    func fetchArticle(slug: String) async throws -> Article

    /// Submits a contact form message
    func submitContact(
        firstName: String,
        lastName: String,
        email: String,
        phone: String?,
        subject: String,
        message: String,
        context: String?
    ) async throws

    /// Registers a device token for push notifications
    func registerDeviceToken(token: String, preferences: NotificationPreferences) async throws
}

// MARK: - API Service Implementation

/// Main API service for communicating with the Madinia Laravel backend.
/// Uses async/await pattern exclusively for all network operations.
final class APIService: APIServiceProtocol {
    /// Shared singleton instance
    static let shared = APIService()

    /// Base URL for the Madinia API
    /// Using production API (local API doesn't have routes configured)
    private let baseURL = "https://madinia.fr/api/v1"

    /// URLSession for network requests (injectable for testing)
    private let session: URLSession

    /// JSON decoder configured for API responses
    private let decoder: JSONDecoder

    /// Maximum number of retry attempts for failed requests
    private let maxRetries = 3

    /// Base delay for exponential backoff (in seconds)
    private let baseRetryDelay: TimeInterval = 1.0

    /// API key for authenticated requests
    private let apiKey = "fuNvIPt3f0uglrWP4SV6n7FSzr1VwLnApSCb4KjzrUUs611k8GUjOF7HNPfAqWay"

    // MARK: - Initialization

    /// Creates an APIService with optional custom URLSession
    /// - Parameter session: URLSession to use for requests (defaults to .shared)
    init(session: URLSession = .shared) {
        self.session = session

        // Configure JSON decoder
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public API Methods

    /// Fetches all formations from the API
    /// - Returns: Array of Formation objects
    /// - Throws: APIError if the request fails
    func fetchFormations() async throws -> [Formation] {
        let response: APIResponse<[Formation]> = try await request(endpoint: "/formations")
        return response.data
    }

    /// Fetches a single formation by its slug
    /// - Parameter slug: The formation's URL slug
    /// - Returns: Formation object with full details
    /// - Throws: APIError if the request fails
    func fetchFormation(slug: String) async throws -> Formation {
        let response: FormationDetailResponse = try await request(endpoint: "/formations/\(slug)")
        return response.data
    }

    /// Fetches a single formation with related formations
    /// - Parameter slug: The formation's URL slug
    /// - Returns: Tuple of (Formation, [Formation]) with full details and related formations
    /// - Throws: APIError if the request fails
    func fetchFormationWithRelated(slug: String) async throws -> (formation: Formation, related: [Formation]) {
        let response: FormationDetailResponse = try await request(endpoint: "/formations/\(slug)")
        return (response.data, response.related ?? [])
    }

    /// Fetches all formation categories from the API
    /// - Returns: Array of FormationCategory objects with formation counts
    /// - Throws: APIError if the request fails
    func fetchCategories() async throws -> [FormationCategory] {
        let response: APIResponse<[FormationCategory]> = try await request(endpoint: "/categories")
        return response.data
    }

    /// Fetches all services from the API
    /// - Returns: Array of Service objects
    /// - Throws: APIError if the request fails
    func fetchServices() async throws -> [Service] {
        let response: APIResponse<[Service]> = try await request(endpoint: "/services")
        return response.data
    }

    /// Submits a pre-registration for a formation
    /// - Parameters:
    ///   - formationId: The formation's ID
    ///   - email: User's email address
    /// - Throws: APIError if the request fails
    func submitPreRegistration(formationId: Int, email: String) async throws {
        let body = PreRegistrationRequest(email: email, formationId: formationId)
        let _: PreRegistrationResponse = try await postRequest(endpoint: "/pre-registrations", body: body)
    }

    /// Fetches all published articles from the API
    /// - Returns: Array of Article objects
    /// - Throws: APIError if the request fails
    func fetchArticles() async throws -> [Article] {
        let response: APIResponse<[Article]> = try await request(endpoint: "/articles")
        return response.data
    }

    /// Fetches a single article by its slug
    /// - Parameter slug: The article's URL slug
    /// - Returns: Article object with full content
    /// - Throws: APIError if the request fails
    func fetchArticle(slug: String) async throws -> Article {
        let response: ArticleDetailResponse = try await request(endpoint: "/articles/\(slug)")
        return response.data
    }

    /// Submits a contact form message
    /// - Throws: APIError if the request fails
    func submitContact(
        firstName: String,
        lastName: String,
        email: String,
        phone: String?,
        subject: String,
        message: String,
        context: String?
    ) async throws {
        let body = ContactRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            subject: subject,
            message: message,
            context: context
        )
        let _: ContactResponse = try await postRequest(endpoint: "/contact", body: body)
    }

    /// Registers a device token for push notifications
    /// - Throws: APIError if the request fails
    func registerDeviceToken(token: String, preferences: NotificationPreferences) async throws {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let body = DeviceTokenRequest(
            deviceToken: token,
            platform: "ios",
            appVersion: appVersion,
            preferences: preferences
        )
        let _: ContactResponse = try await postRequest(endpoint: "/devices", body: body)
    }

    // MARK: - Private Helpers

    /// Generic request method for API calls with automatic retry on failure.
    ///
    /// This method implements exponential backoff retry logic as specified in the architecture:
    /// - Maximum 3 retry attempts
    /// - Exponential backoff: 1s, 2s, 4s delays between retries
    /// - Only retries on network errors and server errors (5xx)
    /// - Does not retry on client errors (4xx) or decoding errors
    ///
    /// - Parameters:
    ///   - endpoint: API endpoint path (e.g., "/formations")
    ///   - method: HTTP method (defaults to GET)
    /// - Returns: Decoded response of type T
    /// - Throws: APIError if all retry attempts fail
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET"
    ) async throws -> T {
        // Build URL
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        var lastError: APIError = .networkError("Unknown error")

        // Retry loop with exponential backoff
        for attempt in 0..<maxRetries {
            do {
                return try await executeRequest(request)
            } catch let error as APIError {
                lastError = error

                // Only retry on retryable errors (network, timeout, server errors)
                guard error.isRetryable else {
                    throw error
                }

                // Don't sleep after the last attempt
                if attempt < maxRetries - 1 {
                    let delay = baseRetryDelay * pow(2.0, Double(attempt))
                    #if DEBUG
                    print("Request failed (attempt \(attempt + 1)/\(maxRetries)). Retrying in \(delay)s...")
                    #endif
                    try await Task.sleep(for: .seconds(delay))
                }
            }
        }

        throw lastError
    }

    /// Generic POST request method for API calls with JSON body.
    /// - Parameters:
    ///   - endpoint: API endpoint path (e.g., "/pre-registrations")
    ///   - body: Encodable body to send as JSON
    /// - Returns: Decoded response of type T
    /// - Throws: APIError if the request fails
    private func postRequest<T: Decodable, B: Encodable>(
        endpoint: String,
        body: B
    ) async throws -> T {
        // Build URL
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        // Encode body
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        var lastError: APIError = .networkError("Unknown error")

        // Retry loop with exponential backoff
        for attempt in 0..<maxRetries {
            do {
                return try await executeRequest(request)
            } catch let error as APIError {
                lastError = error

                // Only retry on retryable errors (network, timeout, server errors)
                guard error.isRetryable else {
                    throw error
                }

                // Don't sleep after the last attempt
                if attempt < maxRetries - 1 {
                    let delay = baseRetryDelay * pow(2.0, Double(attempt))
                    #if DEBUG
                    print("POST request failed (attempt \(attempt + 1)/\(maxRetries)). Retrying in \(delay)s...")
                    #endif
                    try await Task.sleep(for: .seconds(delay))
                }
            }
        }

        throw lastError
    }

    /// Executes a single HTTP request without retry logic.
    /// - Parameter request: The URLRequest to execute
    /// - Returns: Decoded response of type T
    /// - Throws: APIError if the request fails
    private func executeRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            // Check status code
            if let error = APIError.from(statusCode: httpResponse.statusCode) {
                throw error
            }

            // Ensure we have data
            guard !data.isEmpty else {
                throw APIError.noData
            }

            // Decode response
            do {
                return try decoder.decode(T.self, from: data)
            } catch let decodingError {
                #if DEBUG
                print("Decoding error: \(decodingError)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString.prefix(1000))")
                }
                #endif
                throw APIError.decodingError(decodingError.localizedDescription)
            }

        } catch let error as APIError {
            throw error
        } catch let error as URLError {
            throw APIError.from(error)
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - Mock API Service for Previews

/// Mock API service that returns sample data without network calls.
/// Use for SwiftUI previews and testing.
final class MockAPIService: APIServiceProtocol {
    /// Simulated delay for loading states (in seconds)
    var simulatedDelay: TimeInterval = 0.5

    /// Whether to simulate an error
    var shouldFail = false

    /// Error to throw when shouldFail is true
    var errorToThrow: APIError = .networkError("Simulated error")

    func fetchFormations() async throws -> [Formation] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        return Formation.samples
    }

    func fetchFormation(slug: String) async throws -> Formation {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        return Formation.sample
    }

    func fetchCategories() async throws -> [FormationCategory] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        return [
            FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", description: nil, color: "#8B5CF6", icon: nil, formationsCount: 7),
            FormationCategory(id: 2, name: "Marketing Digital", slug: "marketing-digital", description: nil, color: "#EC4899", icon: nil, formationsCount: 5),
            FormationCategory(id: 3, name: "Business", slug: "business", description: nil, color: "#F59E0B", icon: nil, formationsCount: 12),
            FormationCategory(id: 4, name: "Technologie", slug: "technologie", description: nil, color: "#10B981", icon: nil, formationsCount: 3),
        ]
    }

    func fetchServices() async throws -> [Service] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        return Service.samples
    }

    func submitPreRegistration(formationId: Int, email: String) async throws {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        // Success - no return value needed
    }

    func fetchArticles() async throws -> [Article] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        return Article.samples
    }

    func fetchArticle(slug: String) async throws -> Article {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        return Article.sample
    }

    func submitContact(
        firstName: String,
        lastName: String,
        email: String,
        phone: String?,
        subject: String,
        message: String,
        context: String?
    ) async throws {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        // Success - no return value needed
    }

    func registerDeviceToken(token: String, preferences: NotificationPreferences) async throws {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if shouldFail {
            throw errorToThrow
        }

        // Success - no return value needed
    }
}
