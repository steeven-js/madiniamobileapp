//
//  DeepLinkServiceTests.swift
//  MadiniaAppTests
//
//  Tests for DeepLinkService URL parsing and generation.
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the DeepLinkService
final class DeepLinkServiceTests: XCTestCase {

    // MARK: - Properties

    private var deepLinkService: DeepLinkService!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        deepLinkService = DeepLinkService.shared
    }

    override func tearDownWithError() throws {
        deepLinkService = nil
        try super.tearDownWithError()
    }

    // MARK: - Singleton Tests

    /// Test singleton pattern
    func testSingletonInstance() {
        let instance1 = DeepLinkService.shared
        let instance2 = DeepLinkService.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - DeepLinkDestination Tests

    /// Test DeepLinkDestination equality
    func testDeepLinkDestinationEquality() {
        let formation1 = DeepLinkService.DeepLinkDestination.formation(slug: "test-slug")
        let formation2 = DeepLinkService.DeepLinkDestination.formation(slug: "test-slug")
        let formation3 = DeepLinkService.DeepLinkDestination.formation(slug: "other-slug")

        XCTAssertEqual(formation1, formation2)
        XCTAssertNotEqual(formation1, formation3)
    }

    /// Test DeepLinkDestination article equality
    func testDeepLinkDestinationArticleEquality() {
        let article1 = DeepLinkService.DeepLinkDestination.article(slug: "article-slug")
        let article2 = DeepLinkService.DeepLinkDestination.article(slug: "article-slug")

        XCTAssertEqual(article1, article2)
    }

    /// Test DeepLinkDestination home equality
    func testDeepLinkDestinationHomeEquality() {
        let home1 = DeepLinkService.DeepLinkDestination.home
        let home2 = DeepLinkService.DeepLinkDestination.home

        XCTAssertEqual(home1, home2)
    }

    /// Test different destination types are not equal
    func testDifferentDestinationsNotEqual() {
        let formation = DeepLinkService.DeepLinkDestination.formation(slug: "slug")
        let article = DeepLinkService.DeepLinkDestination.article(slug: "slug")
        let home = DeepLinkService.DeepLinkDestination.home

        XCTAssertNotEqual(formation, article)
        XCTAssertNotEqual(formation, home)
        XCTAssertNotEqual(article, home)
    }

    // MARK: - URL Parsing Tests - Formations

    /// Test parsing formation URL with /formations/ path
    func testParseFormationURL() {
        let url = URL(string: "https://madinia.fr/formations/introduction-ia")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .formation(slug: "introduction-ia"))
    }

    /// Test parsing formation URL with /formation/ path (singular)
    func testParseFormationURLSingular() {
        let url = URL(string: "https://madinia.fr/formation/machine-learning-basics")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .formation(slug: "machine-learning-basics"))
    }

    /// Test parsing formation URL without slug returns home
    func testParseFormationURLWithoutSlug() {
        let url = URL(string: "https://madinia.fr/formations")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .home)
    }

    // MARK: - URL Parsing Tests - Articles

    /// Test parsing article URL with /blog/ path
    func testParseArticleURLBlog() {
        let url = URL(string: "https://madinia.fr/blog/latest-ai-trends")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .article(slug: "latest-ai-trends"))
    }

    /// Test parsing article URL with /article/ path
    func testParseArticleURLArticle() {
        let url = URL(string: "https://madinia.fr/article/getting-started")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .article(slug: "getting-started"))
    }

    /// Test parsing article URL with /articles/ path
    func testParseArticleURLArticles() {
        let url = URL(string: "https://madinia.fr/articles/ai-in-martinique")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .article(slug: "ai-in-martinique"))
    }

    /// Test parsing article URL without slug returns home
    func testParseArticleURLWithoutSlug() {
        let url = URL(string: "https://madinia.fr/blog")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .home)
    }

    // MARK: - URL Parsing Tests - Home & Unknown

    /// Test parsing root URL returns home
    func testParseRootURL() {
        let url = URL(string: "https://madinia.fr/")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .home)
    }

    /// Test parsing unknown path returns home
    func testParseUnknownPath() {
        let url = URL(string: "https://madinia.fr/unknown/path")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .home)
    }

    // MARK: - URL Parsing Tests - Host Validation

    /// Test parsing with www subdomain
    func testParseURLWithWWW() {
        let url = URL(string: "https://www.madinia.fr/formations/test-formation")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertEqual(destination, .formation(slug: "test-formation"))
    }

    /// Test parsing with invalid host returns nil
    func testParseURLInvalidHost() {
        let url = URL(string: "https://example.com/formations/test")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertNil(destination)
    }

    /// Test parsing with no host returns nil
    func testParseURLNoHost() {
        let url = URL(string: "file:///formations/test")!
        let destination = deepLinkService.parse(url: url)

        XCTAssertNil(destination)
    }

    // MARK: - URL Generation Tests

    /// Test formation URL generation
    func testFormationURLGeneration() {
        let url = deepLinkService.formationURL(slug: "my-formation")

        XCTAssertEqual(url.absoluteString, "https://madinia.fr/formations/my-formation")
    }

    /// Test article URL generation
    func testArticleURLGeneration() {
        let url = deepLinkService.articleURL(slug: "my-article")

        XCTAssertEqual(url.absoluteString, "https://madinia.fr/blog/my-article")
    }

    /// Test formation URL generation with special characters
    func testFormationURLWithSpecialCharacters() {
        let url = deepLinkService.formationURL(slug: "formation-ia-2026")

        XCTAssertNotNil(url)
        XCTAssertTrue(url.absoluteString.contains("formation-ia-2026"))
    }
}
