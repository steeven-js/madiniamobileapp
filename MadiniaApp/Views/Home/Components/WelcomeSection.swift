//
//  WelcomeSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI
import UIKit

/// Welcome section displayed at the top of the Home screen.
/// Shows Madinia branding with gradient logo, welcome message and tagline.
struct WelcomeSection: View {
    var body: some View {
        VStack(spacing: MadiniaSpacing.xs) {
            // Logo - try custom asset first, fallback to gradient placeholder
            logoView

            // Welcome message
            Text("Bienvenue chez Madin.IA")
                .font(MadiniaTypography.title)
                .fontWeight(.bold)
                .foregroundStyle(MadiniaColors.darkGray)
                .multilineTextAlignment(.center)

            // Tagline
            Text("Formations IA pour transformer votre métier")
                .font(MadiniaTypography.body)
                .foregroundStyle(MadiniaColors.violet)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, MadiniaSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Bienvenue chez Madin.IA. Formations IA pour transformer votre métier.")
    }

    @ViewBuilder
    private var logoView: some View {
        // Try to load custom logo asset
        if let _ = UIImage(named: "madinia-logo") {
            Image("madinia-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)
        } else {
            // Gradient placeholder with icon
            ZStack {
                Circle()
                    .fill(MadiniaColors.brandGradient)
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    WelcomeSection()
        .padding()
}

#Preview("Dark Mode") {
    WelcomeSection()
        .padding()
        .preferredColorScheme(.dark)
}
