//
//  HomeView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Home screen view displaying welcome section, articles, events and most viewed formations.
/// Handles loading, error, and loaded states for formation data.
struct HomeView: View {
    /// ViewModel managing home screen state and data
    @State private var viewModel = HomeViewModel()

    /// Selected tab binding for navigation
    @Binding var selectedTab: Int

    /// Navigation context for triggering blog navigation
    @Environment(\.navigationContext) private var navigationContext

    /// Navigation state for formation detail
    @State private var selectedFormation: Formation?

    /// Navigation state for article detail
    @State private var selectedArticle: Article?

    /// Navigation state for Calendly booking
    @State private var showCalendly = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: MadiniaSpacing.lg) {
                // Welcome section with Madinia branding
                WelcomeSection()

                // Content based on loading state
                switch viewModel.loadingState {
                case .idle, .loading:
                    LoadingView(message: "Chargement des formations...")

                case .loaded:
                    // News carousel - real articles first, then teaser placeholders
                    TeaserCarouselSection(
                        title: "Actualités",
                        items: TeaserItem.newsPlaceholders,
                        articles: viewModel.recentArticles,
                        onTap: {
                            navigationContext.triggerBlogNavigation()
                            selectedTab = 1 // Navigate to Madin.IA tab (Blog)
                        },
                        onItemTap: {
                            navigationContext.triggerBlogNavigation()
                            selectedTab = 1
                        },
                        onArticleTap: { article in
                            selectedArticle = article
                        }
                    )

                    // Events teaser carousel
                    TeaserCarouselSection(
                        title: "Événements",
                        items: TeaserItem.eventsItems,
                        onTap: {
                            navigationContext.triggerEventsNavigation()
                            selectedTab = 1 // Navigate to Madin.IA tab
                        },
                        onItemTap: {
                            navigationContext.triggerEventsNavigation()
                            selectedTab = 1 // Navigate to Madin.IA tab
                        }
                    )

                    // Booking CTA
                    BookingCTACard {
                        showCalendly = true
                    }

                    // Most viewed formations section
                    TopRatedSection(
                        formations: viewModel.mostViewedFormations,
                        onViewAllTap: {
                            // Navigate to search tab to see all formations
                            selectedTab = 1
                        },
                        onFormationTap: { formation in
                            // Navigate to formation detail
                            selectedFormation = formation
                        }
                    )

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.retry() }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .navigationTitle("Accueil")
        .navigationDestination(item: $selectedFormation) { formation in
            FormationDetailView(formation: formation)
        }
        .navigationDestination(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
        }
        .navigationDestination(isPresented: $showCalendly) {
            CalendlyView(embedded: true)
        }
        .task {
            await viewModel.loadFormations()
        }
    }
}

// MARK: - Preview with Mock Data

#Preview {
    NavigationStack {
        HomeView(selectedTab: .constant(0))
    }
}

// MARK: - Preview Helpers (fileprivate to avoid polluting public API)

fileprivate struct HomeView_LoadingPreview: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    WelcomeSection()
                    LoadingView(message: "Chargement des formations...")
                }
                .padding(.horizontal)
            }
            .navigationTitle("Accueil")
        }
    }
}

#Preview("Loading State") {
    HomeView_LoadingPreview()
}

fileprivate struct HomeView_ErrorPreview: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    WelcomeSection()
                    ErrorView(message: "Erreur de connexion. Vérifiez votre connexion internet.") {
                        print("Retry")
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Accueil")
        }
    }
}

#Preview("Error State") {
    HomeView_ErrorPreview()
}
