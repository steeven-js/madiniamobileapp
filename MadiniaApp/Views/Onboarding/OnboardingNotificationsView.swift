//
//  OnboardingNotificationsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI
import UserNotifications

/// Third screen of the onboarding flow.
/// Requests permission for push notifications.
struct OnboardingNotificationsView: View {
    /// Callback when user taps continue (either enable or skip)
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

            // Notification icon
            Image(systemName: "bell.badge.fill")
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
            Text("Restez informé")
                .font(MadiniaTypography.largeTitle)
                .foregroundStyle(MadiniaColors.darkGray)
                .multilineTextAlignment(.center)

            Text("Activez les notifications pour ne manquer aucune nouveauté : nouvelles formations, événements et actualités de l'IA.")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.md)

            // Benefits list
            VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                benefitRow(icon: "graduationcap.fill", text: "Nouvelles formations disponibles")
                benefitRow(icon: "calendar.badge.clock", text: "Rappels d'événements")
                benefitRow(icon: "newspaper.fill", text: "Actualités de l'IA")
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
            // Enable notifications button
            Button {
                requestNotificationPermission()
            } label: {
                HStack(spacing: MadiniaSpacing.xs) {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Activer les notifications")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(MadiniaColors.darkGrayFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MadiniaSpacing.md)
                .background(MadiniaColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }

            // Skip option
            Button {
                onContinue()
            } label: {
                Text("Plus tard")
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress dots
            ProgressDots(currentStep: 2, totalSteps: 4)
                .padding(.bottom, MadiniaSpacing.md)
        }
    }

    // MARK: - Actions

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                onContinue()
            }
        }
    }
}

// MARK: - Previews

#Preview("Notifications View") {
    OnboardingNotificationsView {
        print("Continue tapped")
    }
}
