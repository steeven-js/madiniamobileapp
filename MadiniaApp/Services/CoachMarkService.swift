//
//  CoachMarkService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-09.
//

import SwiftUI

/// Tour groups — one per screen context
enum TourGroup: Int, CaseIterable {
    case tabBar = 0    // Steps 1-6: tab buttons, FAB, settings
    case home = 1      // Step 7: customize home button
    case search = 2    // Step 8: search filters
    case hub = 3       // Steps 9-12: hub sub-tabs
    case userSpace = 4 // Steps 13-16: user space cards
    case detail = 5    // Steps 17-20: detail view buttons
}

/// Service managing the sequential coach marks tour for new users.
/// Uses SSCoachMarks with group-based orchestration across screens.
@Observable
final class CoachMarkService {
    static let shared = CoachMarkService()

    // MARK: - Tour State

    /// Currently active tour group — nil means no tour running
    var activeTourGroup: TourGroup?

    /// Token that changes on replay, used as .id() to force view recreation
    var tourReplayToken = UUID()

    // MARK: - Navigation

    /// Pending tab navigation — observed in MainTabView to switch tabs automatically
    var pendingTabNavigation: MainTab?

    /// Pending formation slug — observed in MainTabView to open a formation detail
    var pendingFormationSlug: String?

    // MARK: - Persistence

    /// Whether the user has completed the full tour at least once
    var hasSeenTour: Bool {
        get { UserDefaults.standard.bool(forKey: "coachMark_hasSeenTour") }
        set { UserDefaults.standard.set(newValue, forKey: "coachMark_hasSeenTour") }
    }

    /// Flag set when user requests replay
    var pendingReplay: Bool {
        get { UserDefaults.standard.bool(forKey: "coachMark_pendingReplay") }
        set { UserDefaults.standard.set(newValue, forKey: "coachMark_pendingReplay") }
    }

    private init() {
        if !hasSeenTour {
            activeTourGroup = .tabBar
        }
    }

    // MARK: - Group Transition

    /// Called when a CoachMarkView group finishes all its steps.
    /// Advances to the next group and triggers tab navigation.
    func onGroupFinished(group: TourGroup) {
        switch group {
        case .tabBar:
            // After tab bar tour (steps 1-6), go directly to Search for step 8
            activeTourGroup = .search
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                self.pendingTabNavigation = .search
            }

        case .home:
            // Skipped — no longer used
            activeTourGroup = .search
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                self.pendingTabNavigation = .search
            }

        case .search:
            // After Search tour (step 8), go to Hub for steps 9-12
            hasSeenTour = true
            activeTourGroup = .hub
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                self.pendingTabNavigation = .madinia
            }

        case .hub:
            // After Hub tour (steps 9-12), go to UserSpace for steps 13-16
            activeTourGroup = .userSpace
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                self.pendingTabNavigation = .userSpace
            }

        case .userSpace:
            // After UserSpace tour (steps 13-16), open a formation detail for steps 17-20
            activeTourGroup = .detail
            if let firstFormation = AppDataRepository.shared.formations.first {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(600))
                    self.pendingFormationSlug = firstFormation.slug
                }
            } else {
                // No formation available, end tour
                activeTourGroup = nil
                print("[CoachMarks] No formations available for detail tour")
            }

        case .detail:
            // Tour complete!
            activeTourGroup = nil
            print("[CoachMarks] Full tour completed!")
        }
    }

    // MARK: - Skip Tour

    /// Skip the entire guided tour immediately.
    func skipTour() {
        hasSeenTour = true
        activeTourGroup = nil
        pendingTabNavigation = nil
        pendingFormationSlug = nil
        print("[CoachMarks] Tour skipped by user")
    }

    // MARK: - Replay

    /// Marks tour for replay
    func replayTour() {
        pendingReplay = true
        hasSeenTour = false
        print("[CoachMarks] Tour replay scheduled for next launch")
    }

    /// Called once at app startup. Performs the replay if requested.
    func performPendingReplayIfNeeded() {
        guard pendingReplay else { return }
        pendingReplay = false
        pendingTabNavigation = nil
        pendingFormationSlug = nil
        activeTourGroup = .tabBar
        tourReplayToken = UUID()
        print("[CoachMarks] Pending replay applied")
    }
}

// MARK: - Conditional CoachMarkView Extension

import SSCoachMarks

extension View {
    /// Conditionally applies a CoachMarkView modifier only when the specified tour group is active.
    /// This ensures only one CoachMarkView is active at a time across the entire app.
    @ViewBuilder
    func conditionalCoachMarkView(
        active: Bool,
        onFinished: @escaping () -> Void
    ) -> some View {
        if active {
            let skipButton = AnyView(
                Button {
                    CoachMarkService.shared.skipTour()
                } label: {
                    Text("Passer le guide")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            )

            self.modifier(
                CoachMarkView(
                    skipCoachMarkButton: skipButton,
                    backButtonContent: skipButton,
                    onCoachMarkFinished: onFinished
                )
                .nextButtonStyle(buttonText: "Suivant",
                                 foregroundStyle: .white,
                                 backgroundColor: MadiniaColors.accent,
                                 fontSize: 15,
                                 fontWeight: .semibold)
                .doneButtonStyle(buttonText: "Terminer",
                                 foregroundStyle: .white,
                                 backgroundColor: MadiniaColors.accent,
                                 fontSize: 15,
                                 fontWeight: .semibold)
                .overlayStyle(overlayColor: .black, overlayOpacity: 0.75)
            )
        } else {
            self
        }
    }
}
