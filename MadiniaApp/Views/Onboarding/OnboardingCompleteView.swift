//
//  OnboardingCompleteView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI

/// Final screen of the onboarding flow.
/// Shows success animation and summary of selected interests.
struct OnboardingCompleteView: View {
    /// Callback when user taps finish
    let onFinish: () -> Void

    /// Onboarding service for reading selections
    @State private var onboardingService = OnboardingService.shared

    /// Animation states
    @State private var checkmarkAnimated = false
    @State private var contentAnimated = false

    /// Reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Success animation section
            successSection

            Spacer()

            // Content section
            contentSection

            Spacer()

            // Bottom section
            bottomSection
        }
        .padding(MadiniaSpacing.lg)
        .background(MadiniaColors.surfaceBackground)
        .onAppear {
            animateContent()
        }
    }

    // MARK: - Success Section

    private var successSection: some View {
        ZStack {
            // Background circles
            Circle()
                .fill(MadiniaColors.accent.opacity(0.1))
                .frame(width: 180, height: 180)

            Circle()
                .fill(MadiniaColors.accent.opacity(0.2))
                .frame(width: 120, height: 120)
                .scaleEffect(checkmarkAnimated ? 1.0 : 0.0)

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(MadiniaColors.accent)
                .scaleEffect(checkmarkAnimated ? 1.0 : 0.0)
                .rotationEffect(.degrees(checkmarkAnimated ? 0 : -90))
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            Text("Vous êtes prêt !")
                .font(MadiniaTypography.largeTitle)
                .foregroundStyle(MadiniaColors.darkGray)
                .multilineTextAlignment(.center)
                .opacity(contentAnimated ? 1.0 : 0.0)
                .offset(y: contentAnimated ? 0 : 20)

            Text("Votre expérience Madin.IA est maintenant personnalisée")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.md)
                .opacity(contentAnimated ? 1.0 : 0.0)
                .offset(y: contentAnimated ? 0 : 20)

            // Selected interests summary
            if !onboardingService.selectedInterests.isEmpty {
                interestsSummary
                    .opacity(contentAnimated ? 1.0 : 0.0)
                    .offset(y: contentAnimated ? 0 : 20)
            }
        }
    }

    private var interestsSummary: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Text("Vos centres d'intérêt")
                .font(MadiniaTypography.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            FlowLayout(spacing: MadiniaSpacing.xxs) {
                ForEach(onboardingService.selectedInterests, id: \.self) { interest in
                    Text(interestDisplayName(interest))
                        .font(MadiniaTypography.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, MadiniaSpacing.xs)
                        .padding(.vertical, MadiniaSpacing.xxs)
                        .background(MadiniaColors.accent.opacity(0.15))
                        .foregroundStyle(MadiniaColors.accent)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(MadiniaSpacing.md)
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        .padding(.top, MadiniaSpacing.md)
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Finish button
            Button {
                onFinish()
            } label: {
                HStack(spacing: MadiniaSpacing.xs) {
                    Text("Découvrir l'app")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(MadiniaColors.darkGrayFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MadiniaSpacing.md)
                .background(MadiniaColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }

            // Progress dots
            ProgressDots(currentStep: 3, totalSteps: 4)
                .padding(.bottom, MadiniaSpacing.md)
        }
    }

    // MARK: - Animations

    private func animateContent() {
        if reduceMotion {
            checkmarkAnimated = true
            contentAnimated = true
            return
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            checkmarkAnimated = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            contentAnimated = true
        }
    }

    // MARK: - Helpers

    /// Maps interest ID to display name
    private func interestDisplayName(_ id: String) -> String {
        let predefinedNames: [String: String] = [
            "ia-generative": "IA Générative",
            "data-science": "Data Science",
            "automation": "Automatisation",
            "development": "Développement",
            "business": "Business"
        ]

        return predefinedNames[id] ?? id.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Previews

#Preview("Complete View") {
    OnboardingCompleteView {
        print("Finish tapped")
    }
}

#Preview("Complete View - With Interests") {
    // Simulate some selected interests
    let _ = {
        OnboardingService.shared.selectedInterests = ["ia-generative", "data-science", "business"]
    }()

    return OnboardingCompleteView {
        print("Finish tapped")
    }
}
