//
//  HighlightCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Card component displaying a highlighted formation.
/// Full-bleed hero image with gradient overlay and content at bottom.
/// Used in the horizontal scroll view on the Home screen.
struct HighlightCard: View {
    /// The formation to display
    let formation: Formation

    /// Action to perform when the card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions
    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 200

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Full-bleed hero image
                heroImage

                // Gradient overlay for text readability
                MadiniaColors.imageOverlayGradient

                // Content overlay at bottom
                contentOverlay
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour voir les détails de cette formation")
    }

    // MARK: - Subviews

    @ViewBuilder
    private var heroImage: some View {
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
    }

    private var placeholderGradient: some View {
        MadiniaColors.placeholderGradient
            .overlay {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.4))
            }
    }

    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
            // Category chip (gold)
            if let category = formation.category {
                Text(category.name)
                    .font(MadiniaTypography.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, MadiniaSpacing.xs)
                    .padding(.vertical, MadiniaSpacing.xxs)
                    .background(MadiniaColors.accent)
                    .foregroundStyle(MadiniaColors.darkGray)
                    .clipShape(Capsule())
            }

            // Title
            Text(formation.title)
                .font(MadiniaTypography.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Bottom row: Duration + Level
            HStack(spacing: MadiniaSpacing.sm) {
                // Duration
                Label(formation.duration, systemImage: "clock")
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.white.opacity(0.9))

                // Level with colored dot
                HStack(spacing: MadiniaSpacing.xxs) {
                    Circle()
                        .fill(levelColor)
                        .frame(width: 8, height: 8)
                    Text(formation.levelLabel)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                // Certification badge
                if formation.certification == true {
                    HStack(spacing: MadiniaSpacing.xxs) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                        Text("Certifiante")
                            .font(MadiniaTypography.caption)
                    }
                    .foregroundStyle(MadiniaColors.accent)
                }
            }
        }
        .padding(MadiniaSpacing.md)
    }

    // MARK: - Computed Properties

    private var levelColor: Color {
        MadiniaColors.levelColor(for: formation.level)
    }

    private var accessibilityDescription: String {
        var description = "\(formation.title), niveau \(formation.levelLabel), durée \(formation.duration)"
        if formation.certification == true {
            description += ", certifiante"
        }
        if let category = formation.category {
            description += ", catégorie \(category.name)"
        }
        return description
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: MadiniaSpacing.md) {
            ForEach(Formation.samples) { formation in
                HighlightCard(formation: formation)
            }
        }
        .padding(MadiniaSpacing.lg)
    }
}
