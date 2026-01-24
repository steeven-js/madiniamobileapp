//
//  FormationTests.swift
//  MadiniaAppTests
//
//  Created by Madinia on 2026-01-23.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the Formation model
final class FormationTests: XCTestCase {

    // MARK: - JSON Decoding Tests

    /// Test that Formation correctly decodes from valid JSON matching API response
    func testFormationDecodingFromJSON() throws {
        // Given: Valid JSON matching Laravel API response format
        let json = """
        {
            "id": 1,
            "title": "Starter Pack - IA Générative",
            "slug": "starter-pack-ia-generative",
            "shortDescription": "Découvrez les fondamentaux de l'IA générative.",
            "duration": "14 heures",
            "durationHours": 14,
            "level": "debutant",
            "levelLabel": "Débutant",
            "certification": false,
            "certificationLabel": "Non certifiante",
            "imageUrl": "https://example.com/image.jpg",
            "category": {
                "id": 1,
                "name": "IA Générative",
                "slug": "ia-generative",
                "color": "#8B5CF6",
                "icon": null
            }
        }
        """.data(using: .utf8)!

        // When: Decoding the JSON
        let decoder = JSONDecoder()
        let formation = try decoder.decode(Formation.self, from: json)

        // Then: All properties are correctly mapped
        XCTAssertEqual(formation.id, 1)
        XCTAssertEqual(formation.title, "Starter Pack - IA Générative")
        XCTAssertEqual(formation.slug, "starter-pack-ia-generative")
        XCTAssertEqual(formation.shortDescription, "Découvrez les fondamentaux de l'IA générative.")
        XCTAssertEqual(formation.duration, "14 heures")
        XCTAssertEqual(formation.durationHours, 14)
        XCTAssertEqual(formation.level, "debutant")
        XCTAssertEqual(formation.levelLabel, "Débutant")
        XCTAssertEqual(formation.certification, false)
        XCTAssertEqual(formation.certificationLabel, "Non certifiante")
        XCTAssertEqual(formation.imageUrl, "https://example.com/image.jpg")
        XCTAssertNotNil(formation.category)
        XCTAssertEqual(formation.category?.name, "IA Générative")
        XCTAssertEqual(formation.category?.color, "#8B5CF6")
    }

    /// Test that Formation handles null optional fields correctly
    func testFormationDecodingWithNullOptionalFields() throws {
        // Given: JSON with null optional fields
        let json = """
        {
            "id": 3,
            "title": "Master Pack",
            "slug": "master-pack",
            "shortDescription": null,
            "duration": "35 heures",
            "durationHours": null,
            "level": "avance",
            "levelLabel": "Avancé",
            "certification": null,
            "certificationLabel": null,
            "imageUrl": null,
            "category": null
        }
        """.data(using: .utf8)!

        // When: Decoding the JSON
        let decoder = JSONDecoder()
        let formation = try decoder.decode(Formation.self, from: json)

        // Then: Optional fields are nil
        XCTAssertNil(formation.shortDescription)
        XCTAssertNil(formation.durationHours)
        XCTAssertNil(formation.certification)
        XCTAssertNil(formation.certificationLabel)
        XCTAssertNil(formation.imageUrl)
        XCTAssertNil(formation.category)
        XCTAssertEqual(formation.id, 3)
    }

    /// Test that Formation decodes detail-only fields
    func testFormationDecodingWithDetailFields() throws {
        // Given: JSON with detail-only fields (from /formations/{slug} endpoint)
        let json = """
        {
            "id": 1,
            "title": "Formation Complète",
            "slug": "formation-complete",
            "shortDescription": "Description courte",
            "duration": "21 heures",
            "durationHours": 21,
            "level": "intermediaire",
            "levelLabel": "Intermédiaire",
            "certification": true,
            "certificationLabel": "Certifiante",
            "imageUrl": null,
            "category": null,
            "description": "<p>Description complète en HTML</p>",
            "objectives": "<ul><li>Objectif 1</li></ul>",
            "prerequisites": "Aucun prérequis",
            "program": "<h2>Programme</h2>",
            "targetAudience": "Tous publics",
            "trainingMethods": "E-learning",
            "pdfFileUrl": "https://example.com/formation.pdf",
            "viewsCount": 150,
            "publishedAt": "2026-01-15T10:00:00Z"
        }
        """.data(using: .utf8)!

        // When: Decoding the JSON
        let decoder = JSONDecoder()
        let formation = try decoder.decode(Formation.self, from: json)

        // Then: Detail fields are correctly decoded
        XCTAssertEqual(formation.description, "<p>Description complète en HTML</p>")
        XCTAssertEqual(formation.objectives, "<ul><li>Objectif 1</li></ul>")
        XCTAssertEqual(formation.prerequisites, "Aucun prérequis")
        XCTAssertEqual(formation.program, "<h2>Programme</h2>")
        XCTAssertEqual(formation.targetAudience, "Tous publics")
        XCTAssertEqual(formation.trainingMethods, "E-learning")
        XCTAssertEqual(formation.pdfFileUrl, "https://example.com/formation.pdf")
        XCTAssertEqual(formation.viewsCount, 150)
        XCTAssertEqual(formation.publishedAt, "2026-01-15T10:00:00Z")
    }

    /// Test that Formation array decodes correctly
    func testFormationArrayDecoding() throws {
        // Given: JSON array of formations
        let json = """
        [
            {
                "id": 1,
                "title": "Formation 1",
                "slug": "formation-1",
                "shortDescription": "Description 1",
                "duration": "14 heures",
                "durationHours": 14,
                "level": "debutant",
                "levelLabel": "Débutant",
                "certification": false,
                "certificationLabel": "Non certifiante",
                "imageUrl": null,
                "category": null
            },
            {
                "id": 2,
                "title": "Formation 2",
                "slug": "formation-2",
                "shortDescription": "Description 2",
                "duration": "21 heures",
                "durationHours": 21,
                "level": "intermediaire",
                "levelLabel": "Intermédiaire",
                "certification": true,
                "certificationLabel": "Certifiante",
                "imageUrl": null,
                "category": null
            }
        ]
        """.data(using: .utf8)!

        // When: Decoding the JSON array
        let decoder = JSONDecoder()
        let formations = try decoder.decode([Formation].self, from: json)

        // Then: Array is correctly decoded
        XCTAssertEqual(formations.count, 2)
        XCTAssertEqual(formations[0].id, 1)
        XCTAssertEqual(formations[1].id, 2)
        XCTAssertEqual(formations[0].levelLabel, "Débutant")
        XCTAssertEqual(formations[1].levelLabel, "Intermédiaire")
    }

    // MARK: - FormationCategory Tests

    /// Test FormationCategory decoding
    func testFormationCategoryDecoding() throws {
        // Given: Category JSON
        let json = """
        {
            "id": 1,
            "name": "IA Générative",
            "slug": "ia-generative",
            "color": "#8B5CF6",
            "icon": "brain"
        }
        """.data(using: .utf8)!

        // When: Decoding
        let decoder = JSONDecoder()
        let category = try decoder.decode(FormationCategory.self, from: json)

        // Then: All fields decoded
        XCTAssertEqual(category.id, 1)
        XCTAssertEqual(category.name, "IA Générative")
        XCTAssertEqual(category.slug, "ia-generative")
        XCTAssertEqual(category.color, "#8B5CF6")
        XCTAssertEqual(category.icon, "brain")
    }

    // MARK: - Protocol Conformance Tests

    /// Test Identifiable conformance
    func testIdentifiableConformance() {
        let formation = Formation.sample
        XCTAssertEqual(formation.id, 1)
    }

    /// Test Hashable conformance
    func testHashableConformance() {
        let formation1 = Formation.sample
        let formation2 = Formation.sample

        // Same formations should have same hash
        XCTAssertEqual(formation1.hashValue, formation2.hashValue)

        // Can be used in Set
        var set = Set<Formation>()
        set.insert(formation1)
        XCTAssertTrue(set.contains(formation2))
    }

    /// Test Equatable conformance
    func testEquatableConformance() {
        let formation1 = Formation.sample
        let formation2 = Formation.sample

        XCTAssertEqual(formation1, formation2)
    }

    // MARK: - Sample Data Tests

    /// Test that sample data is valid
    func testSampleDataIsValid() {
        let sample = Formation.sample
        XCTAssertEqual(sample.id, 1)
        XCTAssertFalse(sample.title.isEmpty)
        XCTAssertFalse(sample.slug.isEmpty)
        XCTAssertFalse(sample.levelLabel.isEmpty)
    }

    /// Test that samples array is not empty
    func testSamplesArrayNotEmpty() {
        XCTAssertFalse(Formation.samples.isEmpty)
        XCTAssertEqual(Formation.samples.count, 3)
    }

    /// Test sample data has expected level values
    func testSampleDataLevels() {
        let samples = Formation.samples

        // Check that we have different levels
        let levels = Set(samples.map { $0.level })
        XCTAssertTrue(levels.contains("debutant"))
        XCTAssertTrue(levels.contains("intermediaire"))
        XCTAssertTrue(levels.contains("avance"))
    }
}
