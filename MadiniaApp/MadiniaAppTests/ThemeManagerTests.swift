//
//  ThemeManagerTests.swift
//  MadiniaAppTests
//
//  Tests for ThemeManager theme selection and persistence.
//

import XCTest
import SwiftUI
@testable import MadiniaApp

/// Unit tests for the ThemeManager
final class ThemeManagerTests: XCTestCase {

    // MARK: - Properties

    private var themeManager: ThemeManager!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        themeManager = ThemeManager.shared
    }

    override func tearDownWithError() throws {
        themeManager = nil
        try super.tearDownWithError()
    }

    // MARK: - AppTheme Tests

    /// Test AppTheme raw values
    func testAppThemeRawValues() {
        XCTAssertEqual(AppTheme.dark.rawValue, "dark")
        XCTAssertEqual(AppTheme.light.rawValue, "light")
    }

    /// Test AppTheme titles
    func testAppThemeTitles() {
        XCTAssertEqual(AppTheme.light.title, "Clair")
        XCTAssertEqual(AppTheme.dark.title, "Sombre")
    }

    /// Test AppTheme icons
    func testAppThemeIcons() {
        XCTAssertEqual(AppTheme.light.icon, "sun.max.fill")
        XCTAssertEqual(AppTheme.dark.icon, "moon.fill")
    }

    /// Test AppTheme conforms to CaseIterable
    func testAppThemeCaseIterable() {
        XCTAssertEqual(AppTheme.allCases.count, 2)
        XCTAssertTrue(AppTheme.allCases.contains(.light))
        XCTAssertTrue(AppTheme.allCases.contains(.dark))
    }

    // MARK: - Singleton Tests

    /// Test singleton pattern
    func testSingletonInstance() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Theme Tests

    /// Test currentTheme is valid
    func testCurrentThemeIsValid() {
        let theme = themeManager.currentTheme
        XCTAssertTrue(AppTheme.allCases.contains(theme))
    }

    /// Test colorScheme matches currentTheme
    func testColorSchemeMatchesTheme() {
        let theme = themeManager.currentTheme
        let colorScheme = themeManager.colorScheme

        switch theme {
        case .light:
            XCTAssertEqual(colorScheme, ColorScheme.light)
        case .dark:
            XCTAssertEqual(colorScheme, ColorScheme.dark)
        }
    }

    /// Test theme can be changed
    func testThemeCanBeChanged() {
        let originalTheme = themeManager.currentTheme

        // Change to the opposite theme
        let newTheme: AppTheme = (originalTheme == .dark) ? .light : .dark
        themeManager.currentTheme = newTheme

        XCTAssertEqual(themeManager.currentTheme, newTheme)

        // Restore original
        themeManager.currentTheme = originalTheme
    }

    /// Test colorScheme updates when theme changes
    func testColorSchemeUpdatesWithTheme() {
        let originalTheme = themeManager.currentTheme

        // Set to light
        themeManager.currentTheme = .light
        XCTAssertEqual(themeManager.colorScheme, ColorScheme.light)

        // Set to dark
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.colorScheme, ColorScheme.dark)

        // Restore original
        themeManager.currentTheme = originalTheme
    }
}
