//
//  BlogViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Blog screen, managing article list and loading state.
@Observable
final class BlogViewModel {
    // MARK: - State

    /// Current loading state for articles data
    private(set) var loadingState: LoadingState<[Article]> = .idle

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties

    /// All loaded articles
    var articles: [Article] {
        loadingState.value ?? []
    }

    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Actions

    /// Loads articles from the API
    @MainActor
    func loadArticles() async {
        guard !loadingState.isLoading else { return }

        loadingState = .loading

        do {
            let articles = try await apiService.fetchArticles()
            loadingState = .loaded(articles)
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Erreur inconnue")
        } catch {
            loadingState = .error("Erreur de chargement")
        }
    }

    /// Refreshes articles from the API
    @MainActor
    func refresh() async {
        if !loadingState.isLoading {
            loadingState = .idle
            await loadArticles()
        }
    }
}
