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
    private let displayLimit = 5

    var body: some View {
        if !recentFormations.isEmpty {
            VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                // Header
                HStack {
                    Text("Reprendre")
                        .font(MadiniaTypography.title2)
                        .fontWeight(.bold)

                    Spacer()

                    if recentFormations.count > displayLimit {
                        Button {
                            onViewAllTap?()
                        } label: {
                            HStack(spacing: MadiniaSpacing.xxs) {
                                Text("Historique")
                                    .font(MadiniaTypography.subheadline)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }

                // Horizontal carousel of recent formations
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MadiniaSpacing.md) {
                        ForEach(Array(recentFormations.prefix(displayLimit))) { formation in
                            FormationTeaserCard(formation: formation)
                                .contentShape(Rectangle())
                                .onTapGesture {
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

// MARK: - Formation Teaser Card

/// Large teaser card for formations (similar to EventTeaserCard)
struct FormationTeaserCard: View {
    let formation: Formation

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image or gradient
            if let imageUrl = formation.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    formationGradient
                }
                .frame(width: 320, height: 200)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            } else {
                formationGradient
                    .overlay {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.3))
                    }
            }

            // Content overlay
            VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                // Top section with category and duration
                HStack {
                    // Category pill
                    if let category = formation.category {
                        HStack(spacing: MadiniaSpacing.xxs) {
                            Image(systemName: "folder.fill")
                                .font(.caption)
                                .foregroundStyle(.white)

                            Text(category.name.uppercased())
                                .font(MadiniaTypography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .tracking(0.5)
                        }
                        .padding(.horizontal, MadiniaSpacing.sm)
                        .padding(.vertical, MadiniaSpacing.xxs)
                        .background(MadiniaColors.accent.opacity(0.8))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    // Duration pill
                    Text(formation.duration)
                        .font(MadiniaTypography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, MadiniaSpacing.sm)
                        .padding(.vertical, MadiniaSpacing.xxs)
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())
                }

                Spacer()

                // Bottom section with title
                VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                    Text(formation.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if let shortDesc = formation.shortDescription {
                        Text(shortDesc)
                            .font(MadiniaTypography.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }
                .padding(MadiniaSpacing.sm)
                .background(.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }
            .padding(MadiniaSpacing.md)
        }
        .frame(width: 320, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.xl))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }

    private var formationGradient: some View {
        LinearGradient(
            colors: [MadiniaColors.accent, MadiniaColors.violetFixed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Previews

#Preview("Continue Learning Section") {
    ScrollView {
        ContinueLearningSection(
            recentFormations: Formation.samples,
            onFormationTap: { print("Tapped: \($0.title)") },
            onViewAllTap: { print("View all") }
        )
        .padding()
    }
}

#Preview("Formation Teaser Card") {
    FormationTeaserCard(formation: .sample)
        .padding()
}
