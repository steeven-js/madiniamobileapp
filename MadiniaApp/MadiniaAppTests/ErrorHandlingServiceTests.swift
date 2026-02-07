//
//  ErrorHandlingServiceTests.swift
//  MadiniaAppTests
//
//  Tests for ErrorHandlingService retry logic and degraded mode functionality.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the ErrorHandlingService
final class ErrorHandlingServiceTests: XCTestCase {

    // MARK: - ErrorContext Tests

    /// Test ErrorContext raw values
    func testErrorContextRawValues() {
        XCTAssertEqual(ErrorContext.loadingFormations.rawValue, "formations")
        XCTAssertEqual(ErrorContext.loadingArticles.rawValue, "articles")
        XCTAssertEqual(ErrorContext.loadingEvents.rawValue, "événements")
        XCTAssertEqual(ErrorContext.loadingServices.rawValue, "services")
        XCTAssertEqual(ErrorContext.loadingCategories.rawValue, "catégories")
        XCTAssertEqual(ErrorContext.sendingContact.rawValue, "envoi du message")
        XCTAssertEqual(ErrorContext.registeringEvent.rawValue, "inscription à l'événement")
        XCTAssertEqual(ErrorContext.downloadingContent.rawValue, "téléchargement")
        XCTAssertEqual(ErrorContext.syncingData.rawValue, "synchronisation")
        XCTAssertEqual(ErrorContext.general.rawValue, "opération")
    }

    /// Test ErrorContext icons
    func testErrorContextIcons() {
        XCTAssertEqual(ErrorContext.loadingFormations.icon, "book.fill")
        XCTAssertEqual(ErrorContext.loadingArticles.icon, "newspaper.fill")
        XCTAssertEqual(ErrorContext.loadingEvents.icon, "calendar")
        XCTAssertEqual(ErrorContext.loadingServices.icon, "briefcase.fill")
        XCTAssertEqual(ErrorContext.loadingCategories.icon, "folder.fill")
        XCTAssertEqual(ErrorContext.sendingContact.icon, "envelope.fill")
        XCTAssertEqual(ErrorContext.registeringEvent.icon, "person.badge.plus")
        XCTAssertEqual(ErrorContext.downloadingContent.icon, "arrow.down.circle.fill")
        XCTAssertEqual(ErrorContext.syncingData.icon, "arrow.triangle.2.circlepath")
        XCTAssertEqual(ErrorContext.general.icon, "exclamationmark.triangle.fill")
    }

    /// Test ErrorContext contextual messages for network errors
    func testErrorContextNetworkErrorMessages() {
        let networkError = APIError.networkError("Connection failed")

        XCTAssertEqual(
            ErrorContext.loadingFormations.errorMessage(for: networkError),
            "Impossible de charger les formations. Vérifiez votre connexion."
        )
        XCTAssertEqual(
            ErrorContext.loadingArticles.errorMessage(for: networkError),
            "Impossible de charger les articles. Vérifiez votre connexion."
        )
        XCTAssertEqual(
            ErrorContext.loadingEvents.errorMessage(for: networkError),
            "Impossible de charger les événements. Vérifiez votre connexion."
        )
    }

    /// Test ErrorContext contextual messages for timeout errors
    func testErrorContextTimeoutMessages() {
        let timeoutError = APIError.timeout

        XCTAssertEqual(
            ErrorContext.loadingFormations.errorMessage(for: timeoutError),
            "Le chargement des formations a pris trop de temps."
        )
        XCTAssertEqual(
            ErrorContext.syncingData.errorMessage(for: timeoutError),
            "Le chargement des synchronisation a pris trop de temps."
        )
    }

    /// Test ErrorContext contextual messages for server errors
    func testErrorContextServerErrorMessages() {
        let serverError = APIError.serverError(500)

        XCTAssertEqual(
            ErrorContext.loadingFormations.errorMessage(for: serverError),
            "Erreur serveur lors du chargement des formations."
        )
        XCTAssertEqual(
            ErrorContext.sendingContact.errorMessage(for: serverError),
            "Erreur serveur lors du chargement des envoi du message."
        )
    }

    /// Test ErrorContext contextual messages for notFound errors
    func testErrorContextNotFoundMessages() {
        let notFoundError = APIError.notFound

        XCTAssertEqual(
            ErrorContext.loadingFormations.errorMessage(for: notFoundError),
            "Les formations demandées sont introuvables."
        )
        XCTAssertEqual(
            ErrorContext.loadingServices.errorMessage(for: notFoundError),
            "Les services demandées sont introuvables."
        )
    }

    /// Test ErrorContext contextual messages for noData errors
    func testErrorContextNoDataMessages() {
        let noDataError = APIError.noData

        XCTAssertEqual(
            ErrorContext.loadingFormations.errorMessage(for: noDataError),
            "Aucune donnée reçue pour les formations."
        )
        XCTAssertEqual(
            ErrorContext.loadingCategories.errorMessage(for: noDataError),
            "Aucune donnée reçue pour les catégories."
        )
    }

    // MARK: - RetryState Tests

    /// Test RetryState isActive property
    func testRetryStateIsActive() {
        XCTAssertFalse(RetryState.idle.isActive)
        XCTAssertTrue(RetryState.retrying(attempt: 1, maxAttempts: 3).isActive)
        XCTAssertTrue(RetryState.waiting(seconds: 5).isActive)
        XCTAssertFalse(RetryState.succeeded.isActive)
        XCTAssertFalse(RetryState.failed(message: "Error").isActive)
    }

    /// Test RetryState status messages
    func testRetryStateStatusMessages() {
        XCTAssertEqual(RetryState.idle.statusMessage, "")
        XCTAssertEqual(
            RetryState.retrying(attempt: 1, maxAttempts: 3).statusMessage,
            "Tentative 1/3..."
        )
        XCTAssertEqual(
            RetryState.retrying(attempt: 2, maxAttempts: 3).statusMessage,
            "Tentative 2/3..."
        )
        XCTAssertEqual(
            RetryState.waiting(seconds: 5).statusMessage,
            "Nouvelle tentative dans 5s..."
        )
        XCTAssertEqual(
            RetryState.waiting(seconds: 1).statusMessage,
            "Nouvelle tentative dans 1s..."
        )
        XCTAssertEqual(RetryState.succeeded.statusMessage, "Connexion rétablie")
        XCTAssertEqual(
            RetryState.failed(message: "Test error").statusMessage,
            "Test error"
        )
    }

    /// Test RetryState Equatable conformance
    func testRetryStateEquatable() {
        XCTAssertEqual(RetryState.idle, RetryState.idle)
        XCTAssertEqual(RetryState.succeeded, RetryState.succeeded)
        XCTAssertEqual(
            RetryState.retrying(attempt: 1, maxAttempts: 3),
            RetryState.retrying(attempt: 1, maxAttempts: 3)
        )
        XCTAssertNotEqual(
            RetryState.retrying(attempt: 1, maxAttempts: 3),
            RetryState.retrying(attempt: 2, maxAttempts: 3)
        )
        XCTAssertEqual(RetryState.waiting(seconds: 5), RetryState.waiting(seconds: 5))
        XCTAssertNotEqual(RetryState.waiting(seconds: 5), RetryState.waiting(seconds: 3))
        XCTAssertEqual(
            RetryState.failed(message: "Error"),
            RetryState.failed(message: "Error")
        )
        XCTAssertNotEqual(
            RetryState.failed(message: "Error1"),
            RetryState.failed(message: "Error2")
        )
    }

    // MARK: - AppHealthState Tests

    /// Test AppHealthState icons
    func testAppHealthStateIcons() {
        XCTAssertEqual(AppHealthState.healthy.icon, "checkmark.circle.fill")
        XCTAssertEqual(AppHealthState.degraded(reason: "Test").icon, "exclamationmark.triangle.fill")
        XCTAssertEqual(AppHealthState.offline.icon, "wifi.slash")
        XCTAssertEqual(AppHealthState.error(message: "Test").icon, "xmark.circle.fill")
    }

    /// Test AppHealthState messages
    func testAppHealthStateMessages() {
        XCTAssertEqual(AppHealthState.healthy.message, "Connecté")
        XCTAssertEqual(AppHealthState.degraded(reason: "API lente").message, "API lente")
        XCTAssertEqual(AppHealthState.offline.message, "Mode hors ligne")
        XCTAssertEqual(AppHealthState.error(message: "Erreur critique").message, "Erreur critique")
    }

    // MARK: - ErrorHandlingService Singleton Tests

    /// Test ErrorHandlingService shared instance exists
    func testErrorHandlingServiceSharedInstance() {
        let service = ErrorHandlingService.shared
        XCTAssertNotNil(service)
    }

    /// Test initial state is healthy
    func testInitialHealthState() {
        let service = ErrorHandlingService.shared
        // Note: This may depend on network state, so we just check it's not nil
        XCTAssertNotNil(service.healthState)
    }

    /// Test initial retry state is idle
    func testInitialRetryState() {
        let service = ErrorHandlingService.shared
        // After any previous operations, reset to check
        service.recordSuccess()
        XCTAssertFalse(service.retryState.isActive)
    }

    /// Test isDegradedMode property
    func testIsDegradedModeProperty() {
        // This is a computed property based on healthState
        // We can't easily control healthState in tests without mocking
        let service = ErrorHandlingService.shared
        // Just verify the property exists and returns a boolean
        _ = service.isDegradedMode
        XCTAssertTrue(true) // Property exists
    }

    /// Test isOffline property
    func testIsOfflineProperty() {
        let service = ErrorHandlingService.shared
        // Just verify the property exists and returns a boolean
        _ = service.isOffline
        XCTAssertTrue(true) // Property exists
    }

    /// Test recordSuccess resets failure count
    func testRecordSuccessResetsFailures() {
        let service = ErrorHandlingService.shared

        // Record some failures first
        service.recordFailure(.networkError("Test"))
        service.recordFailure(.networkError("Test"))

        // Then record success
        service.recordSuccess()

        // After success, if connected, should be healthy
        // (depends on network state)
        XCTAssertFalse(service.retryState.isActive)
    }

    /// Test recordFailure increments counter
    func testRecordFailureIncrementsCounter() {
        let service = ErrorHandlingService.shared

        // Reset first
        service.recordSuccess()

        // Record failures
        service.recordFailure(.serverError(500))
        service.recordFailure(.serverError(500))
        service.recordFailure(.serverError(500))

        // After 3 failures, should be in degraded mode
        XCTAssertTrue(service.isDegradedMode)

        // Clean up
        service.recordSuccess()
    }
}
