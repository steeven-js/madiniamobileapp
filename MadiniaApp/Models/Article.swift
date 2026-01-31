//
//  Article.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Model representing a blog article from the API.
struct Article: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let description: String?
    let category: String?
    let categorySlug: String?
    let readingTime: String?
    let tags: [String]?
    let author: ArticleAuthor?
    let coverUrl: String?
    let publishedAt: String?
    let viewsCount: Int?
    let likesCount: Int?

    // Detail-only fields
    let content: String?
    let heroUrl: String?
    let shortDescription: String?
}

/// Author information for an article
struct ArticleAuthor: Codable, Hashable {
    let name: String
    let avatarUrl: String?
    let role: String?
    let bio: String?
}

// MARK: - Sample Data

extension Article {
    /// Sample article for previews
    static let sample = Article(
        id: 1,
        title: "Comment l'IA transforme le monde du travail",
        slug: "ia-transforme-travail",
        description: "Découvrez comment l'intelligence artificielle révolutionne nos méthodes de travail et les compétences essentielles pour rester compétitif.",
        category: "Intelligence Artificielle",
        categorySlug: "ia",
        readingTime: "5 min",
        tags: ["IA", "Travail", "Innovation"],
        author: ArticleAuthor(
            name: "Sophie Martin",
            avatarUrl: nil,
            role: "Auteur",
            bio: "Experte en IA et formation professionnelle"
        ),
        coverUrl: nil,
        publishedAt: "2026-01-20T10:00:00+00:00",
        viewsCount: 156,
        likesCount: 42,
        content: nil,
        heroUrl: nil,
        shortDescription: nil
    )

    /// Sample articles for previews
    static let samples: [Article] = [
        sample,
        Article(
            id: 2,
            title: "Les meilleures pratiques de prompt engineering",
            slug: "prompt-engineering",
            description: "Maîtrisez l'art de communiquer avec les IA génératives grâce à ces techniques de prompt engineering.",
            category: "IA Générative",
            categorySlug: "ia-generative",
            readingTime: "8 min",
            tags: ["ChatGPT", "Prompts", "IA"],
            author: ArticleAuthor(name: "Marc Dupont", avatarUrl: nil, role: nil, bio: nil),
            coverUrl: nil,
            publishedAt: "2026-01-18T14:30:00+00:00",
            viewsCount: 234,
            likesCount: 67,
            content: nil,
            heroUrl: nil,
            shortDescription: nil
        ),
        Article(
            id: 3,
            title: "Formation continue : pourquoi c'est essentiel",
            slug: "formation-continue-essentielle",
            description: "Dans un monde en constante évolution, la formation continue n'est plus une option mais une nécessité.",
            category: "Développement Personnel",
            categorySlug: "dev-perso",
            readingTime: "4 min",
            tags: ["Formation", "Carrière"],
            author: ArticleAuthor(name: "Julie Lemaire", avatarUrl: nil, role: nil, bio: nil),
            coverUrl: nil,
            publishedAt: "2026-01-15T09:00:00+00:00",
            viewsCount: 89,
            likesCount: 23,
            content: nil,
            heroUrl: nil,
            shortDescription: nil
        )
    ]
}
