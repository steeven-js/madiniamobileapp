//
//  MainTabView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI
import SSCoachMarks

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

    /// Event to navigate to from deep link
    @State private var selectedEventSlug: String?

    /// Controls the permission prompt sheet
    @State private var isShowingPermissionPrompt = false

    /// Deep link bindings from app
    @Environment(\.deepLinkFormationSlug) private var deepLinkFormationSlug
    @Environment(\.deepLinkArticleSlug) private var deepLinkArticleSlug
    @Environment(\.deepLinkServiceSlug) private var deepLinkServiceSlug
    @Environment(\.deepLinkEventSlug) private var deepLinkEventSlug

    /// Horizontal size class for iPad detection
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Push notification service
    @State private var pushService = PushNotificationService.shared

    /// Navigation context for handling contact navigation
    private var navigationContext = NavigationContext.shared

    /// Coach marks service for guided tour
    private var coachMarkService = CoachMarkService.shared

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
            // Force Home tab when tour is active (e.g. after replay)
            if !coachMarkService.hasSeenTour {
                selectedTab = .home
            }
            // Defer push permission check to avoid interrupting first experience
            try? await Task.sleep(for: .seconds(8))
            await pushService.checkAuthorizationStatus()
            // Don't show permission prompt during the guided tour — it covers the tips
            if pushService.shouldPromptForPermission && coachMarkService.activeTourGroup == nil {
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
        .onChange(of: deepLinkEventSlug.wrappedValue) { _, newSlug in
            if let slug = newSlug {
                selectedEventSlug = slug
                selectedTab = .madinia
                deepLinkEventSlug.wrappedValue = nil
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
        // Coach marks auto-navigation: switch tab when the tour requests it
        .onChange(of: coachMarkService.pendingTabNavigation) { _, newTab in
            if let tab = newTab {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = tab
                }
                coachMarkService.pendingTabNavigation = nil
            }
        }
        // Coach marks auto-navigation: open formation detail when tour requests it.
        // First switch to search tab, then set the slug after a delay so SearchView is mounted.
        .onChange(of: coachMarkService.pendingFormationSlug) { _, newSlug in
            if let slug = newSlug {
                coachMarkService.pendingFormationSlug = nil
                selectedTab = .search
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(800))
                    selectedFormationSlug = slug
                }
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            // Degraded mode / offline banner at top
            DegradedModeBanner()
                .animation(.spring(response: 0.3), value: ErrorHandlingService.shared.healthState.message)

            ZStack {
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        NavigationStack {
                            HomeView(selectedTab: selectedTabBinding)
                        }
                    case .madinia:
                        MadiniaHubView(deepLinkArticleSlug: $selectedArticleSlug, deepLinkEventSlug: $selectedEventSlug)
                            .conditionalCoachMarkView(
                                active: coachMarkService.activeTourGroup == .hub,
                                onFinished: { coachMarkService.onGroupFinished(group: .hub) }
                            )
                    case .userSpace:
                        UserSpaceView()
                            .conditionalCoachMarkView(
                                active: coachMarkService.activeTourGroup == .userSpace,
                                onFinished: { coachMarkService.onGroupFinished(group: .userSpace) }
                            )
                    case .search:
                        SearchTab(
                            selectedFormationSlug: $selectedFormationSlug,
                            selectedServiceSlug: $selectedServiceSlug
                        )
                        .conditionalCoachMarkView(
                            active: coachMarkService.activeTourGroup == .search,
                            onFinished: { coachMarkService.onGroupFinished(group: .search) }
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
                            .showCoachMark(order: 4, title: "Madi, coach IA", description: "Étape 5/20 — Posez vos questions à Madi, votre assistant IA personnel.", highlightViewCornerRadius: 30)

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
        .conditionalCoachMarkView(
            active: coachMarkService.activeTourGroup == .tabBar,
            onFinished: { coachMarkService.onGroupFinished(group: .tabBar) }
        )
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        NavigationSplitView {
            // Sidebar
            List {
                iPadSidebarButton(for: .home)

                iPadSidebarButton(for: .madinia)

                iPadSidebarButton(for: .userSpace)

                iPadSidebarButton(for: .search)

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
                // Degraded mode / offline banner at top
                DegradedModeBanner()
                    .animation(.spring(response: 0.3), value: ErrorHandlingService.shared.healthState.message)

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
                .showCoachMark(order: 5, title: "Paramètres", description: "Étape 6/20 — Personnalisez l'apparence, les notifications et gérez vos données.", highlightViewCornerRadius: 30)
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
                    .showCoachMark(order: 0, title: "Accueil", description: "Étape 1/20 — Retrouvez ici vos formations en cours, les dernières actualités et les événements à venir.", highlightViewCornerRadius: 25)

                tabButton(for: .madinia)
                    .showCoachMark(order: 1, title: "Madin.IA", description: "Étape 2/20 — Explorez les articles du blog, les vidéos et toutes les ressources Madin.IA.", highlightViewCornerRadius: 25)

                tabButton(for: .userSpace)
                    .showCoachMark(order: 2, title: "L'IA&Vous", description: "Étape 3/20 — Votre espace personnel : favoris, progression et historique de formations.", highlightViewCornerRadius: 25)

            }
            .padding(.horizontal, MadiniaSpacing.xs)
            .padding(.vertical, MadiniaSpacing.xs)
            .modifier(LiquidGlassModifier())

            // Right group: Recherche
            tabButton(for: .search)
                .showCoachMark(order: 3, title: "Recherche", description: "Étape 4/20 — Trouvez rapidement une formation, un service ou une catégorie.", highlightViewCornerRadius: 25)

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

    // MARK: - iPad Sidebar Button

    private func iPadSidebarButton(for tab: MainTab) -> some View {
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
