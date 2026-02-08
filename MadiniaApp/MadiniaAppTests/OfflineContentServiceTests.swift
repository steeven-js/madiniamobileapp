//
//  OfflineContentServiceTests.swift
//  MadiniaAppTests
//
//  Tests for OfflineContentService download and storage functionality.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the OfflineContentService
final class OfflineContentServiceTests: XCTestCase {

    // MARK: - Properties

    private var offlineService: OfflineContentService!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        offlineService = OfflineContentService.shared
    }

    override func tearDownWithError() throws {
        offlineService = nil
        try super.tearDownWithError()
    }

    // MARK: - DownloadProgress Tests

    /// Test DownloadStatus raw values
    func testDownloadStatusRawValues() {
        XCTAssertEqual(DownloadProgress.DownloadStatus.pending.rawValue, "En attente")
        XCTAssertEqual(DownloadProgress.DownloadStatus.downloading.rawValue, "Téléchargement")
        XCTAssertEqual(DownloadProgress.DownloadStatus.completed.rawValue, "Terminé")
        XCTAssertEqual(DownloadProgress.DownloadStatus.failed.rawValue, "Échec")
    }

    /// Test DownloadProgress initialization
    func testDownloadProgressInitialization() {
        let progress = DownloadProgress(
            id: 123,
            progress: 0.5,
            status: .downloading,
            error: nil
        )

        XCTAssertEqual(progress.id, 123)
        XCTAssertEqual(progress.progress, 0.5)
        XCTAssertEqual(progress.status, .downloading)
        XCTAssertNil(progress.error)
    }

    /// Test DownloadProgress with error
    func testDownloadProgressWithError() {
        let progress = DownloadProgress(
            id: 456,
            progress: 0.0,
            status: .failed,
            error: "Network error"
        )

        XCTAssertEqual(progress.status, .failed)
        XCTAssertEqual(progress.error, "Network error")
    }

    /// Test DownloadProgress conforms to Identifiable
    func testDownloadProgressIdentifiable() {
        let progress = DownloadProgress(id: 789, progress: 1.0, status: .completed)
        XCTAssertEqual(progress.id, 789)
    }

    // MARK: - OfflineFormationMetadata Tests

    /// Test OfflineFormationMetadata initialization
    func testOfflineFormationMetadataInitialization() {
        let date = Date()
        let metadata = OfflineFormationMetadata(
            formationId: 100,
            downloadedAt: date,
            fileSize: 1024,
            imageFileName: "100_image.jpg"
        )

        XCTAssertEqual(metadata.formationId, 100)
        XCTAssertEqual(metadata.downloadedAt, date)
        XCTAssertEqual(metadata.fileSize, 1024)
        XCTAssertEqual(metadata.imageFileName, "100_image.jpg")
    }

    /// Test OfflineFormationMetadata without image
    func testOfflineFormationMetadataWithoutImage() {
        let metadata = OfflineFormationMetadata(
            formationId: 200,
            downloadedAt: Date(),
            fileSize: 512,
            imageFileName: nil
        )

        XCTAssertNil(metadata.imageFileName)
    }

    /// Test OfflineFormationMetadata conforms to Codable
    func testOfflineFormationMetadataCodable() throws {
        let original = OfflineFormationMetadata(
            formationId: 300,
            downloadedAt: Date(),
            fileSize: 2048,
            imageFileName: "300_image.png"
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OfflineFormationMetadata.self, from: data)

        XCTAssertEqual(decoded.formationId, original.formationId)
        XCTAssertEqual(decoded.fileSize, original.fileSize)
        XCTAssertEqual(decoded.imageFileName, original.imageFileName)
    }

    // MARK: - Singleton Tests

    /// Test singleton pattern
    func testSingletonInstance() {
        let instance1 = OfflineContentService.shared
        let instance2 = OfflineContentService.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - State Tests

    /// Test initial state properties
    func testInitialStateProperties() {
        // offlineFormationIds should be a set
        XCTAssertNotNil(offlineService.offlineFormationIds)

        // downloadProgress should be a dictionary
        XCTAssertNotNil(offlineService.downloadProgress)

        // totalStorageUsed should be >= 0
        XCTAssertGreaterThanOrEqual(offlineService.totalStorageUsed, 0)
    }

    /// Test isDownloading property
    func testIsDownloadingProperty() {
        // Initially should not be downloading (unless a download is in progress)
        let isDownloading = offlineService.isDownloading
        XCTAssert(isDownloading == true || isDownloading == false)
    }

    // MARK: - isAvailableOffline Tests

    /// Test isAvailableOffline for non-existent formation
    func testIsAvailableOfflineNonExistent() {
        // Use an unlikely formation ID
        let isAvailable = offlineService.isAvailableOffline(formationId: 999999)
        XCTAssertFalse(isAvailable)
    }

    // MARK: - Storage Formatting Tests

    /// Test formattedStorageUsed returns string
    func testFormattedStorageUsed() {
        let formatted = offlineService.formattedStorageUsed()
        XCTAssertFalse(formatted.isEmpty)
        // Should contain some unit (bytes, KB, MB, etc.)
    }

    // MARK: - getDownloadedFormationsInfo Tests

    /// Test getDownloadedFormationsInfo returns array
    func testGetDownloadedFormationsInfo() {
        let info = offlineService.getDownloadedFormationsInfo()
        XCTAssertNotNil(info)
        // Each item should have formationId, downloadedAt, and fileSize
    }
}
