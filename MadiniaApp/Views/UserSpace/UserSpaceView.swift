//
//  UserSpaceView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// User space view - "L'IA&Vous" section for personalized user experience.
/// This will serve as the user's personal dashboard for their AI learning journey.
struct UserSpaceView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MadiniaSpacing.xl) {
                    // Hero section
                    heroSection

                    // Coming soon features
                    comingSoonSection
                }
                .padding(MadiniaSpacing.md)
                .padding(.bottom, 100) // Space for custom tab bar
            }
            .navigationTitle("L'IA&Vous")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            // User avatar placeholder
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MadiniaColors.gold, MadiniaColors.gold.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
            }

            Text("Votre espace personnel")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)

            Text("Suivez votre progression et personnalisez votre parcours d'apprentissage IA")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.lg)
        }
        .padding(.vertical, MadiniaSpacing.xl)
    }

    // MARK: - Coming Soon Section

    private var comingSoonSection: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Section title
            HStack {
                Text("Bientôt disponible")
                    .font(MadiniaTypography.title2)
                    .foregroundStyle(.primary)
                Spacer()
            }

            // Feature cards
            VStack(spacing: MadiniaSpacing.md) {
                featureCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Suivi de progression",
                    description: "Visualisez votre avancement dans les formations et vos accomplissements."
                )

                featureCard(
                    icon: "bookmark.fill",
                    title: "Formations sauvegardées",
                    description: "Retrouvez facilement les formations que vous avez mises en favoris."
                )

                featureCard(
                    icon: "clock.arrow.circlepath",
                    title: "Historique",
                    description: "Accédez à l'historique de vos formations consultées et complétées."
                )

                featureCard(
                    icon: "sparkles",
                    title: "Recommandations IA",
                    description: "Recevez des suggestions personnalisées basées sur vos centres d'intérêt."
                )

                featureCard(
                    icon: "rosette",
                    title: "Certifications",
                    description: "Consultez et partagez vos certificats de formation obtenus."
                )
            }
        }
    }

    private func featureCard(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: MadiniaSpacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(MadiniaColors.gold)
                .frame(width: 40, height: 40)
                .background(MadiniaColors.gold.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))

            // Content
            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                Text(title)
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Previews

#Preview {
    UserSpaceView()
}

#Preview("Dark Mode") {
    UserSpaceView()
        .preferredColorScheme(.dark)
}
