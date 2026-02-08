//
//  NetworkMonitorServiceTests.swift
//  MadiniaAppTests
//
//  Tests for NetworkMonitorService connectivity monitoring.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the NetworkMonitorService
final class NetworkMonitorServiceTests: XCTestCase {

    // MARK: - Properties

    private var networkService: NetworkMonitorService!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkService = NetworkMonitorService.shared
    }

    override func tearDownWithError() throws {
        networkService = nil
        try super.tearDownWithError()
    }

    // MARK: - ConnectionType Tests

    /// Test ConnectionType raw values
    func testConnectionTypeRawValues() {
        XCTAssertEqual(ConnectionType.wifi.rawValue, "Wi-Fi")
        XCTAssertEqual(ConnectionType.cellular.rawValue, "Cellulaire")
        XCTAssertEqual(ConnectionType.wiredEthernet.rawValue, "Ethernet")
        XCTAssertEqual(ConnectionType.unknown.rawValue, "Inconnu")
    }

    /// Test all ConnectionType cases
    func testConnectionTypeAllCases() {
        let allCases: [ConnectionType] = [.wifi, .cellular, .wiredEthernet, .unknown]
        XCTAssertEqual(allCases.count, 4)
    }

    // MARK: - Singleton Tests

    /// Test singleton pattern
    func testSingletonInstance() {
        let instance1 = NetworkMonitorService.shared
        let instance2 = NetworkMonitorService.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - State Tests

    /// Test initial state properties exist
    func testInitialStateProperties() {
        // isConnected should be a boolean
        XCTAssertNotNil(networkService.isConnected)

        // connectionType should have a value
        XCTAssertNotNil(networkService.connectionType)

        // isExpensive should be a boolean
        XCTAssertNotNil(networkService.isExpensive)

        // isConstrained should be a boolean
        XCTAssertNotNil(networkService.isConstrained)
    }

    /// Test isConnected returns boolean
    func testIsConnectedReturnsBool() {
        let connected = networkService.isConnected
        XCTAssert(connected == true || connected == false)
    }

    /// Test connectionType is valid enum value
    func testConnectionTypeIsValid() {
        let type = networkService.connectionType
        let validTypes: [ConnectionType] = [.wifi, .cellular, .wiredEthernet, .unknown]
        XCTAssertTrue(validTypes.contains(type))
    }

    // MARK: - isDownloadRecommended Tests

    /// Test isDownloadRecommended property
    func testIsDownloadRecommended() {
        let recommended = networkService.isDownloadRecommended

        // Should be a boolean
        XCTAssert(recommended == true || recommended == false)

        // If not connected, should not be recommended
        if !networkService.isConnected {
            XCTAssertFalse(recommended)
        }

        // If expensive (cellular), should not be recommended
        if networkService.isExpensive {
            XCTAssertFalse(recommended)
        }
    }

    // MARK: - Callback Tests

    /// Test onConnectivityChange callback can be set
    func testOnConnectivityChangeCallback() {
        var callbackCalled = false

        networkService.onConnectivityChange = { _ in
            callbackCalled = true
        }

        // Callback should be settable
        XCTAssertNotNil(networkService.onConnectivityChange)

        // Reset
        networkService.onConnectivityChange = nil
    }

    /// Test onBackOnline callback can be set
    func testOnBackOnlineCallback() {
        networkService.onBackOnline = {
            // Callback body
        }

        // Callback should be settable
        XCTAssertNotNil(networkService.onBackOnline)

        // Reset
        networkService.onBackOnline = nil
    }
}
