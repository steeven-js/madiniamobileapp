//
//  FormationRowCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Horizontal row card for formations in vertical list sections.
/// Similar to the "Top Rated" style from Figma (16 Search).
/// Shows thumbnail, title, rating, duration, and favorite button.
struct FormationRowCard: View {
    /// The formation to display
    let formation: Formation

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions
    private let thumbnailSize: CGFloat = 80
    private let cardHeight: CGFloat = 100

    /// Check if formation is favorited
    private var isFavorite: Bool {
        FavoritesService.shared.isFavorite(formationId: formation.id)
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: MadiniaSpacing.sm) {
                // Thumbnail
                thumbnailView

                // Content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    // Title
                    Text(formation.title)
                        .font(MadiniaTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    // Metadata row
                    HStack(spacing: MadiniaSpacing.sm) {
                        // Duration
                        Label(formation.duration, systemImage: "clock")
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        // Level indicator
                        HStack(spacing: MadiniaSpacing.xxs) {
                            Circle()
                                .fill(MadiniaColors.levelColor(for: formation.level))
                                .frame(width: 8, height: 8)

                            Text(formation.levelLabel)
                                .font(MadiniaTypography.caption2)
                                .foregroundStyle(.secondary)
                        }

                        // Certification badge
                        if formation.certification == true {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Favorite button
                Button {
                    Task {
                        await FavoritesService.shared.toggleFavorite(formationId: formation.id)
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(isFavorite ? .red : .secondary.opacity(0.5))
                        .animation(.spring(response: 0.3), value: isFavorite)
                }
                .buttonStyle(.plain)
            }
            .padding(MadiniaSpacing.sm)
            .frame(height: cardHeight)
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour voir les détails de cette formation")
    }

    // MARK: - Thumbnail

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
                placeholderView
            }
        }
        .frame(width: thumbnailSize, height: thumbnailSize)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }

    private var placeholderView: some View {
        MadiniaColors.placeholderGradient
            .overlay {
                Image(systemName: "graduationcap.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.6))
            }
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var desc = "\(formation.title), niveau \(formation.levelLabel), durée \(formation.duration)"
        if formation.certification == true {
            desc += ", certifiante"
        }
        return desc
    }
}

// MARK: - Previews

#Preview("Vertical List") {
    ScrollView {
        VStack(spacing: MadiniaSpacing.sm) {
            ForEach(Formation.samples) { formation in
                FormationRowCard(formation: formation) {
                    print("Tapped: \(formation.title)")
                }
            }
        }
        .padding(MadiniaSpacing.md)
    }
}

#Preview("Single Card") {
    FormationRowCard(formation: .sample)
        .padding()
}
