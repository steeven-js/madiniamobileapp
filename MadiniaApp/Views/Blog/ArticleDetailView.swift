//
//  ArticleDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Detail view for reading a full article using the unified detail design.
struct ArticleDetailView: View {
    /// The article to display
    let article: Article

    /// Navigation context for contact form pre-fill
    @Environment(\.navigationContext) private var navigationContext

    var body: some View {
        UnifiedDetailView(config: configuration)
            .onAppear {
                navigationContext.setArticle(article)
            }
    }

    // MARK: - Configuration

    private var configuration: DetailViewConfiguration {
        DetailViewConfiguration(
            title: article.title,
            subtitle: article.description,
            imageUrl: article.heroUrl ?? article.coverUrl,
            duration: article.readingTime,
            description: article.content ?? article.description,
            availableTabs: [.about],
            ctaTitle: "Partager",
            ctaAction: {
                // Share handled via toolbar
            },
            shareUrl: shareURL
        )
    }

    private var shareURL: URL {
        URL(string: "https://madinia.fr/blog/\(article.slug)") ??
        URL(string: "https://madinia.fr")!
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
