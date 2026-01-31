//
//  NavigationContext.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Enum representing the type of content being viewed
enum NavigationContextType: String, Codable {
    case formation
    case article
    case service
}

/// Model representing the navigation context
struct NavigationContextItem: Equatable {
    let type: NavigationContextType
    let id: Int
    let title: String
}

/// Service that tracks user navigation context for pre-filling contact forms.
@Observable
final class NavigationContext {
    /// Shared instance for app-wide context tracking
    static let shared = NavigationContext()

    /// The current navigation context (last viewed item)
    private(set) var currentContext: NavigationContextItem?

    /// Flag to trigger navigation to the Contact screen
    var shouldNavigateToContact = false

    /// Flag to trigger navigation to the Blog screen
    var shouldNavigateToBlog = false

    /// Flag to trigger navigation to the Search screen
    var shouldNavigateToSearch = false

    /// Flag to trigger navigation to the Events screen
    var shouldNavigateToEvents = false

    private init() {}

    // MARK: - Actions

    /// Sets the context when user views a formation
    func setFormation(_ formation: Formation) {
        currentContext = NavigationContextItem(
            type: .formation,
            id: formation.id,
            title: formation.title
        )
    }

    /// Sets the context when user views an article
    func setArticle(_ article: Article) {
        currentContext = NavigationContextItem(
            type: .article,
            id: article.id,
            title: article.title
        )
    }

    /// Sets the context when user views a service
    func setService(_ service: Service) {
        currentContext = NavigationContextItem(
            type: .service,
            id: service.id,
            title: service.name
        )
    }

    /// Navigate to contact screen with service context
    func navigateToContact(from service: Service) {
        setService(service)
        shouldNavigateToContact = true
    }

    /// Triggers navigation to contact screen (keeps current context)
    func triggerContactNavigation() {
        shouldNavigateToContact = true
    }

    /// Triggers navigation to blog screen
    func triggerBlogNavigation() {
        shouldNavigateToBlog = true
    }

    /// Triggers navigation to search screen
    func triggerSearchNavigation() {
        shouldNavigateToSearch = true
    }

    /// Triggers navigation to events screen
    func triggerEventsNavigation() {
        shouldNavigateToEvents = true
    }

    /// Clears the current context (after successful contact submission)
    func clear() {
        currentContext = nil
    }

    /// Clears contact navigation flag after navigation is complete
    func clearNavigationFlag() {
        shouldNavigateToContact = false
    }

    /// Clears blog navigation flag after navigation is complete
    func clearBlogNavigationFlag() {
        shouldNavigateToBlog = false
    }

    /// Clears search navigation flag after navigation is complete
    func clearSearchNavigationFlag() {
        shouldNavigateToSearch = false
    }

    /// Clears events navigation flag after navigation is complete
    func clearEventsNavigationFlag() {
        shouldNavigateToEvents = false
    }

    // MARK: - Computed Properties

    /// Returns the context string for API submission
    var contextString: String? {
        guard let context = currentContext else { return nil }
        return "\(context.type.rawValue.capitalized): \(context.title)"
    }

    /// Returns the pre-fill subject based on context
    var suggestedSubject: String {
        guard let context = currentContext else {
            return "Question générale"
        }
        switch context.type {
        case .formation:
            return "Question sur la formation"
        case .article:
            return "Question sur l'article"
        case .service:
            return "Question sur le service"
        }
    }

    /// Returns the pre-fill message based on context
    var suggestedMessage: String {
        guard let context = currentContext else { return "" }
        return "Bonjour,\n\nJe vous contacte au sujet de \"\(context.title)\".\n\n"
    }
}

// MARK: - Environment Key

private struct NavigationContextKey: EnvironmentKey {
    static let defaultValue = NavigationContext.shared
}

extension EnvironmentValues {
    var navigationContext: NavigationContext {
        get { self[NavigationContextKey.self] }
        set { self[NavigationContextKey.self] = newValue }
    }
}
