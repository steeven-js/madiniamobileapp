//
//  MainTabView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Main tab navigation view providing access to the 4 primary sections of the app.
/// Uses TabView with NavigationStack per tab for proper navigation hierarchy.
/// Includes the Madi FAB overlay for AI coach access.
struct MainTabView: View {
    /// Selected tab index, persisted across app launches
    @AppStorage("selectedTab") private var selectedTab = 0

    /// Controls the Madi chat sheet presentation
    @State private var isShowingMadiChat = false

    /// Formation to navigate to from Madi recommendation
    @State private var selectedFormationSlug: String?

    /// Article to navigate to from deep link
    @State private var selectedArticleSlug: String?

    /// Controls the permission prompt sheet
    @State private var isShowingPermissionPrompt = false

    /// Deep link bindings from app
    @Environment(\.deepLinkFormationSlug) private var deepLinkFormationSlug
    @Environment(\.deepLinkArticleSlug) private var deepLinkArticleSlug

    /// Push notification service
    @State private var pushService = PushNotificationService.shared

    /// API service for fetching formation details
    private let apiService: APIServiceProtocol = APIService.shared

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
                .accessibilityLabel("Accueil")
                .accessibilityHint("Affiche l'écran d'accueil avec les highlights")

                SearchTab(selectedFormationSlug: $selectedFormationSlug)
                    .tabItem {
                        Label("Recherche", systemImage: "magnifyingglass")
                    }
                    .tag(1)
                    .accessibilityLabel("Recherche")
                    .accessibilityHint("Rechercher des formations, services et catégories")

                MadiniaHubView()
                    .tabItem {
                        Label {
                            Text("Madin.IA")
                        } icon: {
                            Image("madinia-tab-icon")
                                .renderingMode(.template)
                        }
                    }
                    .tag(2)
                    .accessibilityLabel("Madin.IA")
                    .accessibilityHint("Affiche le hub Madin.IA avec blog, à propos et actualités")

                ContactView()
                    .tabItem {
                        Label("Contact", systemImage: "envelope.fill")
                    }
                    .tag(3)
                    .accessibilityLabel("Contact")
                    .accessibilityHint("Affiche le formulaire de contact")
            }

            // Madi FAB overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MadiFAB(isShowingChat: $isShowingMadiChat)
                        .padding(.trailing, MadiniaSpacing.md)
                        .padding(.bottom, 80) // Above tab bar
                }
            }
        }
        .tint(MadiniaColors.gold) // Gold tab bar accent
        .observeKeyboard()
        .sheet(isPresented: $isShowingMadiChat) {
            MadiChatView { recommendation in
                navigateToFormation(slug: recommendation.formationSlug)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingPermissionPrompt) {
            PermissionPromptView()
        }
        .task {
            await pushService.checkAuthorizationStatus()
        }
        .onChange(of: deepLinkFormationSlug.wrappedValue) { _, newSlug in
            if let slug = newSlug {
                navigateToFormation(slug: slug)
                deepLinkFormationSlug.wrappedValue = nil
            }
        }
        .onChange(of: deepLinkArticleSlug.wrappedValue) { _, newSlug in
            if let slug = newSlug {
                selectedArticleSlug = slug
                selectedTab = 2 // Switch to Madin.IA tab
                deepLinkArticleSlug.wrappedValue = nil
            }
        }
    }

    // MARK: - Navigation

    private func navigateToFormation(slug: String) {
        selectedFormationSlug = slug
        selectedTab = 1 // Switch to Formations tab
    }

    /// Shows permission prompt after a meaningful action
    func showPermissionPromptIfNeeded() {
        if pushService.shouldPromptForPermission {
            isShowingPermissionPrompt = true
        }
    }
}

// MARK: - Search Tab with Navigation

private struct SearchTab: View {
    @Binding var selectedFormationSlug: String?
    @State private var navigationPath = NavigationPath()

    private let apiService: APIServiceProtocol = APIService.shared

    var body: some View {
        SearchView()
            .onChange(of: selectedFormationSlug) { _, newSlug in
                guard let slug = newSlug else { return }
                Task {
                    await loadAndNavigateToFormation(slug: slug)
                }
            }
    }

    @MainActor
    private func loadAndNavigateToFormation(slug: String) async {
        do {
            let formation = try await apiService.fetchFormation(slug: slug)
            // SearchView handles its own navigation, so we need to broadcast this
            // For now, the deep link will open the Search tab
            selectedFormationSlug = nil
        } catch {
            // Handle error silently
            selectedFormationSlug = nil
        }
    }
}

#Preview("Default - Accueil") {
    MainTabView()
}

#Preview("Formations Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(1, forKey: "selectedTab")
        }
}

#Preview("Madin.IA Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(2, forKey: "selectedTab")
        }
}

#Preview("Contact Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(3, forKey: "selectedTab")
        }
}
