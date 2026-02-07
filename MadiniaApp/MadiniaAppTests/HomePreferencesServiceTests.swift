//
//  HomePreferencesServiceTests.swift
//  MadiniaAppTests
//
//  Tests for HomePreferencesService section management functionality.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the HomePreferencesService
final class HomePreferencesServiceTests: XCTestCase {

    // MARK: - HomeSection Tests

    /// Test HomeSection raw values
    func testHomeSectionRawValues() {
        XCTAssertEqual(HomeSection.continuelearning.rawValue, "continue_learning")
        XCTAssertEqual(HomeSection.news.rawValue, "news")
        XCTAssertEqual(HomeSection.events.rawValue, "events")
        XCTAssertEqual(HomeSection.booking.rawValue, "booking")
        XCTAssertEqual(HomeSection.mostViewed.rawValue, "most_viewed")
    }

    /// Test HomeSection display titles are in French
    func testHomeSectionDisplayTitles() {
        XCTAssertEqual(HomeSection.continuelearning.displayTitle, "Reprendre")
        XCTAssertEqual(HomeSection.news.displayTitle, "Actualités")
        XCTAssertEqual(HomeSection.events.displayTitle, "Événements")
        XCTAssertEqual(HomeSection.booking.displayTitle, "Réservation")
        XCTAssertEqual(HomeSection.mostViewed.displayTitle, "Formations populaires")
    }

    /// Test HomeSection descriptions are in French
    func testHomeSectionDescriptions() {
        XCTAssertEqual(
            HomeSection.continuelearning.description,
            "Reprendre où vous en étiez"
        )
        XCTAssertEqual(
            HomeSection.news.description,
            "Articles et actualités du blog"
        )
        XCTAssertEqual(
            HomeSection.events.description,
            "Événements à venir"
        )
        XCTAssertEqual(
            HomeSection.booking.description,
            "Réserver un créneau de consultation"
        )
        XCTAssertEqual(
            HomeSection.mostViewed.description,
            "Les formations les plus consultées"
        )
    }

    /// Test HomeSection icons are valid SF Symbols
    func testHomeSectionIcons() {
        XCTAssertEqual(HomeSection.continuelearning.icon, "clock.arrow.circlepath")
        XCTAssertEqual(HomeSection.news.icon, "newspaper.fill")
        XCTAssertEqual(HomeSection.events.icon, "calendar")
        XCTAssertEqual(HomeSection.booking.icon, "calendar.badge.plus")
        XCTAssertEqual(HomeSection.mostViewed.icon, "chart.bar.fill")
    }

    /// Test HomeSection Identifiable conformance
    func testHomeSectionIdentifiable() {
        XCTAssertEqual(HomeSection.continuelearning.id, "continue_learning")
        XCTAssertEqual(HomeSection.news.id, "news")
        XCTAssertEqual(HomeSection.events.id, "events")
        XCTAssertEqual(HomeSection.booking.id, "booking")
        XCTAssertEqual(HomeSection.mostViewed.id, "most_viewed")
    }

    /// Test HomeSection allCases count
    func testHomeSectionAllCases() {
        XCTAssertEqual(HomeSection.allCases.count, 5)
        XCTAssertTrue(HomeSection.allCases.contains(.continuelearning))
        XCTAssertTrue(HomeSection.allCases.contains(.news))
        XCTAssertTrue(HomeSection.allCases.contains(.events))
        XCTAssertTrue(HomeSection.allCases.contains(.booking))
        XCTAssertTrue(HomeSection.allCases.contains(.mostViewed))
    }

    /// Test HomeSection default order
    func testHomeSectionDefaultOrder() {
        let defaultOrder = HomeSection.defaultOrder
        XCTAssertEqual(defaultOrder.count, 5)
        XCTAssertEqual(defaultOrder[0], .continuelearning)
        XCTAssertEqual(defaultOrder[1], .news)
        XCTAssertEqual(defaultOrder[2], .events)
        XCTAssertEqual(defaultOrder[3], .booking)
        XCTAssertEqual(defaultOrder[4], .mostViewed)
    }

    /// Test HomeSection Codable conformance
    func testHomeSectionCodable() throws {
        let section = HomeSection.news
        let encoder = JSONEncoder()
        let data = try encoder.encode(section)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HomeSection.self, from: data)

        XCTAssertEqual(decoded, section)
    }

    // MARK: - HomeSectionPreference Tests

    /// Test HomeSectionPreference Identifiable conformance
    func testHomeSectionPreferenceIdentifiable() {
        let pref = HomeSectionPreference(section: .news, isVisible: true, order: 0)
        XCTAssertEqual(pref.id, "news")
    }

    /// Test HomeSectionPreference Codable conformance
    func testHomeSectionPreferenceCodable() throws {
        let original = HomeSectionPreference(section: .events, isVisible: false, order: 2)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HomeSectionPreference.self, from: data)

        XCTAssertEqual(decoded.section, original.section)
        XCTAssertEqual(decoded.isVisible, original.isVisible)
        XCTAssertEqual(decoded.order, original.order)
    }

    /// Test HomeSectionPreference array Codable
    func testHomeSectionPreferenceArrayCodable() throws {
        let preferences = [
            HomeSectionPreference(section: .continuelearning, isVisible: true, order: 0),
            HomeSectionPreference(section: .news, isVisible: true, order: 1),
            HomeSectionPreference(section: .events, isVisible: false, order: 2)
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(preferences)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([HomeSectionPreference].self, from: data)

        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0].section, .continuelearning)
        XCTAssertEqual(decoded[1].section, .news)
        XCTAssertEqual(decoded[2].section, .events)
        XCTAssertFalse(decoded[2].isVisible)
    }

    // MARK: - HomePreferencesService Singleton Tests

    /// Test HomePreferencesService shared instance exists
    func testHomePreferencesServiceSharedInstance() {
        let service = HomePreferencesService.shared
        XCTAssertNotNil(service)
    }

    /// Test sectionPreferences is not empty
    func testSectionPreferencesNotEmpty() {
        let service = HomePreferencesService.shared
        XCTAssertFalse(service.sectionPreferences.isEmpty)
    }

    /// Test all sections have preferences
    func testAllSectionsHavePreferences() {
        let service = HomePreferencesService.shared
        let preferenceSections = Set(service.sectionPreferences.map { $0.section })
        let allSections = Set(HomeSection.allCases)

        XCTAssertEqual(preferenceSections, allSections)
    }

    /// Test isSectionVisible returns boolean
    func testIsSectionVisibleReturnsBoolean() {
        let service = HomePreferencesService.shared

        // All sections should have visibility defined
        for section in HomeSection.allCases {
            let isVisible = service.isSectionVisible(section)
            XCTAssertTrue(isVisible == true || isVisible == false)
        }
    }

    /// Test visibleSections returns subset of allCases
    func testVisibleSectionsSubset() {
        let service = HomePreferencesService.shared
        let visibleSections = Set(service.visibleSections)
        let allSections = Set(HomeSection.allCases)

        XCTAssertTrue(visibleSections.isSubset(of: allSections))
    }

    /// Test visibleSections are in order
    func testVisibleSectionsOrdered() {
        let service = HomePreferencesService.shared

        // Reset to defaults first to ensure consistent state
        service.resetToDefaults()

        let visibleSections = service.visibleSections
        // After reset, should be in default order
        XCTAssertEqual(visibleSections, HomeSection.defaultOrder)
    }

    /// Test hasCustomizations after reset
    func testHasCustomizationsAfterReset() {
        let service = HomePreferencesService.shared
        service.resetToDefaults()

        // After reset, should not have customizations
        XCTAssertFalse(service.hasCustomizations)
    }

    /// Test setVisibility changes visibility
    func testSetVisibilityChangesVisibility() {
        let service = HomePreferencesService.shared
        service.resetToDefaults()

        // Hide a section
        service.setVisibility(for: .booking, visible: false)

        XCTAssertFalse(service.isSectionVisible(.booking))
        XCTAssertTrue(service.hasCustomizations)

        // Restore
        service.setVisibility(for: .booking, visible: true)
    }

    /// Test toggleSection toggles visibility
    func testToggleSectionTogglesVisibility() {
        let service = HomePreferencesService.shared
        service.resetToDefaults()

        let initialVisibility = service.isSectionVisible(.events)
        service.toggleSection(.events)
        let toggledVisibility = service.isSectionVisible(.events)

        XCTAssertNotEqual(initialVisibility, toggledVisibility)

        // Restore
        service.toggleSection(.events)
    }

    /// Test resetToDefaults restores default state
    func testResetToDefaultsRestoresState() {
        let service = HomePreferencesService.shared

        // Make some changes
        service.setVisibility(for: .news, visible: false)
        service.setVisibility(for: .booking, visible: false)

        // Verify customizations exist
        XCTAssertTrue(service.hasCustomizations)

        // Reset
        service.resetToDefaults()

        // Verify default state
        XCTAssertFalse(service.hasCustomizations)
        XCTAssertEqual(service.visibleSections, HomeSection.defaultOrder)
    }
}
