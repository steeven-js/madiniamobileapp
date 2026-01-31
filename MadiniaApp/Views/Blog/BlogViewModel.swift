//
//  BlogViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// ViewModel for the Blog screen, managing article list and loading state.
/// Uses AppDataRepository as data source (preloaded during splash).
@Observable
final class BlogViewModel {
    // MARK: - Dependencies

    /// Centralized data repository (preloaded during splash)
    private let dataRepository: AppDataRepository

    // MARK: - Computed Properties

    /// Current loading state for articles data
    var loadingState: LoadingState<[Article]> {
        if dataRepository.isLoading && dataRepository.articles.isEmpty {
            return .loading
        } else if let error = dataRepository.errorMessage, dataRepository.articles.isEmpty {
            return .error(error)
        } else {
            return .loaded(dataRepository.articles)
        }
    }

    /// All loaded articles
    var articles: [Article] {
        dataRepository.articles
    }

    // MARK: - Initialization

    init(dataRepository: AppDataRepository = .shared) {
        self.dataRepository = dataRepository
    }

    // MARK: - Actions

    /// Loads articles - data is already preloaded by AppDataRepository
    @MainActor
    func loadArticles() async {
        // Data is already preloaded by AppDataRepository during splash
        // Nothing to do here
    }

    /// Refreshes articles from the API (for pull-to-refresh)
    @MainActor
    func refresh() async {
        await dataRepository.refresh()
    }
}
