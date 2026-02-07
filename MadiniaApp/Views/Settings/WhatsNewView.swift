//
//  WhatsNewView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-30.
//

import SwiftUI

// MARK: - Release Feature Model

/// Represents a new feature in a release
struct ReleaseFeature: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

// MARK: - Release Notes

/// Static release notes for each version
enum ReleaseNotes {
    /// Current version features
    static let version0_1_3: [ReleaseFeature] = [
        ReleaseFeature(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: MadiniaColors.accent,
            title: "Suivi de progression",
            description: "Suivez vos statistiques d'apprentissage : formations consultées, temps passé, catégories explorées et jours consécutifs d'activité."
        ),
        ReleaseFeature(
            icon: "star.circle.fill",
            iconColor: MadiniaColors.goldTier,
            title: "Système de badges",
            description: "Débloquez 9 badges en explorant les formations ! Des badges bronze, argent et or récompensent votre progression."
        ),
        ReleaseFeature(
            icon: "clock.arrow.circlepath",
            iconColor: .blue,
            title: "Historique des formations",
            description: "Retrouvez facilement toutes les formations que vous avez consultées, organisées par date."
        ),
        ReleaseFeature(
            icon: "square.and.arrow.up",
            iconColor: .green,
            title: "Partage de formations",
            description: "Partagez vos formations préférées avec vos collègues et amis grâce au nouveau bouton de partage."
        ),
        ReleaseFeature(
            icon: "chart.bar.fill",
            iconColor: .purple,
            title: "Graphique d'activité",
            description: "Visualisez votre activité de la semaine avec un graphique montrant vos jours les plus actifs."
        )
    ]

    /// Get features for the current version
    static var currentFeatures: [ReleaseFeature] {
        version0_1_3
    }
}

/// View displaying app updates and new features.
/// Shows latest articles from the blog as release notes.
struct WhatsNewView: View {
    /// Whether this is shown as a modal (auto-shown after update) or pushed from settings
    let isModal: Bool

    /// Dismiss action for modal presentation
    @Environment(\.dismiss) private var dismiss

    /// ViewModel for loading articles
    @State private var viewModel = WhatsNewViewModel()

    var body: some View {
        Group {
            if isModal {
                // Modal presentation needs its own NavigationStack
                NavigationStack {
                    contentView
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Fermer") {
                                    WhatsNewService.shared.markAsSeen()
                                    dismiss()
                                }
                                .fontWeight(.semibold)
                            }
                        }
                }
                .onDisappear {
                    WhatsNewService.shared.markAsSeen()
                }
            } else {
                // Pushed from Settings - use parent's NavigationStack
                contentView
            }
        }
        .task {
            await viewModel.loadArticles()
        }
    }

    /// Main content view with navigation
    private var contentView: some View {
        content
            .navigationTitle("Nouveautés")
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        featuresScrollView
    }

    // MARK: - Features Scroll View

    private var featuresScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                // Header
                headerSection

                // Version badge
                versionBadge

                // New features section
                newFeaturesSection

                // Blog articles section (if available)
                if !viewModel.articles.isEmpty {
                    blogArticlesSection
                }

                // Continue button for modal
                if isModal {
                    continueButton
                        .padding(.top, MadiniaSpacing.lg)
                }
            }
            .padding(MadiniaSpacing.md)
            .padding(.bottom, 40)
        }
    }

    // MARK: - New Features Section

    private var newFeaturesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Text("Nouvelles fonctionnalités")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, MadiniaSpacing.sm)

            ForEach(ReleaseNotes.currentFeatures) { feature in
                featureCard(feature)
            }
        }
    }

    private func featureCard(_ feature: ReleaseFeature) -> some View {
        HStack(alignment: .top, spacing: MadiniaSpacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(feature.iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: feature.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(feature.iconColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(feature.description)
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Blog Articles Section

    private var blogArticlesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Text("Articles récents")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, MadiniaSpacing.md)

            ForEach(viewModel.articles) { article in
                NavigationLink {
                    ArticleDetailView(article: article)
                } label: {
                    articleCard(article)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .center, spacing: MadiniaSpacing.md) {
            Image("madinia-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))

            Text("Quoi de neuf ?")
                .font(.system(size: 28, weight: .bold))

            Text("Découvrez les dernières nouveautés de l'application Madin.IA")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.lg)
    }

    // MARK: - Version Badge

    private var versionBadge: some View {
        HStack {
            Image(systemName: "app.badge.checkmark")
                .foregroundStyle(MadiniaColors.accent)

            Text("Version 0.1.3")
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(MadiniaColors.accent.opacity(0.1))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity)
    }

    // MARK: - Article Card

    private func articleCard(_ article: Article) -> some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Cover image
            if let coverUrl = article.coverUrl, let url = URL(string: coverUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
                    case .failure, .empty:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            // Title
            Text(article.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            // Date and reading time
            HStack(spacing: MadiniaSpacing.sm) {
                if let publishedAt = article.publishedAt {
                    Text(formatDate(publishedAt))
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }

                if let readingTime = article.readingTime {
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(readingTime)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Description
            if let description = article.description {
                Text(description)
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            // Tags
            if let tags = article.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MadiniaSpacing.xs) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(MadiniaColors.violet)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(MadiniaColors.violet.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: MadiniaRadius.md)
            .fill(
                LinearGradient(
                    colors: [MadiniaColors.accent.opacity(0.3), MadiniaColors.violet.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 180)
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.8))
            }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            WhatsNewService.shared.markAsSeen()
            dismiss()
        } label: {
            Text("Continuer")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(MadiniaColors.darkGrayFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(MadiniaColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: MadiniaSpacing.lg) {
            Spacer()

            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("Impossible de charger les nouveautés")
                .font(MadiniaTypography.headline)

            Text(message)
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Réessayer") {
                Task { await viewModel.loadArticles() }
            }
            .buttonStyle(.bordered)

            Spacer()

            if isModal {
                continueButton
            }
        }
    }

    // MARK: - Helpers

    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: isoString) else {
                return ""
            }
            return formatDisplayDate(date)
        }

        return formatDisplayDate(date)
    }

    private func formatDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// MARK: - ViewModel

@Observable
final class WhatsNewViewModel {
    /// Centralized data repository (preloaded during splash)
    private let dataRepository: AppDataRepository

    /// Current loading state based on repository
    var loadingState: LoadingState<[Article]> {
        if dataRepository.isLoading && dataRepository.articles.isEmpty {
            return .loading
        } else if let error = dataRepository.errorMessage, dataRepository.articles.isEmpty {
            return .error(error)
        } else {
            return .loaded(dataRepository.recentArticles)
        }
    }

    /// Recent articles (max 3, sorted by publication date)
    var articles: [Article] {
        Array(dataRepository.recentArticles.prefix(3))
    }

    init(dataRepository: AppDataRepository = .shared) {
        self.dataRepository = dataRepository
    }

    @MainActor
    func loadArticles() async {
        // Data is already preloaded by AppDataRepository during splash
        // Only load if needed (fallback)
        await dataRepository.loadArticlesIfNeeded()
    }
}

// MARK: - Previews

#Preview("Modal") {
    WhatsNewView(isModal: true)
}

#Preview("Settings") {
    NavigationStack {
        WhatsNewView(isModal: false)
    }
}
