//
//  CoachMarkService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-09.
//

import SwiftUI
import TipKit

/// Service managing the sequential coach marks tour for new users.
/// Uses TipKit with @Parameter-based rules to chain tips sequentially.
@Observable
final class CoachMarkService {
    static let shared = CoachMarkService()

    // MARK: - Tips

    var homeTabTip = HomeTabTip()
    var madiniaTabTip = MadiniaTabTip()
    var userSpaceTabTip = UserSpaceTabTip()
    var searchTabTip = SearchTabTip()
    var madiFABTip = MadiFABTip()
    var settingsTip = SettingsTip()
    var customizeHomeTip = CustomizeHomeTip()
    var searchFiltersTip = SearchFiltersTip()

    // MARK: - Contextual Tips (Hub)

    var hubAboutTabTip = HubAboutTabTip()
    var hubBlogTabTip = HubBlogTabTip()
    var hubEventsTabTip = HubEventsTabTip()
    var hubContactTabTip = HubContactTabTip()

    // MARK: - Contextual Tips (User Space)

    var savedFormationsTip = SavedFormationsTip()
    var preRegistrationsTip = PreRegistrationsTip()
    var progressTip = ProgressTip()
    var historyTip = HistoryTip()

    // MARK: - Contextual Tips (Detail)

    var favoriteTip = FavoriteTip()
    var offlineDownloadTip = OfflineDownloadTip()
    var shareTip = ShareTip()
    var preRegistrationCTATip = PreRegistrationCTATip()

    /// Token that changes on replay, used as .id() to force view recreation
    var tourReplayToken = UUID()

    // MARK: - Navigation

    /// Pending tab navigation — observed in MainTabView to switch tabs automatically
    var pendingTabNavigation: MainTab?

    /// Pending formation slug — observed in MainTabView to open a formation detail
    var pendingFormationSlug: String?

    // MARK: - Active Highlight

    /// The currently active tip step (1-20), used by views to highlight the target element in yellow.
    /// Set to nil when no tip should be highlighted (e.g. during skip or after tour is done).
    var activeTipStep: Int?

    /// Frame of the currently highlighted element in global coordinates, used for the spotlight cutout.
    var highlightFrame: CGRect = .zero

    /// Shape type of the current highlight, used for the spotlight cutout shape.
    var highlightShapeType: TourHighlightShape = .roundedRect

    // MARK: - Skip State

    /// Guard flag to prevent dismiss handlers from triggering navigation during skip
    private(set) var isSkippingTour = false


    // MARK: - Tour State

    /// Whether the user has completed the full tour at least once
    var hasSeenTour: Bool {
        get { UserDefaults.standard.bool(forKey: "coachMark_hasSeenTour") }
        set { UserDefaults.standard.set(newValue, forKey: "coachMark_hasSeenTour") }
    }

    /// Flag set when user requests replay — actual reset happens on next launch
    var pendingReplay: Bool {
        get { UserDefaults.standard.bool(forKey: "coachMark_pendingReplay") }
        set { UserDefaults.standard.set(newValue, forKey: "coachMark_pendingReplay") }
    }

    private init() {
        // Migration: if user already completed the tour before contextual tips existed,
        // gate the contextual tips so they can appear
        if hasSeenTour && !MainTourGate.hasCompleted {
            MainTourGate.hasCompleted = true
        }
        // If the tour hasn't been seen yet, start highlighting step 1
        if !hasSeenTour {
            activeTipStep = 1
        }
    }

    // MARK: - Advance Tour

    /// Advances to the next step by calling the appropriate dismiss handler for the current step.
    /// Called from TipKit action perform closures ("Suivant") and from status observers (X button).
    func advanceToNextStep() {
        guard let currentStep = activeTipStep, !isSkippingTour else { return }

        // Invalidate the current tip so it disappears visually
        switch currentStep {
        case 1: homeTabTip.invalidate(reason: .actionPerformed)
        case 2: madiniaTabTip.invalidate(reason: .actionPerformed)
        case 3: userSpaceTabTip.invalidate(reason: .actionPerformed)
        case 4: searchTabTip.invalidate(reason: .actionPerformed)
        case 5: madiFABTip.invalidate(reason: .actionPerformed)
        case 6: settingsTip.invalidate(reason: .actionPerformed)
        case 7: customizeHomeTip.invalidate(reason: .actionPerformed)
        case 8: searchFiltersTip.invalidate(reason: .actionPerformed)
        case 9: hubAboutTabTip.invalidate(reason: .actionPerformed)
        case 10: hubBlogTabTip.invalidate(reason: .actionPerformed)
        case 11: hubEventsTabTip.invalidate(reason: .actionPerformed)
        case 12: hubContactTabTip.invalidate(reason: .actionPerformed)
        case 13: savedFormationsTip.invalidate(reason: .actionPerformed)
        case 14: preRegistrationsTip.invalidate(reason: .actionPerformed)
        case 15: progressTip.invalidate(reason: .actionPerformed)
        case 16: historyTip.invalidate(reason: .actionPerformed)
        case 17: favoriteTip.invalidate(reason: .actionPerformed)
        case 18: offlineDownloadTip.invalidate(reason: .actionPerformed)
        case 19: shareTip.invalidate(reason: .actionPerformed)
        case 20: preRegistrationCTATip.invalidate(reason: .actionPerformed)
        default: break
        }

        // Advance to next step
        switch currentStep {
        case 1: didDismissHomeTabTip()
        case 2: didDismissMadiniaTabTip()
        case 3: didDismissUserSpaceTabTip()
        case 4: didDismissSearchTabTip()
        case 5: didDismissMadiFABTip()
        case 6: didDismissSettingsTip()
        case 7: didDismissCustomizeHomeTip()
        case 8: didDismissSearchFiltersTip()
        case 9: didDismissHubAboutTabTip()
        case 10: didDismissHubBlogTabTip()
        case 11: didDismissHubEventsTabTip()
        case 12: didDismissHubContactTabTip()
        case 13: didDismissSavedFormationsTip()
        case 14: didDismissPreRegistrationsTip()
        case 15: didDismissProgressTip()
        case 16: didDismissHistoryTip()
        case 17: didDismissFavoriteTip()
        case 18: didDismissOfflineDownloadTip()
        case 19: didDismissShareTip()
        case 20: didDismissPreRegistrationCTATip()
        default: break
        }
    }

    // MARK: - Skip Tour

    /// Skip the entire guided tour immediately.
    /// Called when user taps "Passer le guide" on any tip.
    func skipTour() {
        guard !isSkippingTour else { return }
        isSkippingTour = true

        // Mark main tour as complete
        hasSeenTour = true
        MainTourGate.hasCompleted = true

        // Set all main tour chain parameters
        MadiniaTabTip.hasDismissedHomeTab = true
        UserSpaceTabTip.hasDismissedMadiniaTab = true
        SearchTabTip.hasDismissedUserSpaceTab = true
        MadiFABTip.hasDismissedSearchTab = true
        SettingsTip.hasDismissedMadiFAB = true
        CustomizeHomeTip.hasDismissedSettings = true
        SearchFiltersTip.hasDismissedCustomizeHome = true

        // Set all contextual tip chain parameters
        HubBlogTabTip.hasSeenAbout = true
        HubEventsTabTip.hasSeenBlog = true
        HubContactTabTip.hasSeenEvents = true
        SavedFormationsTip.hasSeenHubContact = true
        PreRegistrationsTip.hasSeenSaved = true
        ProgressTip.hasSeenPreReg = true
        HistoryTip.hasSeenProgress = true
        FavoriteTip.hasSeenHistory = true
        OfflineDownloadTip.hasSeenFavorite = true
        ShareTip.hasSeenDownload = true
        PreRegistrationCTATip.hasSeenShare = true

        // Invalidate all tip instances
        homeTabTip.invalidate(reason: .actionPerformed)
        madiniaTabTip.invalidate(reason: .actionPerformed)
        userSpaceTabTip.invalidate(reason: .actionPerformed)
        searchTabTip.invalidate(reason: .actionPerformed)
        madiFABTip.invalidate(reason: .actionPerformed)
        settingsTip.invalidate(reason: .actionPerformed)
        customizeHomeTip.invalidate(reason: .actionPerformed)
        searchFiltersTip.invalidate(reason: .actionPerformed)
        hubAboutTabTip.invalidate(reason: .actionPerformed)
        hubBlogTabTip.invalidate(reason: .actionPerformed)
        hubEventsTabTip.invalidate(reason: .actionPerformed)
        hubContactTabTip.invalidate(reason: .actionPerformed)
        savedFormationsTip.invalidate(reason: .actionPerformed)
        preRegistrationsTip.invalidate(reason: .actionPerformed)
        progressTip.invalidate(reason: .actionPerformed)
        historyTip.invalidate(reason: .actionPerformed)
        favoriteTip.invalidate(reason: .actionPerformed)
        offlineDownloadTip.invalidate(reason: .actionPerformed)
        shareTip.invalidate(reason: .actionPerformed)
        preRegistrationCTATip.invalidate(reason: .actionPerformed)

        // Clear navigation and highlight
        pendingTabNavigation = nil
        pendingFormationSlug = nil
        activeTipStep = nil

        isSkippingTour = false
        print("[CoachMarks] Tour skipped by user")
    }

    // MARK: - Main Tour Dismiss Handlers (Tips 1-8)

    /// Tip 1 (Home tab) dismissed → unlock tip 2, navigate to Madin.IA
    func didDismissHomeTabTip() {
        MadiniaTabTip.hasDismissedHomeTab = true
        activeTipStep = 2
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .madinia
        }
    }

    /// Tip 2 (Madin.IA tab) dismissed → unlock tip 3, navigate to L'IA&Vous
    func didDismissMadiniaTabTip() {
        UserSpaceTabTip.hasDismissedMadiniaTab = true
        activeTipStep = 3
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .userSpace
        }
    }

    /// Tip 3 (L'IA&Vous tab) dismissed → unlock tip 4, navigate to Search
    func didDismissUserSpaceTabTip() {
        SearchTabTip.hasDismissedUserSpaceTab = true
        activeTipStep = 4
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .search
        }
    }

    /// Tip 4 (Search tab) dismissed → unlock tip 5 (FAB visible everywhere)
    func didDismissSearchTabTip() {
        MadiFABTip.hasDismissedSearchTab = true
        activeTipStep = 5
    }

    /// Tip 5 (Madi FAB) dismissed → unlock tip 6 (Settings visible everywhere)
    func didDismissMadiFABTip() {
        SettingsTip.hasDismissedMadiFAB = true
        activeTipStep = 6
    }

    /// Tip 6 (Settings) dismissed → unlock tip 7, navigate to Home
    func didDismissSettingsTip() {
        CustomizeHomeTip.hasDismissedSettings = true
        activeTipStep = 7
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .home
        }
    }

    /// Tip 7 (Customize Home) dismissed → unlock tip 8, navigate to Search
    func didDismissCustomizeHomeTip() {
        SearchFiltersTip.hasDismissedCustomizeHome = true
        activeTipStep = 8
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .search
        }
    }

    /// Tip 8 (Search Filters) dismissed → main tour complete, unlock contextual tips, navigate to Madin.IA
    func didDismissSearchFiltersTip() {
        hasSeenTour = true
        MainTourGate.hasCompleted = true
        activeTipStep = 9
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .madinia
        }
    }

    // MARK: - Hub Contextual Dismiss Handlers (Tips 9-12)

    /// Tip 9 (Hub About) dismissed → unlock tip 10
    func didDismissHubAboutTabTip() {
        HubBlogTabTip.hasSeenAbout = true
        activeTipStep = 10
    }

    /// Tip 10 (Hub Blog) dismissed → unlock tip 11
    func didDismissHubBlogTabTip() {
        HubEventsTabTip.hasSeenBlog = true
        activeTipStep = 11
    }

    /// Tip 11 (Hub Events) dismissed → unlock tip 12
    func didDismissHubEventsTabTip() {
        HubContactTabTip.hasSeenEvents = true
        activeTipStep = 12
    }

    /// Tip 12 (Hub Contact) dismissed → unlock tip 13, navigate to L'IA&Vous
    func didDismissHubContactTabTip() {
        SavedFormationsTip.hasSeenHubContact = true
        activeTipStep = 13
        guard !isSkippingTour else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            self.pendingTabNavigation = .userSpace
        }
    }

    // MARK: - User Space Contextual Dismiss Handlers (Tips 13-16)

    /// Tip 13 (Saved Formations) dismissed → unlock tip 14
    func didDismissSavedFormationsTip() {
        PreRegistrationsTip.hasSeenSaved = true
        activeTipStep = 14
    }

    /// Tip 14 (Pre-Registrations) dismissed → unlock tip 15
    func didDismissPreRegistrationsTip() {
        ProgressTip.hasSeenPreReg = true
        activeTipStep = 15
    }

    /// Tip 15 (Progress) dismissed → unlock tip 16
    func didDismissProgressTip() {
        HistoryTip.hasSeenProgress = true
        activeTipStep = 16
    }

    /// Tip 16 (History) dismissed → set step 17, navigate to Search + open first formation.
    /// Note: FavoriteTip.hasSeenHistory is set from UnifiedDetailView.onAppear to avoid
    /// timing issues (tip needs the view to be mounted before becoming eligible).
    func didDismissHistoryTip() {
        activeTipStep = 17
        guard !isSkippingTour else { return }
        // Navigate to search and open the first available formation
        if let firstFormation = AppDataRepository.shared.formations.first {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(600))
                self.pendingFormationSlug = firstFormation.slug
            }
        }
    }

    // MARK: - Detail Contextual Dismiss Handlers (Tips 17-20)

    /// Tip 17 (Favorite) dismissed → unlock tip 18
    func didDismissFavoriteTip() {
        OfflineDownloadTip.hasSeenFavorite = true
        activeTipStep = 18
    }

    /// Tip 18 (Offline Download) dismissed → unlock tip 19
    func didDismissOfflineDownloadTip() {
        ShareTip.hasSeenDownload = true
        activeTipStep = 19
    }

    /// Tip 19 (Share) dismissed → unlock tip 20
    func didDismissShareTip() {
        PreRegistrationCTATip.hasSeenShare = true
        activeTipStep = 20
    }

    /// Tip 20 (Pre-Registration CTA) dismissed → tour complete!
    func didDismissPreRegistrationCTATip() {
        activeTipStep = nil
        print("[CoachMarks] Full tour (20 tips) completed!")
    }

    // MARK: - Replay

    /// Marks tour for replay — actual TipKit reset happens on next app launch
    /// (Tips.resetDatastore() must be called before Tips.configure())
    func replayTour() {
        pendingReplay = true
        hasSeenTour = false
        print("[CoachMarks] Tour replay scheduled for next launch")
    }

    /// Called once at app startup, BEFORE Tips.configure().
    /// Performs the actual TipKit datastore reset if a replay was requested.
    func performPendingReplayIfNeeded() {
        guard pendingReplay else { return }

        do {
            try Tips.resetDatastore()
            print("[CoachMarks] Datastore reset successful")
        } catch {
            print("[CoachMarks] Datastore reset failed: \(error)")
        }

        // Reset main tour chain parameters
        MadiniaTabTip.hasDismissedHomeTab = false
        UserSpaceTabTip.hasDismissedMadiniaTab = false
        SearchTabTip.hasDismissedUserSpaceTab = false
        MadiFABTip.hasDismissedSearchTab = false
        SettingsTip.hasDismissedMadiFAB = false
        CustomizeHomeTip.hasDismissedSettings = false
        SearchFiltersTip.hasDismissedCustomizeHome = false
        MainTourGate.hasCompleted = false

        // Reset contextual tip chain parameters
        HubBlogTabTip.hasSeenAbout = false
        HubEventsTabTip.hasSeenBlog = false
        HubContactTabTip.hasSeenEvents = false
        SavedFormationsTip.hasSeenHubContact = false
        PreRegistrationsTip.hasSeenSaved = false
        ProgressTip.hasSeenPreReg = false
        HistoryTip.hasSeenProgress = false
        FavoriteTip.hasSeenHistory = false
        OfflineDownloadTip.hasSeenFavorite = false
        ShareTip.hasSeenDownload = false
        PreRegistrationCTATip.hasSeenShare = false

        // Clear pending navigation and highlight
        pendingTabNavigation = nil
        pendingFormationSlug = nil
        activeTipStep = 1
        isSkippingTour = false

        // Recreate fresh tip instances (main tour)
        homeTabTip = HomeTabTip()
        madiniaTabTip = MadiniaTabTip()
        userSpaceTabTip = UserSpaceTabTip()
        searchTabTip = SearchTabTip()
        madiFABTip = MadiFABTip()
        settingsTip = SettingsTip()
        customizeHomeTip = CustomizeHomeTip()
        searchFiltersTip = SearchFiltersTip()

        // Recreate fresh contextual tip instances
        hubAboutTabTip = HubAboutTabTip()
        hubBlogTabTip = HubBlogTabTip()
        hubEventsTabTip = HubEventsTabTip()
        hubContactTabTip = HubContactTabTip()
        savedFormationsTip = SavedFormationsTip()
        preRegistrationsTip = PreRegistrationsTip()
        progressTip = ProgressTip()
        historyTip = HistoryTip()
        favoriteTip = FavoriteTip()
        offlineDownloadTip = OfflineDownloadTip()
        shareTip = ShareTip()
        preRegistrationCTATip = PreRegistrationCTATip()

        tourReplayToken = UUID()
        pendingReplay = false
        print("[CoachMarks] Pending replay applied")
    }
}

// MARK: - Tour Dimming Modifier

/// Adds a semi-transparent dark overlay with a spotlight cutout around the highlighted element.
/// Applied at the MainTabView level so it covers the entire screen.
struct TourDimmingModifier: ViewModifier {
    private let coachMarks = CoachMarkService.shared

    func body(content: Content) -> some View {
        content
            .overlay {
                if coachMarks.activeTipStep != nil {
                    TourSpotlightOverlay()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: coachMarks.activeTipStep)
    }
}

/// Full-screen dark overlay with a transparent cutout where the highlighted element is.
private struct TourSpotlightOverlay: View {
    private let coachMarks = CoachMarkService.shared
    private let cutoutPadding: CGFloat = 6

    var body: some View {
        Color.black.opacity(0.5)
            .reverseMask {
                spotlightCutout
            }
    }

    @ViewBuilder
    private var spotlightCutout: some View {
        let frame = coachMarks.highlightFrame
        if frame != .zero {
            let padded = frame.insetBy(dx: -cutoutPadding, dy: -cutoutPadding)
            switch coachMarks.highlightShapeType {
            case .capsule:
                Capsule()
                    .frame(width: padded.width, height: padded.height)
                    .position(x: padded.midX, y: padded.midY)
            case .circle:
                Circle()
                    .frame(width: max(padded.width, padded.height), height: max(padded.width, padded.height))
                    .position(x: padded.midX, y: padded.midY)
            case .roundedRect:
                RoundedRectangle(cornerRadius: MadiniaRadius.md + 4)
                    .frame(width: padded.width, height: padded.height)
                    .position(x: padded.midX, y: padded.midY)
            }
        }
    }
}

// MARK: - Reverse Mask Helper

extension View {
    /// Masks this view with an inverted version of the given shape — the shape becomes transparent.
    fileprivate func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle()
                .ignoresSafeArea()
                .overlay {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

// MARK: - Tour Highlight ViewModifier

/// Adds a pulsing yellow glow around the target element during the guided tour.
/// Attach this to any view that is a tip target, passing the tip's step number.
struct TourHighlightModifier: ViewModifier {
    let step: Int
    let shape: TourHighlightShape

    @State private var isPulsing = false
    private let coachMarks = CoachMarkService.shared

    private var isActive: Bool {
        coachMarks.activeTipStep == step
    }

    func body(content: Content) -> some View {
        content
            // Report frame to CoachMarkService for spotlight cutout
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: isActive) { _, active in
                            if active {
                                coachMarks.highlightFrame = geo.frame(in: .global)
                                coachMarks.highlightShapeType = shape
                            }
                        }
                        .onAppear {
                            if isActive {
                                coachMarks.highlightFrame = geo.frame(in: .global)
                                coachMarks.highlightShapeType = shape
                            }
                        }
                }
            }
            .overlay {
                if isActive {
                    switch shape {
                    case .capsule:
                        Capsule()
                            .stroke(Color.yellow, lineWidth: 2.5)
                            .shadow(color: .yellow.opacity(isPulsing ? 0.7 : 0.3), radius: isPulsing ? 10 : 4)
                    case .circle:
                        Circle()
                            .stroke(Color.yellow, lineWidth: 2.5)
                            .shadow(color: .yellow.opacity(isPulsing ? 0.7 : 0.3), radius: isPulsing ? 10 : 4)
                    case .roundedRect:
                        RoundedRectangle(cornerRadius: MadiniaRadius.md)
                            .stroke(Color.yellow, lineWidth: 2.5)
                            .shadow(color: .yellow.opacity(isPulsing ? 0.7 : 0.3), radius: isPulsing ? 10 : 4)
                    }
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                } else {
                    isPulsing = false
                }
            }
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
            }
    }
}

enum TourHighlightShape {
    case capsule
    case circle
    case roundedRect
}

extension View {
    /// Highlights this view with a pulsing yellow glow during the given tour step.
    func tourHighlight(step: Int, shape: TourHighlightShape = .roundedRect) -> some View {
        modifier(TourHighlightModifier(step: step, shape: shape))
    }
}
