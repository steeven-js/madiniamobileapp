//
//  DeepLinkService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Service for parsing and handling deep links (Universal Links).
/// Supports formation and article deep links from madinia.fr domain.
final class DeepLinkService {
    /// Shared singleton instance
    static let shared = DeepLinkService()

    private init() {}

    // MARK: - Deep Link Types

    /// Represents a parsed deep link destination
    enum DeepLinkDestination: Equatable {
        case formation(slug: String)
        case article(slug: String)
        case home
    }

    // MARK: - URL Parsing

    /// Parses a URL into a deep link destination
    /// - Parameter url: The URL to parse
    /// - Returns: The destination to navigate to, or nil if URL is not supported
    func parse(url: URL) -> DeepLinkDestination? {
        // Ensure it's a madinia.fr URL
        guard let host = url.host?.lowercased(),
              host == "madinia.fr" || host == "www.madinia.fr" else {
            return nil
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // Handle different URL patterns
        switch pathComponents.first {
        case "formations":
            // /formations/{slug}
            if pathComponents.count >= 2 {
                return .formation(slug: pathComponents[1])
            }
            return .home // /formations without slug goes to home

        case "formation":
            // Alternative: /formation/{slug}
            if pathComponents.count >= 2 {
                return .formation(slug: pathComponents[1])
            }
            return .home

        case "blog":
            // /blog/{slug}
            if pathComponents.count >= 2 {
                return .article(slug: pathComponents[1])
            }
            return .home

        case "article", "articles":
            // /article/{slug} or /articles/{slug}
            if pathComponents.count >= 2 {
                return .article(slug: pathComponents[1])
            }
            return .home

        default:
            // Unknown route - go to home
            return .home
        }
    }

    /// Generates a shareable URL for a formation
    /// - Parameter slug: The formation slug
    /// - Returns: The shareable URL
    func formationURL(slug: String) -> URL {
        URL(string: "https://madinia.fr/formations/\(slug)") ??
        URL(string: "https://madinia.fr")!
    }

    /// Generates a shareable URL for an article
    /// - Parameter slug: The article slug
    /// - Returns: The shareable URL
    func articleURL(slug: String) -> URL {
        URL(string: "https://madinia.fr/blog/\(slug)") ??
        URL(string: "https://madinia.fr")!
    }
}
