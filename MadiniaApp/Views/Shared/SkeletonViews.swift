//
//  SkeletonViews.swift
//  MadiniaApp
//
//  Composants skeleton pour le chargement des listes.
//  Remplace les spinners par des placeholders animés.
//

import SwiftUI

// MARK: - Formation Card Skeleton

/// Skeleton placeholder pour une carte de formation
struct FormationCardSkeleton: View {
    private let heroAspectRatio: CGFloat = 170 / 120

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image skeleton
            ShimmerPlaceholder()
                .aspectRatio(heroAspectRatio, contentMode: .fit)

            // Content skeleton
            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                // Title skeleton (2 lines)
                ShimmerPlaceholder()
                    .frame(height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                ShimmerPlaceholder()
                    .frame(width: 120, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer(minLength: MadiniaSpacing.xs)

                // Metadata row skeleton
                HStack {
                    ShimmerPlaceholder()
                        .frame(width: 60, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Spacer()

                    ShimmerPlaceholder()
                        .frame(width: 8, height: 8)
                        .clipShape(Circle())
                }
            }
            .padding(MadiniaSpacing.sm)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        }
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Formation Grid Skeleton

/// Grille de skeletons pour les formations
struct FormationGridSkeleton: View {
    let count: Int

    init(count: Int = 6) {
        self.count = count
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: MadiniaSpacing.md)],
            spacing: MadiniaSpacing.md
        ) {
            ForEach(0..<count, id: \.self) { _ in
                FormationCardSkeleton()
            }
        }
        .padding(MadiniaSpacing.md)
    }
}

// MARK: - Service Row Skeleton

/// Skeleton placeholder pour une ligne de service
struct ServiceRowSkeleton: View {
    private let thumbnailSize: CGFloat = 70
    private let cardHeight: CGFloat = 100

    var body: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Thumbnail skeleton
            ShimmerPlaceholder()
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))

            // Content skeleton
            VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                // Title
                ShimmerPlaceholder()
                    .frame(width: 140, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // Description
                ShimmerPlaceholder()
                    .frame(height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                ShimmerPlaceholder()
                    .frame(width: 100, height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()

                // Badge skeleton
                ShimmerPlaceholder()
                    .frame(width: 60, height: 20)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Favorite button skeleton
            ShimmerPlaceholder()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }
        .padding(MadiniaSpacing.sm)
        .frame(height: cardHeight)
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Service List Skeleton

/// Liste de skeletons pour les services
struct ServiceListSkeleton: View {
    let count: Int

    init(count: Int = 3) {
        self.count = count
    }

    var body: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            ForEach(0..<count, id: \.self) { _ in
                ServiceRowSkeleton()
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }
}

// MARK: - Article Card Skeleton

/// Skeleton placeholder pour une carte d'article
struct ArticleCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image skeleton
            ShimmerPlaceholder()
                .frame(height: 200)

            // Content skeleton
            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                // Category badge
                ShimmerPlaceholder()
                    .frame(width: 80, height: 20)
                    .clipShape(Capsule())

                // Title (2 lines)
                ShimmerPlaceholder()
                    .frame(height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                ShimmerPlaceholder()
                    .frame(width: 200, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // Metadata
                HStack {
                    ShimmerPlaceholder()
                        .frame(width: 80, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Spacer()

                    ShimmerPlaceholder()
                        .frame(width: 60, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(MadiniaSpacing.md)
        }
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Article List Skeleton

/// Liste de skeletons pour les articles
struct ArticleListSkeleton: View {
    let count: Int

    init(count: Int = 3) {
        self.count = count
    }

    var body: some View {
        VStack(spacing: MadiniaSpacing.md) {
            ForEach(0..<count, id: \.self) { _ in
                ArticleCardSkeleton()
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }
}

// MARK: - Event Card Skeleton

/// Skeleton placeholder pour une carte d'événement
struct EventCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header row
            HStack {
                // Date badge skeleton
                VStack {
                    ShimmerPlaceholder()
                        .frame(width: 30, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    ShimmerPlaceholder()
                        .frame(width: 24, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(width: 50, height: 50)
                .background(MadiniaColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))

                VStack(alignment: .leading, spacing: 4) {
                    ShimmerPlaceholder()
                        .frame(width: 180, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    ShimmerPlaceholder()
                        .frame(width: 120, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Spacer()
            }

            // Description
            ShimmerPlaceholder()
                .frame(height: 12)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            ShimmerPlaceholder()
                .frame(width: 200, height: 12)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            // Tags row
            HStack(spacing: MadiniaSpacing.xs) {
                ForEach(0..<2, id: \.self) { _ in
                    ShimmerPlaceholder()
                        .frame(width: 60, height: 24)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(MadiniaSpacing.md)
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Event List Skeleton

/// Liste de skeletons pour les événements
struct EventListSkeleton: View {
    let count: Int

    init(count: Int = 3) {
        self.count = count
    }

    var body: some View {
        VStack(spacing: MadiniaSpacing.md) {
            ForEach(0..<count, id: \.self) { _ in
                EventCardSkeleton()
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }
}

// MARK: - Detail View Skeleton

/// Skeleton pour une vue détail
struct DetailViewSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                // Hero image
                ShimmerPlaceholder()
                    .frame(height: 250)

                VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                    // Title
                    ShimmerPlaceholder()
                        .frame(height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    ShimmerPlaceholder()
                        .frame(width: 200, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    // Metadata chips
                    HStack(spacing: MadiniaSpacing.sm) {
                        ForEach(0..<3, id: \.self) { _ in
                            ShimmerPlaceholder()
                                .frame(width: 80, height: 28)
                                .clipShape(Capsule())
                        }
                    }

                    // Description paragraphs
                    ForEach(0..<4, id: \.self) { _ in
                        ShimmerPlaceholder()
                            .frame(height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    ShimmerPlaceholder()
                        .frame(width: 250, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }
}

// MARK: - Generic List Skeleton

/// Skeleton générique pour une liste
struct ListSkeleton: View {
    let rowCount: Int
    let rowHeight: CGFloat

    init(rowCount: Int = 5, rowHeight: CGFloat = 60) {
        self.rowCount = rowCount
        self.rowHeight = rowHeight
    }

    var body: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            ForEach(0..<rowCount, id: \.self) { _ in
                HStack(spacing: MadiniaSpacing.sm) {
                    ShimmerPlaceholder()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerPlaceholder()
                            .frame(width: 140, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        ShimmerPlaceholder()
                            .frame(width: 200, height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    Spacer()

                    ShimmerPlaceholder()
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: rowHeight)
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }
}

// MARK: - Previews

#Preview("Formation Card Skeleton") {
    FormationCardSkeleton()
        .frame(width: 180)
        .padding()
}

#Preview("Formation Grid Skeleton") {
    ScrollView {
        FormationGridSkeleton(count: 6)
    }
}

#Preview("Service Row Skeleton") {
    VStack {
        ServiceRowSkeleton()
        ServiceRowSkeleton()
    }
    .padding()
}

#Preview("Article Card Skeleton") {
    ArticleCardSkeleton()
        .padding()
}

#Preview("Event Card Skeleton") {
    EventCardSkeleton()
        .padding()
}

#Preview("Detail View Skeleton") {
    DetailViewSkeleton()
}

#Preview("List Skeleton") {
    ListSkeleton(rowCount: 5)
}
