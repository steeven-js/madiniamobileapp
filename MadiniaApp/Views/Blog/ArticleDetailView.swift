//
//  ArticleDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Detail view for reading a full article.
struct ArticleDetailView: View {
    /// The article to display
    let article: Article

    /// Navigation context for contact form pre-fill
    @Environment(\.navigationContext) private var navigationContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero image
                heroImage

                // Article header
                articleHeader

                Divider()

                // Article content
                articleContent

                // Related formation CTA (Story 4.5)
                // TODO: Add when formations are linked to articles
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .onAppear {
            navigationContext.setArticle(article)
        }
    }

    // MARK: - Hero Image

    @ViewBuilder
    private var heroImage: some View {
        if let heroUrl = article.heroUrl ?? article.coverUrl,
           let url = URL(string: heroUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                case .failure:
                    EmptyView()
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Article Header

    private var articleHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category
            if let category = article.category {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.accentColor)
            }

            // Title
            Text(article.title)
                .font(.title)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            // Meta info
            HStack(spacing: 16) {
                // Author
                if let author = article.author {
                    Label(author.name, systemImage: "person.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Reading time
                if let readingTime = article.readingTime {
                    Label(readingTime, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Tags
            if let tags = article.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Article Content

    private var articleContent: some View {
        Group {
            if let content = article.content {
                // Content from API (HTML)
                Text(stripHTML(content))
                    .font(.body)
                    .lineSpacing(6)
            } else if let description = article.description {
                // Fallback to description
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("Chargez l'article complet pour voir le contenu.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top)
            }
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        ShareLink(
            item: shareURL,
            subject: Text(article.title),
            message: Text("Découvrez cet article: \(article.title)")
        ) {
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Partager cet article")
    }

    // MARK: - Computed Properties

    private var shareURL: URL {
        URL(string: "https://madinia.fr/blog/\(article.slug)") ??
        URL(string: "https://madinia.fr")!
    }

    // MARK: - Helpers

    /// Strips HTML tags from content for display
    private func stripHTML(_ html: String) -> String {
        var result = html

        // Remove common HTML tags
        let patterns = ["<[^>]+>", "&nbsp;", "&amp;", "&lt;", "&gt;", "&quot;"]
        let replacements = ["", " ", "&", "<", ">", "\""]

        for (pattern, replacement) in zip(patterns, replacements) {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        // Clean up multiple spaces and newlines
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Previews

#Preview("Article Detail") {
    NavigationStack {
        ArticleDetailView(article: Article(
            id: 1,
            title: "Comment l'IA transforme le monde du travail",
            slug: "ia-transforme-travail",
            description: "Découvrez comment l'intelligence artificielle révolutionne nos méthodes de travail.",
            category: "Intelligence Artificielle",
            categorySlug: "ia",
            readingTime: "5 min",
            tags: ["IA", "Travail", "Innovation"],
            author: ArticleAuthor(name: "Sophie Martin", avatarUrl: nil, role: "Auteur", bio: nil),
            coverUrl: nil,
            publishedAt: "2026-01-20T10:00:00+00:00",
            content: "<p>L'intelligence artificielle est en train de transformer profondément notre façon de travailler. Des tâches autrefois réservées aux humains sont maintenant automatisées, libérant du temps pour des activités à plus forte valeur ajoutée.</p><h2>Les principaux changements</h2><p>On observe plusieurs évolutions majeures dans le monde professionnel...</p>",
            heroUrl: nil
        ))
    }
}
