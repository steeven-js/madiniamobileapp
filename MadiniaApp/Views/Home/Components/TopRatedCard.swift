//
//  TopRatedCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Horizontal card for Most Viewed formations section.
/// Displays image with views badge, title, duration, and level.
struct TopRatedCard: View {
    /// The formation to display
    let formation: Formation

    /// Views count (optional, from API)
    var viewsCount: Int?

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions
    private let cardHeight: CGFloat = 90
    private let imageSize: CGFloat = 80

    /// Check if formation is favorited
    private var isFavorite: Bool {
        FavoritesService.shared.isFavorite(formationId: formation.id)
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: MadiniaSpacing.sm) {
                // Image with views badge
                imageWithViewsBadge

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

    private var imageWithViewsBadge: some View {
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

            // Views badge
            if let views = viewsCount ?? formation.viewsCount, views > 0 {
                viewsBadge(count: views)
                    .padding(MadiniaSpacing.xxs)
            }
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

    private func viewsBadge(count: Int) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "eye.fill")
                .font(.system(size: 8))
                .foregroundStyle(.white)

            Text(formatViewsCount(count))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(MadiniaColors.violet.opacity(0.85))
        )
    }

    /// Formats views count for display (e.g., 1234 -> "1.2k")
    private func formatViewsCount(_ count: Int) -> String {
        if count >= 1000 {
            let value = Double(count) / 1000.0
            return String(format: "%.1fk", value)
        }
        return "\(count)"
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

#Preview("Most Viewed Card") {
    VStack(spacing: MadiniaSpacing.sm) {
        TopRatedCard(formation: Formation.sample, viewsCount: 1523)
        TopRatedCard(formation: Formation.samples[1], viewsCount: 892)
        TopRatedCard(formation: Formation.samples[2], viewsCount: 456)
    }
    .padding(MadiniaSpacing.md)
}
