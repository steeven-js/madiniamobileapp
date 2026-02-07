//
//  ContinueLearningSection.swift
//  MadiniaApp
//
//  Section "Reprendre où vous en étiez" affichant les formations récemment consultées.
//

import SwiftUI

/// Section affichant les formations récemment consultées pour permettre de reprendre.
struct ContinueLearningSection: View {
    /// Formations récemment consultées (triées par date de dernière vue)
    let recentFormations: [Formation]

    /// Action lors du tap sur une formation
    var onFormationTap: ((Formation) -> Void)?

    /// Action lors du tap sur "Voir tout"
    var onViewAllTap: (() -> Void)?

    /// Limite d'affichage
    private let displayLimit = 3

    var body: some View {
        if !recentFormations.isEmpty {
            VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                // Header
                HStack {
                    HStack(spacing: MadiniaSpacing.xs) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(MadiniaColors.accent)

                        Text("Reprendre")
                            .font(MadiniaTypography.headline)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    if recentFormations.count > displayLimit {
                        Button {
                            onViewAllTap?()
                        } label: {
                            Text("Historique")
                                .font(MadiniaTypography.caption)
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }

                // Horizontal scroll of recent formations
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MadiniaSpacing.sm) {
                        ForEach(Array(recentFormations.prefix(displayLimit))) { formation in
                            ContinueLearningCard(formation: formation) {
                                HapticManager.tap()
                                onFormationTap?(formation)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Continue Learning Card

/// Carte compacte pour une formation récemment consultée
struct ContinueLearningCard: View {
    let formation: Formation
    var onTap: (() -> Void)?

    private let cardWidth: CGFloat = 260
    private let cardHeight: CGFloat = 80

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: MadiniaSpacing.sm) {
                // Thumbnail
                thumbnailView

                // Content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    Text(formation.title)
                        .font(MadiniaTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: MadiniaSpacing.xs) {
                        // Duration
                        Label(formation.duration, systemImage: "clock")
                            .font(MadiniaTypography.caption2)
                            .foregroundStyle(.secondary)

                        // Category
                        if let category = formation.category {
                            Text(category.name)
                                .font(MadiniaTypography.caption2)
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(MadiniaSpacing.sm)
            .frame(width: cardWidth, height: cardHeight)
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .pressScale(0.98)
    }

    private var thumbnailView: some View {
        Group {
            if let imageUrl = formation.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerPlaceholder()
                }
            } else {
                MadiniaColors.placeholderGradient
                    .overlay {
                        Image(systemName: "graduationcap.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                    }
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }
}

// MARK: - Previews

#Preview("Continue Learning Section") {
    VStack {
        ContinueLearningSection(
            recentFormations: Formation.samples,
            onFormationTap: { print("Tapped: \($0.title)") },
            onViewAllTap: { print("View all") }
        )
    }
    .padding()
}

#Preview("Single Card") {
    ContinueLearningCard(formation: .sample)
        .padding()
}
