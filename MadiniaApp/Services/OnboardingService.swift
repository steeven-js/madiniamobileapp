//
//  OnboardingService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import Foundation

/// Service managing the onboarding flow state.
/// Tracks whether the user has completed onboarding and their selected interests.
@Observable
final class OnboardingService {
    /// Shared singleton instance
    static let shared = OnboardingService()

    // MARK: - UserDefaults Keys

    private let completedKey = "onboarding_completed"
    private let interestsKey = "onboarding_interests"

    // MARK: - Properties

    /// Whether the user has completed the onboarding flow
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: completedKey) }
        set { UserDefaults.standard.set(newValue, forKey: completedKey) }
    }

    /// The slugs/IDs of user-selected interests
    var selectedInterests: [String] {
        get { UserDefaults.standard.stringArray(forKey: interestsKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: interestsKey) }
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Marks the onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    /// Adds an interest to the selection
    func addInterest(_ interest: String) {
        var interests = selectedInterests
        if !interests.contains(interest) {
            interests.append(interest)
            selectedInterests = interests
        }
    }

    /// Removes an interest from the selection
    func removeInterest(_ interest: String) {
        var interests = selectedInterests
        interests.removeAll { $0 == interest }
        selectedInterests = interests
    }

    /// Toggles an interest selection
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            removeInterest(interest)
        } else {
            addInterest(interest)
        }
    }

    /// Checks if an interest is selected
    func isInterestSelected(_ interest: String) -> Bool {
        selectedInterests.contains(interest)
    }

    /// Resets onboarding state (for testing)
    func reset() {
        hasCompletedOnboarding = false
        selectedInterests = []
    }
}
