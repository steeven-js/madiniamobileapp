//
//  ArticleCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Card component displaying an article in the blog feed.
struct ArticleCard: View {
    /// The article to display
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover image
            if let coverUrl = article.coverUrl, let url = URL(string: coverUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    ShimmerPlaceholder()
                        .aspectRatio(16/9, contentMode: .fit)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                imagePlaceholder
            }

            // Content
            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                // Category and reading time
                HStack(spacing: MadiniaSpacing.xs) {
                    if let category = article.category {
                        Text(category)
                            .font(MadiniaTypography.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(MadiniaColors.accent)
                    }

                    if let readingTime = article.readingTime {
                        Text("• \(readingTime)")
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Title
                Text(article.title)
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                // Description
                if let description = article.description {
                    Text(description)
                        .font(MadiniaTypography.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Author and date
                HStack {
                    if let author = article.author {
                        Text(author.name)
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let publishedAt = article.publishedAt {
                        Text(formattedDate(publishedAt))
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(MadiniaSpacing.md)
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour lire l'article")
    }

    // MARK: - Subviews

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemBackground))
            .aspectRatio(16/9, contentMode: .fit)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

    private var accessibilityDescription: String {
        var parts: [String] = [article.title]
        if let category = article.category {
            parts.append("Catégorie \(category)")
        }
        if let readingTime = article.readingTime {
            parts.append("Temps de lecture \(readingTime)")
        }
        if let author = article.author {
            parts.append("Par \(author.name)")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Previews

#Preview("Article Card") {
    ScrollView {
        ArticleCard(article: .sample)
            .padding()
    }
}

#Preview("Multiple Cards") {
    ScrollView {
        LazyVStack(spacing: 16) {
            ForEach(Article.samples) { article in
                ArticleCard(article: article)
            }
        }
        .padding()
    }
}
