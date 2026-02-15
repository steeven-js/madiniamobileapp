//
//  OnboardingOfflineView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-15.
//

import SwiftUI

/// Fourth screen of the onboarding flow.
/// Presents the offline content features to the user.
struct OnboardingOfflineView: View {
    /// Callback when user taps continue
    let onContinue: () -> Void

    /// Animation state for icon
    @State private var iconAnimated = false

    /// Reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration section
            illustrationSection

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
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    iconAnimated = true
                }
            } else {
                iconAnimated = true
            }
        }
    }

    // MARK: - Illustration Section

    private var illustrationSection: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(MadiniaColors.accent.opacity(0.1))
                .frame(width: 160, height: 160)

            // Offline icon
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(MadiniaColors.accent)
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(iconAnimated ? 1.0 : 0.5)
                .opacity(iconAnimated ? 1.0 : 0.0)
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            Text("Apprenez partout")
                .font(MadiniaTypography.largeTitle)
                .foregroundStyle(MadiniaColors.darkGray)
                .multilineTextAlignment(.center)

            Text("Téléchargez vos formations pour y accéder même sans connexion internet.")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.md)

            // Benefits list
            VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                benefitRow(icon: "arrow.down.app.fill", text: "Téléchargez vos formations favorites")
                benefitRow(icon: "wifi.slash", text: "Accédez au contenu sans connexion")
                benefitRow(icon: "arrow.triangle.2.circlepath", text: "Synchronisation automatique")
            }
            .padding(.top, MadiniaSpacing.md)
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(MadiniaColors.accent)
                .frame(width: 24)

            Text(text)
                .font(MadiniaTypography.subheadline)
                .foregroundStyle(MadiniaColors.darkGray)
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Continue button
            Button {
                onContinue()
            } label: {
                HStack(spacing: MadiniaSpacing.xs) {
                    Text("Continuer")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(MadiniaColors.darkGrayFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MadiniaSpacing.md)
                .background(MadiniaColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }

            // Progress dots
            ProgressDots(currentStep: 3, totalSteps: 5)
                .padding(.bottom, MadiniaSpacing.md)
        }
    }
}

// MARK: - Previews

#Preview("Offline View") {
    OnboardingOfflineView {
        print("Continue tapped")
    }
}
