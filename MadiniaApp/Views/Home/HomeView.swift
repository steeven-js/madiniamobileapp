//
//  HomeView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Home screen view displaying welcome section, categories, and most viewed formations.
/// Handles loading, error, and loaded states for formation data.
struct HomeView: View {
    /// ViewModel managing home screen state and data
    @State private var viewModel = HomeViewModel()

    /// Selected tab binding for navigation
    @Binding var selectedTab: Int

    /// Navigation state for categories grid
    @State private var showCategoriesGrid = false

    /// Navigation state for formation detail
    @State private var selectedFormation: Formation?

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
                    // News teaser carousel
                    TeaserCarouselSection(
                        title: "Actualités",
                        items: TeaserItem.newsItems
                    )

                    // Events teaser carousel
                    TeaserCarouselSection(
                        title: "Événements",
                        items: TeaserItem.eventsItems
                    )

                    // Categories section
                    CategoriesSection(
                        categories: viewModel.categories,
                        onViewAllTap: { showCategoriesGrid = true },
                        onCategoryTap: { category in
                            FormationsRepository.shared.setSelectedCategory(category)
                            selectedTab = 1
                        }
                    )

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
            .padding(.bottom, 100) // Space for tab bar
        }
        .navigationTitle("Accueil")
        .navigationDestination(isPresented: $showCategoriesGrid) {
            CategoriesGridView { category in
                // Set category filter and navigate to formations tab
                FormationsRepository.shared.setSelectedCategory(category)
                showCategoriesGrid = false
                selectedTab = 1
            }
        }
        .navigationDestination(item: $selectedFormation) { formation in
            FormationDetailView(formation: formation)
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
