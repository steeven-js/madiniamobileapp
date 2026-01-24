//
//  FormationCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Card component displaying a formation in the grid.
/// Vertical layout with hero image, category badge, title, and metadata.
/// Designed for 2-column grid display (Nuton-style).
struct FormationCard: View {
    /// The formation to display
    let formation: Formation

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions
    private let cardWidth: CGFloat = 170
    private let cardHeight: CGFloat = 240
    private let heroHeight: CGFloat = 120

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
            .frame(width: cardWidth, height: cardHeight)
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
        ZStack(alignment: .topLeading) {
            // Image or gradient placeholder
            if let imageUrl = formation.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        placeholderGradient
                    @unknown default:
                        placeholderGradient
                    }
                }
            } else {
                placeholderGradient
            }

            // Category badge overlay (gold pill)
            if let category = formation.category {
                Text(category.name)
                    .font(MadiniaTypography.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, MadiniaSpacing.xs)
                    .padding(.vertical, MadiniaSpacing.xxs)
                    .background(MadiniaColors.gold)
                    .foregroundStyle(MadiniaColors.darkGray)
                    .clipShape(Capsule())
                    .padding(MadiniaSpacing.xs)
            }
        }
        .frame(width: cardWidth, height: heroHeight)
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

            Spacer()

            // Bottom row: Duration + Level + Certification
            metadataRow
        }
        .padding(MadiniaSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .foregroundStyle(MadiniaColors.gold)
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
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: MadiniaSpacing.md),
            GridItem(.flexible(), spacing: MadiniaSpacing.md)
        ], spacing: MadiniaSpacing.md) {
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
