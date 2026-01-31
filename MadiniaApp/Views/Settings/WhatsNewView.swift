//
//  WhatsNewView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-30.
//

import SwiftUI

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
        NavigationStack {
            content
                .navigationTitle("Nouveautés")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isModal {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Fermer") {
                                WhatsNewService.shared.markAsSeen()
                                dismiss()
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
        }
        .task {
            await viewModel.loadArticles()
        }
        .onDisappear {
            if isModal {
                WhatsNewService.shared.markAsSeen()
            }
        }
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

                // Articles list
                ForEach(viewModel.articles) { article in
                    articleCard(article)
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
    private(set) var loadingState: LoadingState<[Article]> = .idle
    private let apiService: APIServiceProtocol

    var articles: [Article] {
        loadingState.value ?? []
    }

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    @MainActor
    func loadArticles() async {
        guard !loadingState.isLoading else { return }

        loadingState = .loading

        do {
            let articles = try await apiService.fetchArticles()
            // Show only the most recent articles (e.g., last 3)
            let recentArticles = Array(articles.prefix(3))
            loadingState = .loaded(recentArticles)
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Erreur inconnue")
        } catch {
            loadingState = .error("Erreur de chargement")
        }
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
