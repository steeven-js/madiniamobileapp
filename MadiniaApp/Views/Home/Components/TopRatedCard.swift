//
//  TopRatedCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Horizontal card for Top Rated formations section.
/// Displays image with rating badge, title, duration, and level.
struct TopRatedCard: View {
    /// The formation to display
    let formation: Formation

    /// Rating value (hardcoded for now, will be dynamic later)
    var rating: Double = 5.0

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions
    private let cardHeight: CGFloat = 90
    private let imageSize: CGFloat = 80

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: MadiniaSpacing.sm) {
                // Image with rating badge
                imageWithRating

                // Content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    // Title
                    Text(formation.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MadiniaColors.darkGray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    // Duration row
                    HStack(spacing: MadiniaSpacing.xxs) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)

                        Text(formation.duration)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)

                        Spacer()

                        // Level badge
                        Text(formation.levelLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(levelColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Favorite button (placeholder for future)
                Button {
                    // TODO: Implement favorites
                } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(MadiniaSpacing.xs)
            .frame(height: cardHeight)
            .background(
                RoundedRectangle(cornerRadius: MadiniaRadius.sm)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(formation.title), \(formation.duration), \(formation.levelLabel)")
    }

    // MARK: - Subviews

    private var imageWithRating: some View {
        ZStack(alignment: .bottomLeading) {
            // Formation image
            if let imageUrl = formation.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        imagePlaceholder
                    case .empty:
                        ProgressView()
                            .frame(width: imageSize, height: imageSize)
                    @unknown default:
                        imagePlaceholder
                    }
                }
                .frame(width: imageSize, height: imageSize)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
            } else {
                imagePlaceholder
            }

            // Rating badge
            ratingBadge
                .padding(MadiniaSpacing.xxs)
        }
        .frame(width: imageSize, height: imageSize)
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: MadiniaRadius.sm)
            .fill(
                LinearGradient(
                    colors: [MadiniaColors.violet.opacity(0.3), MadiniaColors.gold.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: imageSize, height: imageSize)
            .overlay {
                Image(systemName: "book.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.6))
            }
    }

    private var ratingBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 8))
                .foregroundStyle(MadiniaColors.gold)

            Text(String(format: "%.1f", rating))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(MadiniaColors.darkGray.opacity(0.85))
        )
    }

    // MARK: - Computed Properties

    private var levelColor: Color {
        switch formation.level.lowercased() {
        case "debutant", "starter":
            return MadiniaColors.levelStarter
        case "intermediaire", "performer":
            return MadiniaColors.levelPerformer
        case "avance", "master":
            return MadiniaColors.levelMaster
        default:
            return .secondary
        }
    }
}

// MARK: - Preview

#Preview("Top Rated Card") {
    VStack(spacing: MadiniaSpacing.sm) {
        TopRatedCard(formation: Formation.sample)
        TopRatedCard(formation: Formation.samples[1])
        TopRatedCard(formation: Formation.samples[2])
    }
    .padding(MadiniaSpacing.md)
}
