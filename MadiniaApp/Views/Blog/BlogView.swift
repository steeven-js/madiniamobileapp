//
//  BlogView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Main view for the Blog tab displaying a feed of articles.
/// Can be used standalone (with its own NavigationStack) or embedded in another NavigationStack.
struct BlogView: View {
    /// ViewModel managing articles data and loading state
    @State private var viewModel = BlogViewModel()

    /// Whether to show within its own NavigationStack (false when embedded in MadiniaHubView)
    var embedded: Bool = false

    /// Deep link article slug binding (optional)
    @Binding var deepLinkArticleSlug: String?

    /// Article fetched from deep link for navigation
    @State private var deepLinkArticle: Article?

    /// API service for fetching article details
    private let apiService: APIServiceProtocol = APIService.shared

    init(embedded: Bool = false, deepLinkArticleSlug: Binding<String?> = .constant(nil)) {
        self.embedded = embedded
        self._deepLinkArticleSlug = deepLinkArticleSlug
    }

    var body: some View {
        if embedded {
            content
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
                .navigationDestination(item: $deepLinkArticle) { article in
                    ArticleDetailView(article: article)
                }
                .task {
                    await viewModel.loadArticles()
                }
                .onChange(of: deepLinkArticleSlug) { _, newSlug in
                    guard let slug = newSlug else { return }
                    Task {
                        await navigateToArticle(slug: slug)
                    }
                }
                .task(id: deepLinkArticleSlug) {
                    guard let slug = deepLinkArticleSlug else { return }
                    await navigateToArticle(slug: slug)
                }
        } else {
            NavigationStack {
                content
                    .navigationTitle("Blog")
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
            }
            .task {
                await viewModel.loadArticles()
            }
        }
    }

    /// Navigate to an article by fetching it from the API
    @MainActor
    private func navigateToArticle(slug: String) async {
        // Wait for articles to load if needed
        if case .idle = viewModel.loadingState {
            await viewModel.loadArticles()
        } else if case .loading = viewModel.loadingState {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }

        // Try to find in already loaded articles first
        if let article = viewModel.articles.first(where: { $0.slug == slug }) {
            deepLinkArticle = article
            deepLinkArticleSlug = nil
            return
        }

        // Fallback: fetch from API
        do {
            let article = try await apiService.fetchArticle(slug: slug)
            deepLinkArticle = article
        } catch {
            #if DEBUG
            print("Failed to fetch article for deep link: \(error)")
            #endif
        }
        deepLinkArticleSlug = nil
    }

    // MARK: - Content View

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            ScrollView {
                ArticleListSkeleton(count: 4)
                    .padding(.vertical, MadiniaSpacing.md)
            }

        case .loaded:
            if viewModel.articles.isEmpty {
                emptyState
            } else {
                articlesList
            }

        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.loadArticles() }
            }
        }
    }

    // MARK: - Articles List

    private var articlesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                    NavigationLink(value: article) {
                        ArticleCard(article: article)
                            .staggeredAppearance(index: index, baseDelay: 0.05)
                    }
                    .buttonStyle(.plain)
                    .pressScale(0.98)
                }
            }
            .padding()
            .tabBarSafeArea()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                ContentUnavailableView {
                    Label("Aucun article", systemImage: "doc.text")
                } description: {
                    Text("Les articles de blog arrivent bientôt !\n\nRetrouvez ici nos conseils, tutoriels et actualités sur l'Intelligence Artificielle.")
                }
                .padding(.top, MadiniaSpacing.xl)
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Previews

#Preview {
    BlogView()
}

#Preview("Embedded") {
    NavigationStack {
        BlogView(embedded: true)
            .navigationTitle("Blog")
    }
}

#Preview("Loading") {
    NavigationStack {
        LoadingView(message: "Chargement des articles...")
            .navigationTitle("Blog")
    }
}
