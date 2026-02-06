//
//  OnboardingWelcomeView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI

/// First screen of the onboarding flow.
/// Displays the app logo, welcome message, and brief description.
struct OnboardingWelcomeView: View {
    /// Callback when user taps continue
    let onContinue: () -> Void

    /// Animation state for logo
    @State private var logoAnimated = false

    /// Reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo section
            logoSection

            Spacer()

            // Content section
            contentSection

            Spacer()

            // Bottom section with button and progress
            bottomSection
        }
        .padding(MadiniaSpacing.lg)
        .background(MadiniaColors.surfaceBackground)
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    logoAnimated = true
                }
            } else {
                logoAnimated = true
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            Image("madinia-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.xl))
                .shadow(color: MadiniaColors.violet.opacity(0.3), radius: 20, x: 0, y: 10)
                .scaleEffect(logoAnimated ? 1.0 : 0.8)
                .opacity(logoAnimated ? 1.0 : 0.0)
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            Text("Bienvenue sur Madin.IA")
                .font(MadiniaTypography.largeTitle)
                .foregroundStyle(MadiniaColors.darkGray)
                .multilineTextAlignment(.center)

            Text("Votre plateforme de formation en Intelligence Artificielle en Martinique")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.lg)
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Continue button
            Button {
                onContinue()
            } label: {
                Text("Commencer")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MadiniaSpacing.md)
                    .background(MadiniaColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }

            // Progress dots
            ProgressDots(currentStep: 0, totalSteps: 4)
                .padding(.bottom, MadiniaSpacing.md)
        }
    }
}

// MARK: - Previews

#Preview("Welcome View") {
    OnboardingWelcomeView {
        print("Continue tapped")
    }
}
