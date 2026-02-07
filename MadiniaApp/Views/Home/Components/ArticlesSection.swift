//
//  ArticlesSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-01.
//

import SwiftUI

/// Section displaying recent articles on the Home screen.
/// Shows horizontal carousel of large article cards.
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
            HStack {
                Text("Actualités")
                    .font(MadiniaTypography.title2)
                    .fontWeight(.bold)

                Spacer()

                if !articles.isEmpty {
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

            // Content
            if articles.isEmpty {
                emptyState
            } else {
                // Horizontal carousel of articles
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MadiniaSpacing.md) {
                        ForEach(articles.prefix(5)) { article in
                            ArticleTeaserCard(article: article)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    HapticManager.tap()
                                    onArticleTap?(article)
                                }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subviews

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
