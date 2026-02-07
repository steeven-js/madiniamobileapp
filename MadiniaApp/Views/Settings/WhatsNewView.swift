//
//  WhatsNewView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-30.
//

import SwiftUI

/// Represents a feature for a specific app version
private struct VersionFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
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
        switch viewModel.loadingState {
        case .idle, .loading:
            loadingView

        case .loaded:
            if viewModel.articles.isEmpty {
                emptyView
            } else {
                articlesScrollView
            }

        case .error(let message):
            errorView(message: message)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Chargement des nouveautés...")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(MadiniaColors.accent)

            Text("Bienvenue sur Madin.IA !")
                .font(.system(size: 24, weight: .bold))

            Text("Merci d'avoir installé notre application.\nDécouvrez nos formations en Intelligence Artificielle.")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.xl)

            Spacer()

            if isModal {
                continueButton
            }
        }
    }

    // MARK: - Articles Scroll View

    private var articlesScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                // Header
                headerSection

                // Version badge
                versionBadge

                // Version-specific features
                versionFeaturesSection

                // Previous versions
                previousVersionsSection

                // Blog articles header
                if !viewModel.articles.isEmpty {
                    Text("Actualités du blog")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, MadiniaSpacing.sm)
                }

                // Articles list
                ForEach(viewModel.articles) { article in
                    NavigationLink {
                        ArticleDetailView(article: article)
                    } label: {
                        articleCard(article)
                    }
                    .buttonStyle(.plain)
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

            Text("Version \(WhatsNewService.shared.currentVersion)")
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(MadiniaColors.accent.opacity(0.1))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity)
    }

    // MARK: - Version Features Section

    private var versionFeaturesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Text("Nouveautés de cette version")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, MadiniaSpacing.sm)

            ForEach(currentVersionFeatures, id: \.title) { feature in
                featureRow(feature)
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
    }

    private func featureRow(_ feature: VersionFeature) -> some View {
        HStack(alignment: .top, spacing: MadiniaSpacing.md) {
            Image(systemName: feature.icon)
                .font(.system(size: 24))
                .foregroundStyle(feature.color)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(feature.description)
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, MadiniaSpacing.xs)
    }

    // MARK: - Version Features Data

    private var currentVersionFeatures: [VersionFeature] {
        // Features for version 0.1.3
        [
            VersionFeature(
                icon: "arrow.down.circle.fill",
                title: "Mode hors-ligne",
                description: "Téléchargez vos formations favorites pour les consulter sans connexion internet.",
                color: MadiniaColors.violet
            ),
            VersionFeature(
                icon: "wifi.slash",
                title: "Indicateur de connexion",
                description: "Une bannière vous informe quand vous êtes hors-ligne et affiche les opérations en attente.",
                color: .orange
            ),
            VersionFeature(
                icon: "arrow.triangle.2.circlepath",
                title: "Synchronisation intelligente",
                description: "Vos actions (favoris, inscriptions) sont automatiquement synchronisées au retour en ligne.",
                color: .green
            )
        ]
    }

    // MARK: - Previous Versions Section

    private var previousVersionsSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Text("Versions précédentes")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, MadiniaSpacing.sm)

            // Version 0.1.2
            version012Section

            // Version 0.1.1
            version011Section
        }
    }

    private var version012Section: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            HStack {
                Text("Version 0.1.2")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, MadiniaSpacing.xxs)

            ForEach(version012Features, id: \.title) { feature in
                featureRowCompact(feature)
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
    }

    private var version011Section: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            HStack {
                Text("Version 0.1.1")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, MadiniaSpacing.xxs)

            ForEach(version011Features, id: \.title) { feature in
                featureRowCompact(feature)
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
    }

    private func featureRowCompact(_ feature: VersionFeature) -> some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: feature.icon)
                .font(.system(size: 16))
                .foregroundStyle(feature.color)
                .frame(width: 24)

            Text(feature.title)
                .font(.system(size: 14))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private var version012Features: [VersionFeature] {
        [
            VersionFeature(
                icon: "hand.wave.fill",
                title: "Onboarding interactif",
                description: "Personnalisez vos centres d'intérêt au premier lancement",
                color: MadiniaColors.accent
            ),
            VersionFeature(
                icon: "sparkles",
                title: "Écran Nouveautés",
                description: "Découvrez les mises à jour après chaque installation",
                color: MadiniaColors.violet
            ),
            VersionFeature(
                icon: "bell.badge.fill",
                title: "Notifications push",
                description: "Recevez des alertes pour les nouvelles formations",
                color: .red
            ),
            VersionFeature(
                icon: "gearshape.fill",
                title: "Paramètres avancés",
                description: "Thème, notifications et préférences",
                color: .gray
            )
        ]
    }

    private var version011Features: [VersionFeature] {
        [
            VersionFeature(
                icon: "brain.head.profile",
                title: "Coach Madi IA",
                description: "Assistant intelligent pour vous guider",
                color: MadiniaColors.accent
            ),
            VersionFeature(
                icon: "heart.fill",
                title: "Favoris",
                description: "Sauvegardez vos formations préférées",
                color: .pink
            ),
            VersionFeature(
                icon: "calendar",
                title: "Événements",
                description: "Consultez les événements à venir",
                color: .blue
            ),
            VersionFeature(
                icon: "magnifyingglass",
                title: "Recherche",
                description: "Trouvez rapidement des formations",
                color: .green
            )
        ]
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
