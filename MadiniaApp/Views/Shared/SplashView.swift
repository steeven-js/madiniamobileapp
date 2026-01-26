//
//  SplashView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Splash screen displayed during app launch and initial data loading.
/// Uses iOS 17+ best practices with smooth animations and accessibility support.
struct SplashView: View {
    /// Controls logo animation state
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    /// Controls text animation state
    @State private var textOpacity: Double = 0

    /// Controls tagline animation state
    @State private var taglineOpacity: Double = 0

    /// Accessibility: reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Current color scheme for adaptive styling
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background - adaptive to color scheme
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: MadiniaSpacing.lg) {
                Spacer()

                // Logo
                Image("splash-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.xl))
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // Brand name - adaptive to color scheme
                Text("Madin.IA")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .opacity(textOpacity)

                // Tagline
                Text("Former vous à l'IA")
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.secondary)
                    .opacity(taglineOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        let animationDuration = reduceMotion ? 0.1 : 0.6
        let staggerDelay = reduceMotion ? 0.05 : 0.15

        // Logo animation
        withAnimation(.easeOut(duration: animationDuration)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Text animation (staggered)
        withAnimation(.easeOut(duration: animationDuration).delay(staggerDelay)) {
            textOpacity = 1.0
        }

        // Tagline animation (staggered)
        withAnimation(.easeOut(duration: animationDuration).delay(staggerDelay * 2)) {
            taglineOpacity = 1.0
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    SplashView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    SplashView()
        .preferredColorScheme(.dark)
}
