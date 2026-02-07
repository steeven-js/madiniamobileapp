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
    case userSpace = 2
    case search = 3

    var title: String {
        switch self {
        case .home: return "Accueil"
        case .madinia: return "Madin.IA"
        case .userSpace: return "L'IA&Vous"
        case .search: return "Recherche"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .madinia: return "madinia-tab-icon"
        case .userSpace: return "person.crop.circle"
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
/// Uses a custom App Store-style tab bar on iPhone and a sidebar on iPad.
/// Includes the Madi FAB overlay for AI coach access.
struct MainTabView: View {
    /// Selected tab - using @State for immediate responsiveness
    @State private var selectedTab: MainTab = {
        if let rawValue = UserDefaults.standard.object(forKey: "selectedTab") as? Int,
           let tab = MainTab(rawValue: rawValue) {
            return tab
        }
        return .home
    }()

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

    /// Service to navigate to from deep link
    @State private var selectedServiceSlug: String?

    /// Controls the permission prompt sheet
    @State private var isShowingPermissionPrompt = false

    /// Deep link bindings from app
    @Environment(\.deepLinkFormationSlug) private var deepLinkFormationSlug
    @Environment(\.deepLinkArticleSlug) private var deepLinkArticleSlug
    @Environment(\.deepLinkServiceSlug) private var deepLinkServiceSlug

    /// Horizontal size class for iPad detection
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Push notification service
    @State private var pushService = PushNotificationService.shared

    /// Navigation context for handling contact navigation
    private var navigationContext = NavigationContext.shared

    /// Whether we're on iPad (regular width)
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Binding to convert MainTab to Int for HomeView
    private var selectedTabBinding: Binding<Int> {
        Binding(
            get: { selectedTab.rawValue },
            set: { newValue in
                if let tab = MainTab(rawValue: newValue) {
                    selectedTab = tab
                }
            }
        )
    }

    var body: some View {
        Group {
            if isIPad {
                iPadLayout
            } else {
                iPhoneLayout
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
        .onChange(of: deepLinkServiceSlug.wrappedValue) { _, newSlug in
            if let slug = newSlug {
                navigateToService(slug: slug)
                deepLinkServiceSlug.wrappedValue = nil
            }
        }
        .onChange(of: navigationContext.shouldNavigateToContact) { _, shouldNavigate in
            if shouldNavigate {
                selectedTab = .madinia
            }
        }
        .onChange(of: navigationContext.shouldNavigateToSearch) { _, shouldNavigate in
            if shouldNavigate {
                selectedTab = .search
                navigationContext.clearSearchNavigationFlag()
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            // Persist tab selection in background
            UserDefaults.standard.set(newTab.rawValue, forKey: "selectedTab")
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            // Offline status banner at top
            OfflineStatusBanner()
                .animation(.spring(response: 0.3), value: NetworkMonitorService.shared.isConnected)

            ZStack {
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        NavigationStack {
                            HomeView(selectedTab: selectedTabBinding)
                        }
                    case .madinia:
                        MadiniaHubView()
                    case .userSpace:
                        UserSpaceView()
                    case .search:
                        SearchTab(
                            selectedFormationSlug: $selectedFormationSlug,
                            selectedServiceSlug: $selectedServiceSlug
                        )
                    }
                }

                // Settings button overlay (top-right)
                settingsButtonOverlay

                // Madi FAB overlay (bottom-right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        MadiFAB(isShowingChat: $isShowingMadiChat)
                            .padding(.trailing, MadiniaSpacing.lg)
                            .padding(.bottom, 16) // Just above custom tab bar
                    }
                }
                .allowsHitTesting(true)
            }
            // Custom Tab Bar - using safeAreaInset ensures proper hit testing
            .safeAreaInset(edge: .bottom) {
                customTabBar
                    .padding(.bottom, MadiniaSpacing.sm)
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        NavigationSplitView {
            // Sidebar
            List {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        HStack(spacing: MadiniaSpacing.sm) {
                            if tab.isSystemIcon {
                                Image(systemName: tab.icon)
                                    .font(.title3)
                                    .frame(width: 24)
                            } else {
                                Image(tab.icon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                            Text(tab.title)
                                .font(MadiniaTypography.body)
                        }
                        .foregroundStyle(selectedTab == tab ? MadiniaColors.accent : .primary)
                        .padding(.vertical, MadiniaSpacing.xs)
                    }
                    .listRowBackground(
                        selectedTab == tab
                            ? MadiniaColors.accent.opacity(0.1)
                            : Color.clear
                    )
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Madin.IA")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(MadiniaColors.accent)
                    }
                    .accessibilityLabel("Paramètres")
                }
            }
        } detail: {
            // Detail content
            VStack(spacing: 0) {
                // Offline status banner at top
                OfflineStatusBanner()
                    .animation(.spring(response: 0.3), value: NetworkMonitorService.shared.isConnected)

                ZStack {
                    Group {
                        switch selectedTab {
                        case .home:
                            NavigationStack {
                                HomeView(selectedTab: selectedTabBinding)
                            }
                        case .madinia:
                            MadiniaHubView()
                        case .userSpace:
                            UserSpaceView()
                        case .search:
                            SearchTab(
                                selectedFormationSlug: $selectedFormationSlug,
                                selectedServiceSlug: $selectedServiceSlug
                            )
                        }
                    }

                    // Madi FAB overlay (bottom-right)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            MadiFAB(isShowingChat: $isShowingMadiChat)
                                .padding(.trailing, MadiniaSpacing.lg)
                                .padding(.bottom, MadiniaSpacing.lg)
                        }
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - Settings Button Overlay

    private var settingsButtonOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(MadiniaColors.accent)
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
    }

    // MARK: - Custom Tab Bar (Liquid Glass Style)

    private var customTabBar: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Left group: Accueil + Madin.IA + L'IA&Vous
            HStack(spacing: 0) {
                tabButton(for: .home)
                tabButton(for: .madinia)
                tabButton(for: .userSpace)
            }
            .padding(.horizontal, MadiniaSpacing.xs)
            .padding(.vertical, MadiniaSpacing.xs)
            .modifier(LiquidGlassModifier())

            // Right group: Recherche
            tabButton(for: .search)
                .padding(.horizontal, MadiniaSpacing.sm)
                .padding(.vertical, MadiniaSpacing.xs)
                .modifier(LiquidGlassModifier())
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }

    private func tabButton(for tab: MainTab) -> some View {
        Button {
            selectedTab = tab
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
                    .font(.caption)
                    .fontWeight(selectedTab == tab ? .semibold : .medium)
            }
            .foregroundStyle(selectedTab == tab ? MadiniaColors.accent : .secondary)
            .frame(minWidth: 70)
            .padding(.vertical, MadiniaSpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    // MARK: - Navigation

    private func navigateToFormation(slug: String) {
        selectedFormationSlug = slug
        selectedTab = .search
    }

    private func navigateToService(slug: String) {
        selectedServiceSlug = slug
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
    @Binding var selectedServiceSlug: String?

    var body: some View {
        SearchView(
            deepLinkFormationSlug: $selectedFormationSlug,
            deepLinkServiceSlug: $selectedServiceSlug
        )
    }
}

// MARK: - Tab Button Style

/// Custom button style for tab buttons with immediate response
private struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Liquid Glass Modifier

/// ViewModifier that applies liquid glass effect on iOS 26+ with fallback for older versions
private struct LiquidGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular)
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
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

#Preview("L'IA&Vous Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(2, forKey: "selectedTab")
        }
}

#Preview("Recherche Tab") {
    MainTabView()
        .onAppear {
            UserDefaults.standard.set(3, forKey: "selectedTab")
        }
}
