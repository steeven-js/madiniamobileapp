//
//  SyncQueueServiceTests.swift
//  MadiniaAppTests
//
//  Tests for SyncQueueService offline operation queuing and sync.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the SyncQueueService
final class SyncQueueServiceTests: XCTestCase {

    // MARK: - Properties

    private var syncService: SyncQueueService!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        syncService = SyncQueueService.shared
    }

    override func tearDownWithError() throws {
        syncService = nil
        try super.tearDownWithError()
    }

    // MARK: - PendingOperationType Tests

    /// Test PendingOperationType raw values
    func testPendingOperationTypeRawValues() {
        XCTAssertEqual(PendingOperationType.addFavorite.rawValue, "add_favorite")
        XCTAssertEqual(PendingOperationType.removeFavorite.rawValue, "remove_favorite")
        XCTAssertEqual(PendingOperationType.addServiceFavorite.rawValue, "add_service_favorite")
        XCTAssertEqual(PendingOperationType.removeServiceFavorite.rawValue, "remove_service_favorite")
        XCTAssertEqual(PendingOperationType.registerEvent.rawValue, "register_event")
        XCTAssertEqual(PendingOperationType.unregisterEvent.rawValue, "unregister_event")
    }

    /// Test all operation types
    func testAllOperationTypes() {
        let types: [PendingOperationType] = [
            .addFavorite,
            .removeFavorite,
            .addServiceFavorite,
            .removeServiceFavorite,
            .registerEvent,
            .unregisterEvent
        ]
        XCTAssertEqual(types.count, 6)
    }

    // MARK: - PendingOperation Tests

    /// Test PendingOperation initialization
    func testPendingOperationInitialization() {
        let payload = ["formationId": "123"]
        let operation = PendingOperation(type: .addFavorite, payload: payload)

        XCTAssertEqual(operation.type, .addFavorite)
        XCTAssertEqual(operation.payload["formationId"], "123")
        XCTAssertEqual(operation.retryCount, 0)
        XCTAssertNotNil(operation.id)
        XCTAssertNotNil(operation.createdAt)
    }

    /// Test PendingOperation has unique ID
    func testPendingOperationUniqueId() {
        let op1 = PendingOperation(type: .addFavorite, payload: [:])
        let op2 = PendingOperation(type: .addFavorite, payload: [:])

        XCTAssertNotEqual(op1.id, op2.id)
    }

    /// Test PendingOperation conforms to Identifiable
    func testPendingOperationIdentifiable() {
        let operation = PendingOperation(type: .removeFavorite, payload: ["formationId": "456"])

        // Identifiable requires id property
        XCTAssertNotNil(operation.id)
    }

    /// Test PendingOperation conforms to Codable
    func testPendingOperationCodable() throws {
        let original = PendingOperation(
            type: .registerEvent,
            payload: ["eventId": "789"]
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PendingOperation.self, from: data)

        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.payload, original.payload)
        XCTAssertEqual(decoded.retryCount, original.retryCount)
        XCTAssertEqual(decoded.id, original.id)
    }

    // MARK: - Singleton Tests

    /// Test singleton pattern
    func testSingletonInstance() {
        let instance1 = SyncQueueService.shared
        let instance2 = SyncQueueService.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - State Tests

    /// Test initial state properties
    func testInitialStateProperties() {
        // pendingCount should be >= 0
        XCTAssertGreaterThanOrEqual(syncService.pendingCount, 0)

        // isSyncing should be false initially
        XCTAssertFalse(syncService.isSyncing)
    }

    /// Test getPendingOperations returns array
    func testGetPendingOperations() {
        let operations = syncService.getPendingOperations()
        XCTAssertNotNil(operations)
        XCTAssertTrue(type(of: operations) == [PendingOperation].self)
    }

    // MARK: - SyncError Tests

    /// Test SyncError error descriptions
    func testSyncErrorDescriptions() {
        XCTAssertEqual(SyncError.invalidPayload.errorDescription, "Données invalides")
        XCTAssertEqual(SyncError.invalidURL.errorDescription, "URL invalide")
        XCTAssertEqual(SyncError.serverError.errorDescription, "Erreur serveur")
        XCTAssertEqual(SyncError.networkError.errorDescription, "Erreur réseau")
    }

    /// Test SyncError conforms to LocalizedError
    func testSyncErrorConformsToLocalizedError() {
        let error: LocalizedError = SyncError.serverError
        XCTAssertNotNil(error.errorDescription)
    }
}
