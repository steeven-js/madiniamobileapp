//
//  MainTabView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Main tab types for the app
enum MainTab: Int, CaseIterable {
    case home = 0
    case madinia = 1
    case search = 2

    var title: String {
        switch self {
        case .home: return "Accueil"
        case .madinia: return "Madin.IA"
        case .search: return "Recherche"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .madinia: return "madinia-tab-icon"
        case .search: return "magnifyingglass"
        }
    }

    var isSystemIcon: Bool {
        switch self {
        case .madinia: return false
        default: return true
        }
    }
}

/// Main tab navigation view providing access to the primary sections of the app.
/// Uses a custom App Store-style tab bar with grouped tabs.
/// Includes the Madi FAB overlay for AI coach access.
struct MainTabView: View {
    /// Selected tab, persisted across app launches
    @AppStorage("selectedTab") private var selectedTab: MainTab = .home

    /// Controls the Madi chat sheet presentation
    @State private var isShowingMadiChat = false

    /// Controls the settings sheet presentation
    @State private var isShowingSettings = false

    /// Theme manager for applying color scheme to sheets
    private var themeManager = ThemeManager.shared

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
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        HomeView(selectedTab: .constant(0))
                    }
                case .madinia:
                    MadiniaHubView()
                case .search:
                    SearchTab(selectedFormationSlug: $selectedFormationSlug)
                }
            }

            // Custom Tab Bar
            VStack {
                Spacer()
                customTabBar
            }

            // Settings button overlay (top-right)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(MadiniaColors.gold)
                            .padding(MadiniaSpacing.sm)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                    .accessibilityLabel("Paramètres")
                    .padding(.trailing, MadiniaSpacing.md)
                    .padding(.top, 4)
                }
                Spacer()
            }

            // Madi FAB overlay (bottom-right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MadiFAB(isShowingChat: $isShowingMadiChat)
                        .padding(.trailing, MadiniaSpacing.md)
                        .padding(.bottom, 100) // Above custom tab bar
                }
            }
        }
        .sheet(isPresented: $isShowingMadiChat) {
            MadiChatView { recommendation in
                navigateToFormation(slug: recommendation.formationSlug)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .preferredColorScheme(themeManager.colorScheme)
        }
        .sheet(isPresented: $isShowingPermissionPrompt) {
            PermissionPromptView()
                .preferredColorScheme(themeManager.colorScheme)
        }
        .sheet(isPresented: $isShowingSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Fermer") {
                                isShowingSettings = false
                            }
                        }
                    }
            }
            .preferredColorScheme(themeManager.colorScheme)
        }
        .task {
            await pushService.checkAuthorizationStatus()
            if pushService.shouldPromptForPermission {
                try? await Task.sleep(for: .seconds(2))
                isShowingPermissionPrompt = true
            }
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
                selectedTab = .madinia
                deepLinkArticleSlug.wrappedValue = nil
            }
        }
    }

    // MARK: - Custom Tab Bar (App Store Style)

    private var customTabBar: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Left group: Accueil + Madin.IA
            HStack(spacing: 0) {
                tabButton(for: .home)
                tabButton(for: .madinia)
            }
            .padding(.horizontal, MadiniaSpacing.xs)
            .padding(.vertical, MadiniaSpacing.xs)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))

            // Right group: Recherche
            tabButton(for: .search)
                .padding(.horizontal, MadiniaSpacing.sm)
                .padding(.vertical, MadiniaSpacing.xs)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.bottom, MadiniaSpacing.sm)
    }

    private func tabButton(for tab: MainTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                if tab.isSystemIcon {
                    Image(systemName: tab.icon)
                        .font(.title2)
                        .symbolVariant(selectedTab == tab ? .fill : .none)
                } else {
                    Image(tab.icon)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }

                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(selectedTab == tab ? .semibold : .regular)
            }
            .foregroundStyle(selectedTab == tab ? MadiniaColors.gold : .secondary)
            .frame(minWidth: 70)
            .padding(.vertical, MadiniaSpacing.xs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    // MARK: - Navigation

    private func navigateToFormation(slug: String) {
        selectedFormationSlug = slug
        selectedTab = .search
    }

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
            selectedFormationSlug = nil
        } catch {
            selectedFormationSlug = nil
        }
    }
}

#Preview("Default - Accueil") {
    MainTabView()
}

#Preview("Madin.IA Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(1, forKey: "selectedTab")
        }
}

#Preview("Recherche Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(2, forKey: "selectedTab")
        }
}
