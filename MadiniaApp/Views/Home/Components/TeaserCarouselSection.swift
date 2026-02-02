//
//  TeaserCarouselSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// Teaser item data for the carousel
struct TeaserItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let gradient: LinearGradient
    /// Whether this item is tappable (has content available)
    var isAvailable: Bool = false
}

/// Large App Store-style teaser card
struct TeaserCard: View {
    let item: TeaserItem

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            // Top section with icon and category
            HStack {
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.9))

                Text(item.subtitle.uppercased())
                    .font(MadiniaTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(1)

                Spacer()
            }

            Spacer()

            // Bottom section with title and description
            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                Text(item.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text(item.description)
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
        }
        .padding(MadiniaSpacing.lg)
        .frame(width: 320, height: 200)
        .background(item.gradient)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.xl))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

/// Article card in teaser style for the carousel
struct ArticleTeaserCard: View {
    let article: Article

    /// Gradient based on article category
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [MadiniaColors.accent, MadiniaColors.violetFixed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image or gradient
            if let coverUrl = article.coverUrl, let url = URL(string: coverUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    gradient
                }
                .frame(width: 320, height: 200)
                .clipped()
                .overlay {
                    // Dark gradient overlay for text readability
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            } else {
                gradient
            }

            // Content overlay
            VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                // Top section with category and reading time in pills
                HStack {
                    // Category pill
                    HStack(spacing: MadiniaSpacing.xxs) {
                        Image(systemName: "newspaper.fill")
                            .font(.caption)
                            .foregroundStyle(.white)

                        Text((article.category ?? "Article").uppercased())
                            .font(MadiniaTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .tracking(0.5)
                    }
                    .padding(.horizontal, MadiniaSpacing.sm)
                    .padding(.vertical, MadiniaSpacing.xxs)
                    .background(.black.opacity(0.5))
                    .clipShape(Capsule())

                    Spacer()

                    // Reading time pill
                    if let readingTime = article.readingTime {
                        Text(readingTime)
                            .font(MadiniaTypography.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, MadiniaSpacing.sm)
                            .padding(.vertical, MadiniaSpacing.xxs)
                            .background(.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                // Bottom section with title and description in pill
                VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                    Text(article.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if let description = article.description {
                        Text(description)
                            .font(MadiniaTypography.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }
                .padding(MadiniaSpacing.sm)
                .background(.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }
            .padding(MadiniaSpacing.md)
        }
        .frame(width: 320, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.xl))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

/// Horizontal carousel section for teaser content
struct TeaserCarouselSection: View {
    let title: String
    let items: [TeaserItem]
    var articles: [Article] = []
    var onTap: (() -> Void)? = nil
    var onItemTap: (() -> Void)? = nil
    var onArticleTap: ((Article) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Section header
            HStack {
                Text(title)
                    .font(MadiniaTypography.title2)
                    .foregroundStyle(.primary)

                Spacer()

                if let onTap = onTap {
                    Button(action: onTap) {
                        Text("Voir tout")
                            .font(MadiniaTypography.subheadline)
                            .foregroundStyle(MadiniaColors.accent)
                    }
                }
            }

            // Horizontal carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.md) {
                    // Real articles first (from API)
                    ForEach(articles) { article in
                        ArticleTeaserCard(article: article)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onArticleTap?(article)
                            }
                    }

                    // Then teaser placeholder items
                    ForEach(items) { item in
                        if let onItemTap = onItemTap {
                            TeaserCard(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onItemTap()
                                }
                        } else {
                            TeaserCard(item: item)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Predefined Teaser Items

extension TeaserItem {
    /// News teaser items - first one redirects to Blog
    static let newsItems: [TeaserItem] = [
        TeaserItem(
            title: "Actualités IA",
            subtitle: "Blog",
            description: "Suivez les dernières tendances et innovations en Intelligence Artificielle.",
            icon: "newspaper.fill",
            gradient: LinearGradient(
                colors: [Color(red: 0.2, green: 0.4, blue: 0.8), Color(red: 0.4, green: 0.2, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            isAvailable: true
        ),
        TeaserItem(
            title: "Conseils d'experts",
            subtitle: "Bientôt disponible",
            description: "Des articles rédigés par nos formateurs pour vous accompagner.",
            icon: "lightbulb.fill",
            gradient: LinearGradient(
                colors: [Color(red: 0.8, green: 0.3, blue: 0.3), Color(red: 0.6, green: 0.2, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            isAvailable: false
        )
    ]

    /// News placeholder items (shown after real articles)
    static let newsPlaceholders: [TeaserItem] = [
        TeaserItem(
            title: "Conseils d'experts",
            subtitle: "Bientôt disponible",
            description: "Des articles rédigés par nos formateurs pour vous accompagner.",
            icon: "lightbulb.fill",
            gradient: LinearGradient(
                colors: [Color(red: 0.8, green: 0.3, blue: 0.3), Color(red: 0.6, green: 0.2, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            isAvailable: false
        )
    ]

    /// Events teaser items
    static let eventsItems: [TeaserItem] = [
        TeaserItem(
            title: "Webinaires IA",
            subtitle: "Bientôt disponible",
            description: "Participez à nos sessions en direct avec des experts du domaine.",
            icon: "video.fill",
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.5), Color(red: 0.2, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ),
        TeaserItem(
            title: "Ateliers pratiques",
            subtitle: "En préparation",
            description: "Des sessions hands-on pour mettre en pratique vos connaissances.",
            icon: "hammer.fill",
            gradient: LinearGradient(
                colors: [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 0.8, green: 0.3, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ),
        TeaserItem(
            title: "Meetups Madin.IA",
            subtitle: "À venir",
            description: "Rencontrez la communauté Madin.IA lors de nos événements.",
            icon: "person.3.fill",
            gradient: LinearGradient(
                colors: [MadiniaColors.violetFixed, MadiniaColors.accent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    ]
}

// MARK: - Previews

#Preview("News Teaser") {
    ScrollView {
        TeaserCarouselSection(
            title: "Actualités",
            items: TeaserItem.newsItems
        )
        .padding()
    }
}

#Preview("Events Teaser") {
    ScrollView {
        TeaserCarouselSection(
            title: "Événements",
            items: TeaserItem.eventsItems
        )
        .padding()
    }
}

#Preview("Dark Mode") {
    ScrollView {
        VStack(spacing: 24) {
            TeaserCarouselSection(
                title: "Actualités",
                items: TeaserItem.newsItems
            )
            TeaserCarouselSection(
                title: "Événements",
                items: TeaserItem.eventsItems
            )
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
