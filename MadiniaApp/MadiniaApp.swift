//
//  MadiniaApp.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI
import SwiftData

@main
struct MadiniaApp: App {
    /// App delegate for handling push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// Theme manager for light/dark mode
    @State private var themeManager = ThemeManager.shared

    /// Deep link state for navigation
    @State private var deepLinkFormationSlug: String?
    @State private var deepLinkArticleSlug: String?
    @State private var deepLinkServiceSlug: String?

    /// What's New modal presentation
    @State private var showWhatsNew = false

    /// Deep link service
    private let deepLinkService = DeepLinkService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.deepLinkFormationSlug, $deepLinkFormationSlug)
                .environment(\.deepLinkArticleSlug, $deepLinkArticleSlug)
                .environment(\.deepLinkServiceSlug, $deepLinkServiceSlug)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    setupDeepLinkHandler()
                    checkForWhatsNew()
                }
                .onOpenURL { url in
                    handleUniversalLink(url)
                }
                .fullScreenCover(isPresented: $showWhatsNew) {
                    WhatsNewView(isModal: true)
                }
        }
        .modelContainer(for: [])
    }

    // MARK: - What's New

    /// Checks if we should show the What's New screen after app update
    private func checkForWhatsNew() {
        // Slight delay to let the app finish launching
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if WhatsNewService.shared.shouldShowWhatsNew {
                showWhatsNew = true
            }
        }
    }

    // MARK: - Universal Links

    private func handleUniversalLink(_ url: URL) {
        guard let destination = deepLinkService.parse(url: url) else { return }

        switch destination {
        case .formation(let slug):
            deepLinkFormationSlug = slug
        case .article(let slug):
            deepLinkArticleSlug = slug
        case .home:
            // Already on home, nothing to do
            break
        }
    }

    private func setupDeepLinkHandler() {
        appDelegate.onDeepLink = { payload in
            switch payload.type {
            case .formation:
                if let slug = payload.slug {
                    deepLinkFormationSlug = slug
                }
            case .article:
                if let slug = payload.slug {
                    deepLinkArticleSlug = slug
                }
            case .service:
                if let slug = payload.slug {
                    deepLinkServiceSlug = slug
                }
            case .home:
                // Already on home, nothing to do
                break
            }
        }
    }
}

// MARK: - Deep Link Environment Keys

private struct DeepLinkFormationSlugKey: EnvironmentKey {
    static let defaultValue: Binding<String?> = .constant(nil)
}

private struct DeepLinkArticleSlugKey: EnvironmentKey {
    static let defaultValue: Binding<String?> = .constant(nil)
}

private struct DeepLinkServiceSlugKey: EnvironmentKey {
    static let defaultValue: Binding<String?> = .constant(nil)
}

extension EnvironmentValues {
    var deepLinkFormationSlug: Binding<String?> {
        get { self[DeepLinkFormationSlugKey.self] }
        set { self[DeepLinkFormationSlugKey.self] = newValue }
    }

    var deepLinkArticleSlug: Binding<String?> {
        get { self[DeepLinkArticleSlugKey.self] }
        set { self[DeepLinkArticleSlugKey.self] = newValue }
    }

    var deepLinkServiceSlug: Binding<String?> {
        get { self[DeepLinkServiceSlugKey.self] }
        set { self[DeepLinkServiceSlugKey.self] = newValue }
    }
}
