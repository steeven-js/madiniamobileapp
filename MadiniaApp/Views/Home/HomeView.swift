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

    /// Navigation state for event detail
    @State private var selectedEvent: Event?

    /// Sheet de personnalisation
    @State private var showCustomization = false

    /// Navigation vers l'historique
    @State private var showHistory = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: MadiniaSpacing.lg) {
                // Welcome section with Madinia branding
                WelcomeSection()

                // Customization button
                HStack {
                    Spacer()
                    Button {
                        HapticManager.tap()
                        showCustomization = true
                    } label: {
                        HStack(spacing: MadiniaSpacing.xxs) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 12, weight: .medium))
                            Text("Personnaliser")
                                .font(MadiniaTypography.caption)
                        }
                        .foregroundStyle(MadiniaColors.accent)
                        .padding(.horizontal, MadiniaSpacing.sm)
                        .padding(.vertical, MadiniaSpacing.xxs)
                        .background(MadiniaColors.accent.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }

                // Content based on loading state
                switch viewModel.loadingState {
                case .idle, .loading:
                    LoadingView(message: "Chargement des formations...")

                case .loaded:
                    // Afficher les sections selon les préférences utilisateur
                    ForEach(viewModel.visibleSections) { section in
                        sectionView(for: section)
                    }

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
        .refreshable {
            await viewModel.retry()
        }
        .navigationTitle("Accueil")
        .sheet(isPresented: $showCustomization) {
            HomeCustomizationSheet()
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView()
        }
        .navigationDestination(item: $selectedFormation) { formation in
            FormationDetailView(formation: formation)
        }
        .navigationDestination(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
        }
        .navigationDestination(isPresented: $showCalendly) {
            CalendlyView(embedded: true)
        }
        .navigationDestination(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .task {
            await viewModel.loadFormations()
        }
    }
}

// MARK: - Section Views

extension HomeView {
    /// Returns the appropriate view for each home section
    @ViewBuilder
    private func sectionView(for section: HomeSection) -> some View {
        switch section {
        case .continuelearning:
            if !viewModel.recentlyViewedFormations.isEmpty {
                ContinueLearningSection(
                    recentFormations: viewModel.recentlyViewedFormations,
                    onFormationTap: { formation in
                        HapticManager.tap()
                        selectedFormation = formation
                    },
                    onViewAllTap: {
                        HapticManager.tap()
                        showHistory = true
                    }
                )
            }

        case .news:
            ArticlesSection(
                articles: viewModel.recentArticles,
                onViewAllTap: {
                    HapticManager.tap()
                    navigationContext.triggerBlogNavigation()
                    selectedTab = 1 // Madin.IA tab
                },
                onArticleTap: { article in
                    HapticManager.tap()
                    selectedArticle = article
                }
            )

        case .events:
            EventsSection(
                events: viewModel.upcomingEvents,
                onViewAllTap: {
                    HapticManager.tap()
                    selectedTab = 2 // Events tab
                },
                onEventTap: { event in
                    HapticManager.tap()
                    selectedEvent = event
                }
            )

        case .booking:
            BookingSection {
                HapticManager.tap()
                showCalendly = true
            }

        case .mostViewed:
            if !viewModel.mostViewedFormations.isEmpty {
                TopRatedSection(
                    formations: viewModel.mostViewedFormations,
                    onViewAllTap: {
                        HapticManager.tap()
                        selectedTab = 1 // Formations tab
                    },
                    onFormationTap: { formation in
                        HapticManager.tap()
                        selectedFormation = formation
                    }
                )
            }
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
