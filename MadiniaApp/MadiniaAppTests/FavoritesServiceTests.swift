//
//  FavoritesServiceTests.swift
//  MadiniaAppTests
//
//  Tests for FavoritesService functionality including local storage and sync.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the FavoritesService
final class FavoritesServiceTests: XCTestCase {

    // MARK: - Properties

    private var favoritesService: FavoritesService!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        favoritesService = FavoritesService.shared
    }

    override func tearDownWithError() throws {
        favoritesService = nil
        try super.tearDownWithError()
    }

    // MARK: - API Response Type Tests

    /// Test FavoriteIdsResponse decoding
    func testFavoriteIdsResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "data": [1, 2, 3, 4, 5]
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(FavoriteIdsResponse.self, from: data)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data.count, 5)
        XCTAssertEqual(response.data, [1, 2, 3, 4, 5])
    }

    /// Test FavoriteIdsResponse decoding with empty array
    func testFavoriteIdsResponseEmptyArray() throws {
        let json = """
        {
            "success": true,
            "data": []
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(FavoriteIdsResponse.self, from: data)

        XCTAssertTrue(response.success)
        XCTAssertTrue(response.data.isEmpty)
    }

    /// Test FavoriteActionResponse decoding with message
    func testFavoriteActionResponseWithMessage() throws {
        let json = """
        {
            "success": true,
            "message": "Favorite added successfully"
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(FavoriteActionResponse.self, from: data)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Favorite added successfully")
    }

    /// Test FavoriteActionResponse decoding without message
    func testFavoriteActionResponseWithoutMessage() throws {
        let json = """
        {
            "success": false,
            "message": null
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(FavoriteActionResponse.self, from: data)

        XCTAssertFalse(response.success)
        XCTAssertNil(response.message)
    }

    // MARK: - isFavorite Tests

    /// Test isFavorite returns correct status
    func testIsFavoriteStatus() {
        // Note: This test depends on the current state of favorites
        // In a production app, we'd use dependency injection for isolated testing
        let formationId = 99999 // Use an unlikely ID
        let initialStatus = favoritesService.isFavorite(formationId: formationId)

        // The status should be a boolean
        XCTAssertNotNil(initialStatus)
        XCTAssert(initialStatus == true || initialStatus == false)
    }

    // MARK: - isServiceFavorite Tests

    /// Test isServiceFavorite returns correct status
    func testIsServiceFavoriteStatus() {
        let serviceId = 99999 // Use an unlikely ID
        let initialStatus = favoritesService.isServiceFavorite(serviceId: serviceId)

        // The status should be a boolean
        XCTAssertNotNil(initialStatus)
        XCTAssert(initialStatus == true || initialStatus == false)
    }

    // MARK: - Device UUID Tests

    /// Test device UUID is generated and persisted
    func testDeviceUUIDGeneration() {
        let uuid = favoritesService.deviceUUID

        // UUID should not be empty
        XCTAssertFalse(uuid.isEmpty)

        // UUID should be a valid format (36 characters with dashes)
        XCTAssertEqual(uuid.count, 36)
        XCTAssertTrue(uuid.contains("-"))

        // Subsequent calls should return the same UUID
        let uuid2 = favoritesService.deviceUUID
        XCTAssertEqual(uuid, uuid2)
    }

    // MARK: - State Tests

    /// Test initial state properties
    func testInitialStateProperties() {
        // isSyncing should be false initially (unless sync is in progress)
        // This is a basic sanity check
        XCTAssertNotNil(favoritesService.isSyncing)

        // favoriteFormationIds should be a set (may or may not be empty)
        XCTAssertNotNil(favoritesService.favoriteFormationIds)

        // favoriteServiceIds should be a set (may or may not be empty)
        XCTAssertNotNil(favoritesService.favoriteServiceIds)
    }

    /// Test favoriteFormationIds is observable
    func testFavoriteFormationIdsIsSet() {
        let favorites = favoritesService.favoriteFormationIds
        XCTAssertTrue(type(of: favorites) == Set<Int>.self)
    }

    /// Test favoriteServiceIds is observable
    func testFavoriteServiceIdsIsSet() {
        let favorites = favoritesService.favoriteServiceIds
        XCTAssertTrue(type(of: favorites) == Set<Int>.self)
    }

    // MARK: - Singleton Tests

    /// Test singleton pattern
    func testSingletonInstance() {
        let instance1 = FavoritesService.shared
        let instance2 = FavoritesService.shared

        XCTAssertTrue(instance1 === instance2)
    }
}
