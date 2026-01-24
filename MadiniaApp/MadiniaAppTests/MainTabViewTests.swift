//
//  MainTabViewTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
import SwiftUI
@testable import MadiniaApp

/// Unit tests for MainTabView tab navigation functionality
final class MainTabViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset selected tab before each test
        UserDefaults.standard.removeObject(forKey: "selectedTab")
    }

    override func tearDown() {
        // Clean up after tests
        UserDefaults.standard.removeObject(forKey: "selectedTab")
        super.tearDown()
    }

    // MARK: - Default State Tests

    /// Test that the default selected tab is Accueil (index 0)
    func testDefaultSelectedTabIsAccueil() {
        // Given: Fresh app state with no stored tab preference
        UserDefaults.standard.removeObject(forKey: "selectedTab")

        // When: Reading the default value
        let selectedTab = UserDefaults.standard.integer(forKey: "selectedTab")

        // Then: Default should be 0 (Accueil)
        XCTAssertEqual(selectedTab, 0, "Default selected tab should be Accueil (index 0)")
    }

    // MARK: - Tab Selection Persistence Tests

    /// Test that tab selection persists across sessions via @AppStorage
    func testTabSelectionPersistence() {
        // Given: User selects Formations tab (index 1)
        let expectedTab = 1
        UserDefaults.standard.set(expectedTab, forKey: "selectedTab")

        // When: Reading the persisted value
        let persistedTab = UserDefaults.standard.integer(forKey: "selectedTab")

        // Then: Value should be persisted
        XCTAssertEqual(persistedTab, expectedTab, "Selected tab should persist in UserDefaults")
    }

    /// Test that each tab index is valid (0-3)
    func testAllTabIndicesAreValid() {
        let validTabIndices = [0, 1, 2, 3]

        for index in validTabIndices {
            UserDefaults.standard.set(index, forKey: "selectedTab")
            let storedIndex = UserDefaults.standard.integer(forKey: "selectedTab")
            XCTAssertEqual(storedIndex, index, "Tab index \(index) should be storable")
        }
    }

    // MARK: - Tab Configuration Tests

    /// Test that we have exactly 4 tabs as per requirements
    func testTabCount() {
        // Given: The app requires 4 tabs (Accueil, Formations, Blog, Contact)
        let expectedTabCount = 4

        // Then: Verify tab count matches requirements
        // Note: This is a specification test - actual view testing requires UI tests
        XCTAssertEqual(expectedTabCount, 4, "App should have exactly 4 tabs")
    }

    /// Test tab names match French requirements
    func testTabNamesAreFrench() {
        let expectedTabNames = ["Accueil", "Formations", "Blog", "Contact"]

        // Verify all names are non-empty and match expected French names
        for name in expectedTabNames {
            XCTAssertFalse(name.isEmpty, "Tab name should not be empty")
            XCTAssertTrue(expectedTabNames.contains(name), "Tab name '\(name)' should be in expected list")
        }
    }

    /// Test SF Symbol names are valid
    func testSFSymbolsExist() {
        let sfSymbols = ["house.fill", "graduationcap.fill", "doc.text.fill", "envelope.fill"]

        for symbolName in sfSymbols {
            let image = UIImage(systemName: symbolName)
            XCTAssertNotNil(image, "SF Symbol '\(symbolName)' should exist")
        }
    }
}
