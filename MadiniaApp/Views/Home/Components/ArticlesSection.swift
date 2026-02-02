//
//  ArticlesSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-01.
//

import SwiftUI

/// Section displaying recent articles on the Home screen.
/// Shows vertical list of compact article cards, sorted by publication date (most recent first).
struct ArticlesSection: View {
    /// Articles to display (sorted by publication date)
    let articles: [Article]

    /// Action when "View all" is tapped
    var onViewAllTap: (() -> Void)?

    /// Action when an article is tapped
    var onArticleTap: ((Article) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header row
            headerRow

            // Article cards (max 3 most recent)
            if articles.isEmpty {
                emptyState
            } else {
                VStack(spacing: MadiniaSpacing.sm) {
                    ForEach(articles.prefix(3)) { article in
                        ArticleRowCard(article: article) {
                            onArticleTap?(article)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            Text("Actualités")
                .font(MadiniaTypography.title2)
                .fontWeight(.bold)

            Spacer()

            Button {
                onViewAllTap?()
            } label: {
                HStack(spacing: MadiniaSpacing.xxs) {
                    Text("Voir tout")
                        .font(MadiniaTypography.subheadline)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundStyle(MadiniaColors.accent)
            }
            .accessibilityLabel("Voir tous les articles")
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: MadiniaSpacing.xs) {
                Image(systemName: "newspaper")
                    .font(.title)
                    .foregroundStyle(.tertiary)
                Text("Aucun article pour le moment")
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, MadiniaSpacing.lg)
            Spacer()
        }
    }
}

/// Compact article card for the home screen
struct ArticleRowCard: View {
    /// The article to display
    let article: Article

    /// Action when card is tapped
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: MadiniaSpacing.md) {
                // Thumbnail
                articleThumbnail

                // Content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    // Category
                    if let category = article.category {
                        Text(category)
                            .font(MadiniaTypography.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(MadiniaColors.accent)
                    }

                    // Title
                    Text(article.title)
                        .font(MadiniaTypography.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Meta info
                    HStack(spacing: MadiniaSpacing.xs) {
                        if let readingTime = article.readingTime {
                            Label(readingTime, systemImage: "clock")
                                .font(MadiniaTypography.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let publishedAt = article.publishedAt {
                            Text("•")
                                .foregroundStyle(.tertiary)
                            Text(formattedDate(publishedAt))
                                .font(MadiniaTypography.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer(minLength: 0)

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(MadiniaSpacing.md)
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.title)
        .accessibilityHint("Appuyez pour lire l'article")
    }

    // MARK: - Subviews

    @ViewBuilder
    private var articleThumbnail: some View {
        if let coverUrl = article.coverUrl, let url = URL(string: coverUrl) {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                thumbnailPlaceholder
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        } else {
            thumbnailPlaceholder
        }
    }

    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: MadiniaRadius.md)
            .fill(Color(.tertiarySystemBackground))
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
            }
    }

    // MARK: - Helpers

    private func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: isoString) else {
                return ""
            }
            return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
        }

        return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Previews

#Preview("Articles Section") {
    ScrollView {
        ArticlesSection(
            articles: Article.samples,
            onViewAllTap: { print("View all tapped") },
            onArticleTap: { print("Article tapped: \($0.title)") }
        )
        .padding(.horizontal, MadiniaSpacing.md)
    }
}

#Preview("Empty State") {
    ArticlesSection(articles: [])
        .padding(.horizontal, MadiniaSpacing.md)
}

#Preview("Article Row Card") {
    ArticleRowCard(article: .sample)
        .padding()
}
