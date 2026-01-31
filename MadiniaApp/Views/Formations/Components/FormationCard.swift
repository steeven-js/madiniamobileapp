//
//  FormationCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Card component displaying a formation in the grid.
/// Vertical layout with hero image, category badge, title, and metadata.
/// Designed for adaptive grid display - works on iPhone and iPad.
struct FormationCard: View {
    /// The formation to display
    let formation: Formation

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Hero image aspect ratio (width / height)
    private let heroAspectRatio: CGFloat = 170 / 120

    /// Check if formation is favorited
    private var isFavorite: Bool {
        FavoritesService.shared.isFavorite(formationId: formation.id)
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image with category badge overlay
                heroSection

                // Content: title and metadata
                contentSection
            }
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour voir les détails de cette formation")
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            // Image or gradient placeholder
            if let imageUrl = formation.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerPlaceholder()
                }
            } else {
                placeholderGradient
            }

            // Overlays
            VStack {
                HStack {
                    // Category badge overlay (gold pill) - top left
                    if let category = formation.category {
                        Text(category.name)
                            .font(MadiniaTypography.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, MadiniaSpacing.xs)
                            .padding(.vertical, MadiniaSpacing.xxs)
                            .background(MadiniaColors.accent)
                            .foregroundStyle(MadiniaColors.darkGray)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // Favorite button - top right
                    Button {
                        Task {
                            await FavoritesService.shared.toggleFavorite(formationId: formation.id)
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isFavorite ? .red : .white)
                            .padding(6)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .animation(.spring(response: 0.3), value: isFavorite)
                    }
                    .buttonStyle(.plain)
                }
                .padding(MadiniaSpacing.xs)

                Spacer()
            }
        }
        .aspectRatio(heroAspectRatio, contentMode: .fit)
        .clipped()
    }

    private var placeholderGradient: some View {
        MadiniaColors.placeholderGradient
            .overlay {
                Image(systemName: "graduationcap.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.5))
            }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
            // Title (2 lines max)
            Text(formation.title)
                .font(MadiniaTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: MadiniaSpacing.xs)

            // Bottom row: Duration + Level + Certification
            metadataRow
        }
        .padding(MadiniaSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
    }

    private var metadataRow: some View {
        HStack(spacing: MadiniaSpacing.xxs) {
            // Duration
            Label(formation.duration, systemImage: "clock")
                .font(MadiniaTypography.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            // Level indicator (colored dot)
            Circle()
                .fill(levelColor)
                .frame(width: 8, height: 8)

            // Certification badge
            if formation.certification == true {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption2)
                    .foregroundStyle(MadiniaColors.accent)
            }
        }
    }

    // MARK: - Computed Properties

    private var levelColor: Color {
        MadiniaColors.levelColor(for: formation.level)
    }

    private var accessibilityDescription: String {
        var desc = "\(formation.title), niveau \(formation.levelLabel), durée \(formation.duration)"
        if formation.certification == true {
            desc += ", certifiante"
        }
        if let category = formation.category {
            desc += ", catégorie \(category.name)"
        }
        return desc
    }
}

// MARK: - Previews

#Preview("Grid Layout") {
    ScrollView {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: MadiniaSpacing.md)],
            spacing: MadiniaSpacing.md
        ) {
            ForEach(Formation.samples) { formation in
                FormationCard(formation: formation) {
                    print("Tapped: \(formation.title)")
                }
            }
        }
        .padding(MadiniaSpacing.md)
    }
}

#Preview("Single Card") {
    FormationCard(formation: .sample)
        .padding()
}
