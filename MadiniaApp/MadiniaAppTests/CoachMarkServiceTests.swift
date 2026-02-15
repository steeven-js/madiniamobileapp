//
//  CoachMarkServiceTests.swift
//  MadiniaAppTests
//
//  Tests for CoachMarkService guided tour logic (state transitions, navigation, skip/replay).
//

import XCTest
@testable import MadiniaApp

/// Unit tests for the CoachMarkService
final class CoachMarkServiceTests: XCTestCase {

    // MARK: - Properties

    private var coachMarkService: CoachMarkService!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        coachMarkService = CoachMarkService.shared

        // Reset state to a clean baseline for each test
        resetAllState()
    }

    override func tearDownWithError() throws {
        resetAllState()
        coachMarkService = nil
        try super.tearDownWithError()
    }

    /// Resets all CoachMarkService state to default values
    private func resetAllState() {
        let service = CoachMarkService.shared

        // Reset UserDefaults-backed properties
        service.hasSeenTour = false
        service.pendingReplay = false

        // Reset navigation
        service.pendingTabNavigation = nil
        service.pendingFormationSlug = nil

        // Reset active step to initial state (new user)
        service.activeTipStep = 1

        // Reset all main tour @Parameter chain values
        MadiniaTabTip.hasDismissedHomeTab = false
        UserSpaceTabTip.hasDismissedMadiniaTab = false
        SearchTabTip.hasDismissedUserSpaceTab = false
        MadiFABTip.hasDismissedSearchTab = false
        SettingsTip.hasDismissedMadiFAB = false
        CustomizeHomeTip.hasDismissedSettings = false
        SearchFiltersTip.hasDismissedCustomizeHome = false
        MainTourGate.hasCompleted = false

        // Reset all contextual tip @Parameter chain values
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
    }

    // MARK: - Singleton Tests

    /// Verify CoachMarkService uses singleton pattern
    func testSingletonInstance() {
        let instance1 = CoachMarkService.shared
        let instance2 = CoachMarkService.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Initial State Tests

    /// New user (hasSeenTour = false) should start at step 1
    func testInitialActiveTipStepForNewUser() {
        coachMarkService.hasSeenTour = false
        // After resetAllState, activeTipStep is set to 1
        XCTAssertEqual(coachMarkService.activeTipStep, 1)
    }

    /// Navigation properties should be nil at start
    func testInitialNavigationStateIsNil() {
        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertNil(coachMarkService.pendingFormationSlug)
    }

    // MARK: - Main Tour Dismiss Handlers (Tips 1→8)

    /// Test the full main tour chain: tips 1→2→3→4→5→6→7→8
    func testMainTourDismissHandlers() {
        // Start at step 1
        coachMarkService.activeTipStep = 1

        // Tip 1 → 2
        coachMarkService.didDismissHomeTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 2)
        XCTAssertTrue(MadiniaTabTip.hasDismissedHomeTab)

        // Tip 2 → 3
        coachMarkService.didDismissMadiniaTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 3)
        XCTAssertTrue(UserSpaceTabTip.hasDismissedMadiniaTab)

        // Tip 3 → 4
        coachMarkService.didDismissUserSpaceTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 4)
        XCTAssertTrue(SearchTabTip.hasDismissedUserSpaceTab)

        // Tip 4 → 5
        coachMarkService.didDismissSearchTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 5)
        XCTAssertTrue(MadiFABTip.hasDismissedSearchTab)

        // Tip 5 → 6
        coachMarkService.didDismissMadiFABTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 6)
        XCTAssertTrue(SettingsTip.hasDismissedMadiFAB)

        // Tip 6 → 7
        coachMarkService.didDismissSettingsTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 7)
        XCTAssertTrue(CustomizeHomeTip.hasDismissedSettings)

        // Tip 7 → 8
        coachMarkService.didDismissCustomizeHomeTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 8)
        XCTAssertTrue(SearchFiltersTip.hasDismissedCustomizeHome)
    }

    // MARK: - Hub Dismiss Handlers (Tips 9→12)

    /// Test the hub contextual chain: tips 9→10→11→12
    func testHubDismissHandlers() {
        coachMarkService.activeTipStep = 9

        // Tip 9 → 10
        coachMarkService.didDismissHubAboutTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 10)
        XCTAssertTrue(HubBlogTabTip.hasSeenAbout)

        // Tip 10 → 11
        coachMarkService.didDismissHubBlogTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 11)
        XCTAssertTrue(HubEventsTabTip.hasSeenBlog)

        // Tip 11 → 12
        coachMarkService.didDismissHubEventsTabTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 12)
        XCTAssertTrue(HubContactTabTip.hasSeenEvents)
    }

    // MARK: - User Space Dismiss Handlers (Tips 13→16)

    /// Test the user space contextual chain: tips 13→14→15→16
    func testUserSpaceDismissHandlers() {
        coachMarkService.activeTipStep = 13

        // Tip 13 → 14
        coachMarkService.didDismissSavedFormationsTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 14)
        XCTAssertTrue(PreRegistrationsTip.hasSeenSaved)

        // Tip 14 → 15
        coachMarkService.didDismissPreRegistrationsTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 15)
        XCTAssertTrue(ProgressTip.hasSeenPreReg)

        // Tip 15 → 16
        coachMarkService.didDismissProgressTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 16)
        XCTAssertTrue(HistoryTip.hasSeenProgress)
    }

    // MARK: - Detail Dismiss Handlers (Tips 17→20→nil)

    /// Test the detail contextual chain: tips 17→18→19→20→nil
    func testDetailDismissHandlers() {
        coachMarkService.activeTipStep = 17

        // Tip 17 → 18
        coachMarkService.didDismissFavoriteTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 18)
        XCTAssertTrue(OfflineDownloadTip.hasSeenFavorite)

        // Tip 18 → 19
        coachMarkService.didDismissOfflineDownloadTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 19)
        XCTAssertTrue(ShareTip.hasSeenDownload)

        // Tip 19 → 20
        coachMarkService.didDismissShareTip()
        XCTAssertEqual(coachMarkService.activeTipStep, 20)
        XCTAssertTrue(PreRegistrationCTATip.hasSeenShare)

        // Tip 20 → nil (tour complete)
        coachMarkService.didDismissPreRegistrationCTATip()
        XCTAssertNil(coachMarkService.activeTipStep)
    }

    // MARK: - Navigation Tests
    // Note: Dismiss handlers schedule navigation via `Task { @MainActor in sleep(400ms); ... }`.
    // These fire-and-forget Swift concurrency tasks cannot be drained in XCTest synchronously.
    // We verify the synchronous effects (step + parameter) and that navigation is deferred (not set immediately).

    /// Tip 1 dismissed → navigation is deferred (not set synchronously), step advances to 2
    func testDismissHomeTabDefersNavigation() {
        coachMarkService.activeTipStep = 1
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissHomeTabTip()

        // Navigation is async (400ms delay) — not set immediately
        XCTAssertNil(coachMarkService.pendingTabNavigation)
        // But step and parameter are set synchronously
        XCTAssertEqual(coachMarkService.activeTipStep, 2)
        XCTAssertTrue(MadiniaTabTip.hasDismissedHomeTab)
    }

    /// Tip 2 dismissed → navigation is deferred, step advances to 3
    func testDismissMadiniaTabDefersNavigation() {
        coachMarkService.activeTipStep = 2
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissMadiniaTabTip()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertEqual(coachMarkService.activeTipStep, 3)
        XCTAssertTrue(UserSpaceTabTip.hasDismissedMadiniaTab)
    }

    /// Tip 3 dismissed → navigation is deferred, step advances to 4
    func testDismissUserSpaceTabDefersNavigation() {
        coachMarkService.activeTipStep = 3
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissUserSpaceTabTip()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertEqual(coachMarkService.activeTipStep, 4)
        XCTAssertTrue(SearchTabTip.hasDismissedUserSpaceTab)
    }

    /// Tip 6 dismissed → navigation is deferred, step advances to 7
    func testDismissSettingsDefersNavigation() {
        coachMarkService.activeTipStep = 6
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissSettingsTip()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertEqual(coachMarkService.activeTipStep, 7)
        XCTAssertTrue(CustomizeHomeTip.hasDismissedSettings)
    }

    /// Tip 8 dismissed → navigation is deferred, step advances to 9, main tour marked complete
    func testDismissSearchFiltersDefersNavigation() {
        coachMarkService.activeTipStep = 8
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissSearchFiltersTip()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertEqual(coachMarkService.activeTipStep, 9)
        XCTAssertTrue(coachMarkService.hasSeenTour)
        XCTAssertTrue(MainTourGate.hasCompleted)
    }

    /// Tip 12 dismissed → navigation is deferred, step advances to 13
    func testDismissHubContactDefersNavigation() {
        coachMarkService.activeTipStep = 12
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissHubContactTabTip()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertEqual(coachMarkService.activeTipStep, 13)
        XCTAssertTrue(SavedFormationsTip.hasSeenHubContact)
    }

    /// Tip 16 dismissed → step advances to 17, formation slug navigation is deferred
    func testDismissHistoryDefersNavigation() {
        coachMarkService.activeTipStep = 16
        coachMarkService.pendingFormationSlug = nil
        coachMarkService.didDismissHistoryTip()

        // Step advances immediately
        XCTAssertEqual(coachMarkService.activeTipStep, 17)
        // Slug is set asynchronously (600ms delay) — not set immediately
        XCTAssertNil(coachMarkService.pendingFormationSlug)
    }

    // MARK: - Skip Tour Tests

    /// Skip tour should set all @Parameter values to true
    func testSkipTourSetsAllParametersTrue() {
        coachMarkService.activeTipStep = 3 // Mid-tour

        coachMarkService.skipTour()

        // Main tour parameters
        XCTAssertTrue(MadiniaTabTip.hasDismissedHomeTab)
        XCTAssertTrue(UserSpaceTabTip.hasDismissedMadiniaTab)
        XCTAssertTrue(SearchTabTip.hasDismissedUserSpaceTab)
        XCTAssertTrue(MadiFABTip.hasDismissedSearchTab)
        XCTAssertTrue(SettingsTip.hasDismissedMadiFAB)
        XCTAssertTrue(CustomizeHomeTip.hasDismissedSettings)
        XCTAssertTrue(SearchFiltersTip.hasDismissedCustomizeHome)
        XCTAssertTrue(MainTourGate.hasCompleted)

        // Hub contextual parameters
        XCTAssertTrue(HubBlogTabTip.hasSeenAbout)
        XCTAssertTrue(HubEventsTabTip.hasSeenBlog)
        XCTAssertTrue(HubContactTabTip.hasSeenEvents)

        // User space contextual parameters
        XCTAssertTrue(SavedFormationsTip.hasSeenHubContact)
        XCTAssertTrue(PreRegistrationsTip.hasSeenSaved)
        XCTAssertTrue(ProgressTip.hasSeenPreReg)
        XCTAssertTrue(HistoryTip.hasSeenProgress)

        // Detail contextual parameters
        XCTAssertTrue(FavoriteTip.hasSeenHistory)
        XCTAssertTrue(OfflineDownloadTip.hasSeenFavorite)
        XCTAssertTrue(ShareTip.hasSeenDownload)
        XCTAssertTrue(PreRegistrationCTATip.hasSeenShare)
    }

    /// Skip tour should clear navigation state and set activeTipStep to nil
    func testSkipTourClearsNavigationAndStep() {
        coachMarkService.activeTipStep = 5
        coachMarkService.pendingTabNavigation = .search

        coachMarkService.skipTour()

        XCTAssertNil(coachMarkService.activeTipStep)
        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertNil(coachMarkService.pendingFormationSlug)
    }

    /// Skip tour should mark hasSeenTour as true
    func testSkipTourMarksHasSeenTour() {
        XCTAssertFalse(coachMarkService.hasSeenTour)

        coachMarkService.skipTour()

        XCTAssertTrue(coachMarkService.hasSeenTour)
    }

    // MARK: - Replay Tests

    /// Replay should set pendingReplay to true
    func testReplayTourSchedulesPending() {
        XCTAssertFalse(coachMarkService.pendingReplay)

        coachMarkService.replayTour()

        XCTAssertTrue(coachMarkService.pendingReplay)
    }

    /// Replay should clear hasSeenTour
    func testReplayTourClearsHasSeenTour() {
        coachMarkService.hasSeenTour = true

        coachMarkService.replayTour()

        XCTAssertFalse(coachMarkService.hasSeenTour)
    }

    // MARK: - Tour Completion Tests

    /// Dismissing tip 20 should set activeTipStep to nil
    func testFullTourCompletionSetsActiveTipStepNil() {
        coachMarkService.activeTipStep = 20

        coachMarkService.didDismissPreRegistrationCTATip()

        XCTAssertNil(coachMarkService.activeTipStep)
    }

    // MARK: - Tip 8 Completion Sets hasSeenTour

    /// Dismissing tip 8 (end of main tour) should mark hasSeenTour and MainTourGate
    func testDismissSearchFiltersSetsHasSeenTour() {
        XCTAssertFalse(coachMarkService.hasSeenTour)
        XCTAssertFalse(MainTourGate.hasCompleted)

        coachMarkService.didDismissSearchFiltersTip()

        XCTAssertTrue(coachMarkService.hasSeenTour)
        XCTAssertTrue(MainTourGate.hasCompleted)
        XCTAssertEqual(coachMarkService.activeTipStep, 9)
    }

    // MARK: - Skip Tour Idempotency

    /// Calling skipTour twice should not cause issues (guard against isSkippingTour)
    func testSkipTourIsIdempotent() {
        coachMarkService.activeTipStep = 3
        coachMarkService.skipTour()
        XCTAssertNil(coachMarkService.activeTipStep)

        // Second call should be a no-op (isSkippingTour resets to false after first skip)
        coachMarkService.activeTipStep = 5
        coachMarkService.skipTour()
        XCTAssertNil(coachMarkService.activeTipStep)
    }

    // MARK: - Navigation Not Triggered During Skip

    /// When isSkippingTour is active, dismiss handlers should NOT trigger navigation
    func testDismissHandlerSkipsNavigationDuringSkip() {
        // skipTour internally calls isSkippingTour = true, then sets parameters, then false
        // We test that after skipTour, pendingTabNavigation stays nil
        coachMarkService.activeTipStep = 1
        coachMarkService.skipTour()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    // MARK: - Hub Contact Navigation

    /// Tip 7 dismissed → navigation is deferred, step advances to 8
    func testDismissCustomizeHomeDefersNavigation() {
        coachMarkService.activeTipStep = 7
        coachMarkService.pendingTabNavigation = nil
        coachMarkService.didDismissCustomizeHomeTip()

        XCTAssertNil(coachMarkService.pendingTabNavigation)
        XCTAssertEqual(coachMarkService.activeTipStep, 8)
        XCTAssertTrue(SearchFiltersTip.hasDismissedCustomizeHome)
    }

    // MARK: - Tips Without Navigation

    /// Tips 4 and 5 should NOT trigger any navigation (no tab switch needed)
    func testDismissSearchTabDoesNotNavigate() {
        coachMarkService.activeTipStep = 4
        coachMarkService.pendingTabNavigation = nil

        coachMarkService.didDismissSearchTabTip()

        XCTAssertEqual(coachMarkService.activeTipStep, 5)
        // No async navigation for this tip — pendingTabNavigation stays nil
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    func testDismissMadiFABDoesNotNavigate() {
        coachMarkService.activeTipStep = 5
        coachMarkService.pendingTabNavigation = nil

        coachMarkService.didDismissMadiFABTip()

        XCTAssertEqual(coachMarkService.activeTipStep, 6)
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    // MARK: - Hub Tips Without Navigation

    /// Hub tips 9→10→11 should NOT trigger navigation (same screen)
    func testHubAboutDoesNotNavigate() {
        coachMarkService.activeTipStep = 9
        coachMarkService.didDismissHubAboutTabTip()
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    func testHubBlogDoesNotNavigate() {
        coachMarkService.activeTipStep = 10
        coachMarkService.didDismissHubBlogTabTip()
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    func testHubEventsDoesNotNavigate() {
        coachMarkService.activeTipStep = 11
        coachMarkService.didDismissHubEventsTabTip()
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    // MARK: - User Space Tips Without Navigation

    /// User space tips 13→14→15 should NOT trigger navigation (same screen)
    func testSavedFormationsDoesNotNavigate() {
        coachMarkService.activeTipStep = 13
        coachMarkService.didDismissSavedFormationsTip()
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    func testPreRegistrationsDoesNotNavigate() {
        coachMarkService.activeTipStep = 14
        coachMarkService.didDismissPreRegistrationsTip()
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }

    func testProgressDoesNotNavigate() {
        coachMarkService.activeTipStep = 15
        coachMarkService.didDismissProgressTip()
        XCTAssertNil(coachMarkService.pendingTabNavigation)
    }
}
