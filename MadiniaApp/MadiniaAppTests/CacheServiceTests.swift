//
//  CacheServiceTests.swift
//  MadiniaAppTests
//
//  Tests for CacheService TTL, freshness, and invalidation functionality.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the CacheService
final class CacheServiceTests: XCTestCase {

    // MARK: - CacheContentType Tests

    /// Test TTL values for each content type
    func testContentTypeTTLValues() {
        // Formations: 24 hours
        XCTAssertEqual(CacheContentType.formations.ttl, 24 * 60 * 60)

        // Categories: 1 week
        XCTAssertEqual(CacheContentType.categories.ttl, 7 * 24 * 60 * 60)

        // Services: 24 hours
        XCTAssertEqual(CacheContentType.services.ttl, 24 * 60 * 60)

        // Articles: 6 hours
        XCTAssertEqual(CacheContentType.articles.ttl, 6 * 60 * 60)

        // Events: 2 hours
        XCTAssertEqual(CacheContentType.events.ttl, 2 * 60 * 60)
    }

    /// Test display names for content types
    func testContentTypeDisplayNames() {
        XCTAssertEqual(CacheContentType.formations.displayName, "Formations")
        XCTAssertEqual(CacheContentType.categories.displayName, "Catégories")
        XCTAssertEqual(CacheContentType.services.displayName, "Services")
        XCTAssertEqual(CacheContentType.articles.displayName, "Articles")
        XCTAssertEqual(CacheContentType.events.displayName, "Événements")
    }

    /// Test all content types are covered
    func testContentTypeAllCases() {
        XCTAssertEqual(CacheContentType.allCases.count, 5)
        XCTAssertTrue(CacheContentType.allCases.contains(.formations))
        XCTAssertTrue(CacheContentType.allCases.contains(.categories))
        XCTAssertTrue(CacheContentType.allCases.contains(.services))
        XCTAssertTrue(CacheContentType.allCases.contains(.articles))
        XCTAssertTrue(CacheContentType.allCases.contains(.events))
    }

    // MARK: - CacheFreshness Tests

    /// Test freshness color names
    func testFreshnessColorNames() {
        XCTAssertEqual(CacheFreshness.fresh.colorName, "green")
        XCTAssertEqual(CacheFreshness.stale.colorName, "orange")
        XCTAssertEqual(CacheFreshness.expired.colorName, "red")
        XCTAssertEqual(CacheFreshness.none.colorName, "gray")
    }

    /// Test freshness icons
    func testFreshnessIcons() {
        XCTAssertEqual(CacheFreshness.fresh.icon, "checkmark.circle.fill")
        XCTAssertEqual(CacheFreshness.stale.icon, "clock.fill")
        XCTAssertEqual(CacheFreshness.expired.icon, "exclamationmark.triangle.fill")
        XCTAssertEqual(CacheFreshness.none.icon, "questionmark.circle")
    }

    // MARK: - CacheMetadata Tests

    /// Test metadata freshness calculation - fresh
    func testMetadataFreshnessFresh() {
        // Data cached just now should be fresh
        let metadata = CacheMetadata(cachedAt: Date(), contentType: "formations")
        let freshness = metadata.freshness(for: .formations)
        XCTAssertEqual(freshness, .fresh)
    }

    /// Test metadata freshness calculation - stale
    func testMetadataFreshnessStale() {
        // Data cached at 60% of TTL should be stale
        let ttl = CacheContentType.formations.ttl
        let cachedAt = Date().addingTimeInterval(-ttl * 0.6)
        let metadata = CacheMetadata(cachedAt: cachedAt, contentType: "formations")
        let freshness = metadata.freshness(for: .formations)
        XCTAssertEqual(freshness, .stale)
    }

    /// Test metadata freshness calculation - expired
    func testMetadataFreshnessExpired() {
        // Data cached beyond TTL should be expired
        let ttl = CacheContentType.formations.ttl
        let cachedAt = Date().addingTimeInterval(-ttl * 1.5)
        let metadata = CacheMetadata(cachedAt: cachedAt, contentType: "formations")
        let freshness = metadata.freshness(for: .formations)
        XCTAssertEqual(freshness, .expired)
    }

    /// Test metadata age calculation
    func testMetadataAge() {
        let tenMinutesAgo = Date().addingTimeInterval(-600)
        let metadata = CacheMetadata(cachedAt: tenMinutesAgo, contentType: "test")
        // Age should be approximately 600 seconds (allow 1 second tolerance)
        XCTAssertEqual(metadata.age, 600, accuracy: 1)
    }

    /// Test metadata isExpired
    func testMetadataIsExpired() {
        // Fresh data
        let freshMetadata = CacheMetadata(cachedAt: Date(), contentType: "events")
        XCTAssertFalse(freshMetadata.isExpired(for: .events))

        // Expired data (events TTL is 2 hours)
        let expiredTime = Date().addingTimeInterval(-3 * 60 * 60) // 3 hours ago
        let expiredMetadata = CacheMetadata(cachedAt: expiredTime, contentType: "events")
        XCTAssertTrue(expiredMetadata.isExpired(for: .events))
    }

    /// Test metadata Codable conformance
    func testMetadataCodable() throws {
        let original = CacheMetadata(cachedAt: Date(), contentType: "formations")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(CacheMetadata.self, from: data)

        XCTAssertEqual(decoded.contentType, original.contentType)
        // Allow 1 second tolerance for date encoding/decoding
        XCTAssertEqual(
            decoded.cachedAt.timeIntervalSince1970,
            original.cachedAt.timeIntervalSince1970,
            accuracy: 1
        )
    }

    // MARK: - CacheService Singleton Tests

    /// Test CacheService shared instance exists
    func testCacheServiceSharedInstance() {
        let service = CacheService.shared
        XCTAssertNotNil(service)
    }

    /// Test CacheService formattedCacheSize returns valid string
    func testFormattedCacheSize() {
        let service = CacheService.shared
        let sizeString = service.formattedCacheSize
        // Should contain KB or MB or "Zero" depending on cache state
        XCTAssertFalse(sizeString.isEmpty)
    }

    // MARK: - TTL Boundary Tests

    /// Test freshness boundary at exactly 50% TTL
    func testFreshnessBoundaryAtHalfTTL() {
        let ttl = CacheContentType.articles.ttl
        // Just under 50% - should be fresh
        let justUnderHalf = Date().addingTimeInterval(-ttl * 0.49)
        let freshMetadata = CacheMetadata(cachedAt: justUnderHalf, contentType: "articles")
        XCTAssertEqual(freshMetadata.freshness(for: .articles), .fresh)

        // Just over 50% - should be stale
        let justOverHalf = Date().addingTimeInterval(-ttl * 0.51)
        let staleMetadata = CacheMetadata(cachedAt: justOverHalf, contentType: "articles")
        XCTAssertEqual(staleMetadata.freshness(for: .articles), .stale)
    }

    /// Test freshness boundary at exactly 100% TTL
    func testFreshnessBoundaryAtFullTTL() {
        let ttl = CacheContentType.events.ttl
        // Just under 100% - should be stale
        let justUnder = Date().addingTimeInterval(-ttl * 0.99)
        let staleMetadata = CacheMetadata(cachedAt: justUnder, contentType: "events")
        XCTAssertEqual(staleMetadata.freshness(for: .events), .stale)

        // Just over 100% - should be expired
        let justOver = Date().addingTimeInterval(-ttl * 1.01)
        let expiredMetadata = CacheMetadata(cachedAt: justOver, contentType: "events")
        XCTAssertEqual(expiredMetadata.freshness(for: .events), .expired)
    }

    // MARK: - Content Type Specific TTL Tests

    /// Test events have shortest TTL (time-sensitive)
    func testEventsShortestTTL() {
        let eventsTTL = CacheContentType.events.ttl
        let articlesTTL = CacheContentType.articles.ttl
        let formationsTTL = CacheContentType.formations.ttl
        let categoriesTTL = CacheContentType.categories.ttl

        XCTAssertLessThan(eventsTTL, articlesTTL)
        XCTAssertLessThan(eventsTTL, formationsTTL)
        XCTAssertLessThan(eventsTTL, categoriesTTL)
    }

    /// Test categories have longest TTL (rarely change)
    func testCategoriesLongestTTL() {
        let categoriesTTL = CacheContentType.categories.ttl
        let formationsTTL = CacheContentType.formations.ttl
        let articlesTTL = CacheContentType.articles.ttl
        let eventsTTL = CacheContentType.events.ttl

        XCTAssertGreaterThan(categoriesTTL, formationsTTL)
        XCTAssertGreaterThan(categoriesTTL, articlesTTL)
        XCTAssertGreaterThan(categoriesTTL, eventsTTL)
    }
}
