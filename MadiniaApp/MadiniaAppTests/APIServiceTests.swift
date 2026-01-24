//
//  APIServiceTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the APIService
final class APIServiceTests: XCTestCase {

    // MARK: - APIError Tests

    /// Test APIError user-friendly messages are in French
    func testAPIErrorMessagesAreFrench() {
        XCTAssertEqual(
            APIError.networkError("test").errorDescription,
            "Erreur de connexion. Vérifiez votre connexion internet."
        )
        XCTAssertEqual(
            APIError.decodingError("test").errorDescription,
            "Erreur lors du traitement des données."
        )
        XCTAssertEqual(
            APIError.serverError(500).errorDescription,
            "Erreur serveur (code: 500). Réessayez plus tard."
        )
        XCTAssertEqual(
            APIError.invalidURL.errorDescription,
            "URL invalide."
        )
        XCTAssertEqual(
            APIError.noData.errorDescription,
            "Aucune donnée reçue du serveur."
        )
        XCTAssertEqual(
            APIError.timeout.errorDescription,
            "La requête a pris trop de temps. Réessayez."
        )
        XCTAssertEqual(
            APIError.unauthorized.errorDescription,
            "Accès non autorisé."
        )
        XCTAssertEqual(
            APIError.notFound.errorDescription,
            "Ressource non trouvée."
        )
    }

    /// Test APIError factory from status code
    func testAPIErrorFromStatusCode() {
        // Success codes should return nil
        XCTAssertNil(APIError.from(statusCode: 200))
        XCTAssertNil(APIError.from(statusCode: 201))
        XCTAssertNil(APIError.from(statusCode: 204))

        // Client error codes
        XCTAssertEqual(APIError.from(statusCode: 400), .badRequest)
        XCTAssertEqual(APIError.from(statusCode: 401), .unauthorized)
        XCTAssertEqual(APIError.from(statusCode: 403), .forbidden)
        XCTAssertEqual(APIError.from(statusCode: 404), .notFound)
        XCTAssertEqual(APIError.from(statusCode: 422), .badRequest) // Other 4xx → badRequest

        // Server error codes
        XCTAssertEqual(APIError.from(statusCode: 500), .serverError(500))
        XCTAssertEqual(APIError.from(statusCode: 503), .serverError(503))
    }

    /// Test APIError debug descriptions
    func testAPIErrorDebugDescription() {
        XCTAssertEqual(APIError.networkError("test").debugDescription, "NetworkError: test")
        XCTAssertEqual(APIError.decodingError("parse failed").debugDescription, "DecodingError: parse failed")
        XCTAssertEqual(APIError.serverError(500).debugDescription, "ServerError: HTTP 500")
        XCTAssertEqual(APIError.invalidURL.debugDescription, "InvalidURL")
        XCTAssertEqual(APIError.unauthorized.debugDescription, "Unauthorized (401)")
        XCTAssertEqual(APIError.notFound.debugDescription, "NotFound (404)")
        XCTAssertEqual(APIError.badRequest.debugDescription, "BadRequest (400)")
        XCTAssertEqual(APIError.forbidden.debugDescription, "Forbidden (403)")
    }

    /// Test APIError isRetryable property
    func testAPIErrorIsRetryable() {
        // Retryable errors
        XCTAssertTrue(APIError.networkError("test").isRetryable)
        XCTAssertTrue(APIError.timeout.isRetryable)
        XCTAssertTrue(APIError.serverError(500).isRetryable)
        XCTAssertTrue(APIError.serverError(503).isRetryable)

        // Non-retryable errors
        XCTAssertFalse(APIError.decodingError("test").isRetryable)
        XCTAssertFalse(APIError.invalidURL.isRetryable)
        XCTAssertFalse(APIError.noData.isRetryable)
        XCTAssertFalse(APIError.unauthorized.isRetryable)
        XCTAssertFalse(APIError.notFound.isRetryable)
        XCTAssertFalse(APIError.badRequest.isRetryable)
        XCTAssertFalse(APIError.forbidden.isRetryable)
    }

    /// Test APIError Equatable conformance
    func testAPIErrorEquatable() {
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
        XCTAssertEqual(APIError.noData, APIError.noData)
        XCTAssertEqual(APIError.serverError(500), APIError.serverError(500))
        XCTAssertNotEqual(APIError.serverError(500), APIError.serverError(404))
        XCTAssertEqual(APIError.networkError("test"), APIError.networkError("test"))
    }

    // MARK: - LoadingState Tests

    /// Test LoadingState isLoading property
    func testLoadingStateIsLoading() {
        let idle: LoadingState<[Formation]> = .idle
        let loading: LoadingState<[Formation]> = .loading
        let loaded: LoadingState<[Formation]> = .loaded([])
        let error: LoadingState<[Formation]> = .error("Error")

        XCTAssertFalse(idle.isLoading)
        XCTAssertTrue(loading.isLoading)
        XCTAssertFalse(loaded.isLoading)
        XCTAssertFalse(error.isLoading)
    }

    /// Test LoadingState value property
    func testLoadingStateValue() {
        let formations = Formation.samples
        let loaded: LoadingState<[Formation]> = .loaded(formations)
        let idle: LoadingState<[Formation]> = .idle

        XCTAssertEqual(loaded.value?.count, formations.count)
        XCTAssertNil(idle.value)
    }

    /// Test LoadingState errorMessage property
    func testLoadingStateErrorMessage() {
        let error: LoadingState<[Formation]> = .error("Test error")
        let loaded: LoadingState<[Formation]> = .loaded([])

        XCTAssertEqual(error.errorMessage, "Test error")
        XCTAssertNil(loaded.errorMessage)
    }

    /// Test LoadingState isIdle property
    func testLoadingStateIsIdle() {
        let idle: LoadingState<[Formation]> = .idle
        let loading: LoadingState<[Formation]> = .loading

        XCTAssertTrue(idle.isIdle)
        XCTAssertFalse(loading.isIdle)
    }

    /// Test LoadingState isCompleted property
    func testLoadingStateIsCompleted() {
        let idle: LoadingState<[Formation]> = .idle
        let loading: LoadingState<[Formation]> = .loading
        let loaded: LoadingState<[Formation]> = .loaded([])
        let error: LoadingState<[Formation]> = .error("Error")

        XCTAssertFalse(idle.isCompleted)
        XCTAssertFalse(loading.isCompleted)
        XCTAssertTrue(loaded.isCompleted)
        XCTAssertTrue(error.isCompleted)
    }

    /// Test LoadingState Equatable conformance
    func testLoadingStateEquatable() {
        let state1: LoadingState<String> = .loaded("test")
        let state2: LoadingState<String> = .loaded("test")
        let state3: LoadingState<String> = .loaded("different")

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
        XCTAssertEqual(LoadingState<String>.idle, LoadingState<String>.idle)
        XCTAssertEqual(LoadingState<String>.loading, LoadingState<String>.loading)
        XCTAssertEqual(LoadingState<String>.error("msg"), LoadingState<String>.error("msg"))
    }

    // MARK: - MockAPIService Tests

    /// Test MockAPIService returns sample data
    func testMockAPIServiceReturnsSampleData() async throws {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0 // No delay for tests

        let formations = try await mockService.fetchFormations()

        XCTAssertEqual(formations.count, Formation.samples.count)
        XCTAssertEqual(formations.first?.id, Formation.samples.first?.id)
    }

    /// Test MockAPIService can simulate failure
    func testMockAPIServiceCanFail() async {
        let mockService = MockAPIService()
        mockService.simulatedDelay = 0
        mockService.shouldFail = true
        mockService.errorToThrow = .serverError(500)

        do {
            _ = try await mockService.fetchFormations()
            XCTFail("Should have thrown an error")
        } catch let error as APIError {
            XCTAssertEqual(error, .serverError(500))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - APIService Configuration Tests

    /// Test APIService shared instance exists
    func testAPIServiceSharedInstance() {
        let service = APIService.shared
        XCTAssertNotNil(service)
    }
}
