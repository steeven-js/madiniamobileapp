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

    var body: some View {
        if embedded {
            content
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
                .task {
                    await viewModel.loadArticles()
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
