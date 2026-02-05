//
//  OnboardingFlowView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI

/// Container view managing the onboarding flow navigation.
/// Uses a TabView with page style for swipeable navigation between steps.
struct OnboardingFlowView: View {
    /// Optional callback when onboarding is completed (used when presented modally)
    var onComplete: (() -> Void)?

    /// Current step index
    @State private var currentStep = 0

    /// Onboarding service for completion tracking
    private let onboardingService = OnboardingService.shared

    /// Reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Total number of onboarding steps
    private let totalSteps = 4

    var body: some View {
        TabView(selection: $currentStep) {
            OnboardingWelcomeView(onContinue: goToNextStep)
                .tag(0)

            OnboardingInterestsView(onContinue: goToNextStep)
                .tag(1)

            OnboardingNotificationsView(onContinue: goToNextStep)
                .tag(2)

            OnboardingCompleteView(onFinish: completeOnboarding)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: currentStep)
    }

    // MARK: - Navigation

    /// Advances to the next step
    private func goToNextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    /// Goes back to the previous step
    private func goToPreviousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    /// Completes the onboarding and dismisses the flow
    private func completeOnboarding() {
        onboardingService.completeOnboarding()
        onComplete?()
    }
}

// MARK: - Onboarding Replay View

/// Wrapper view for replaying onboarding from Settings.
/// Handles dismiss and allows users to update their interests.
struct OnboardingReplayView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        OnboardingFlowView(onComplete: {
            dismiss()
        })
    }
}

// MARK: - Previews

#Preview("Onboarding Flow") {
    OnboardingFlowView()
}

#Preview("Onboarding Flow - Step 2") {
    struct PreviewWrapper: View {
        @State private var step = 1

        var body: some View {
            TabView(selection: $step) {
                OnboardingWelcomeView { step = 1 }
                    .tag(0)
                OnboardingInterestsView { step = 2 }
                    .tag(1)
                OnboardingNotificationsView { step = 3 }
                    .tag(2)
                OnboardingCompleteView { }
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }

    return PreviewWrapper()
}
