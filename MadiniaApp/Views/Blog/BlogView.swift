//
//  BlogView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Main view for the Blog tab displaying a feed of articles.
struct BlogView: View {
    /// ViewModel managing articles data and loading state
    @State private var viewModel = BlogViewModel()

    var body: some View {
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

    // MARK: - Content View

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingView(message: "Chargement des articles...")

        case .loaded:
            articlesList

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
                ForEach(viewModel.articles) { article in
                    NavigationLink(value: article) {
                        ArticleCard(article: article)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
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

#Preview("Loading") {
    NavigationStack {
        LoadingView(message: "Chargement des articles...")
            .navigationTitle("Blog")
    }
}
