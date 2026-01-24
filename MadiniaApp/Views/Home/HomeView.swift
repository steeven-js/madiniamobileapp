//
//  HomeView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Home screen view displaying welcome section, highlighted formations, and quick access.
/// Handles loading, error, and loaded states for formation data.
struct HomeView: View {
    /// ViewModel managing home screen state and data
    @State private var viewModel = HomeViewModel()

    /// Selected tab binding for navigation from quick access
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                // Welcome section with Madinia branding
                WelcomeSection()

                // Progress path - always visible (static content)
                ProgressPath { step in
                    // Navigate to formations tab
                    // Later Story 2.6 will add navigation to specific formation
                    selectedTab = 1
                }

                // Content based on loading state
                switch viewModel.loadingState {
                case .idle, .loading:
                    LoadingView(message: "Chargement des formations...")

                case .loaded:
                    // Highlighted formations section
                    highlightsSection

                    // Quick access buttons
                    QuickAccessSection(
                        onFormationsTap: { selectedTab = 1 },
                        onBlogTap: { selectedTab = 2 },
                        onContactTap: { selectedTab = 3 }
                    )

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.retry() }
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
            .padding(.bottom, MadiniaSpacing.lg)
        }
        .navigationTitle("Accueil")
        .task {
            await viewModel.loadFormations()
        }
    }

    // MARK: - Subviews

    /// Horizontal scrolling section showing highlighted formations
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Formations à la une")
                .font(MadiniaTypography.title2)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.md) {
                    ForEach(viewModel.highlightedFormations) { formation in
                        HighlightCard(formation: formation) {
                            // Navigate to formations tab
                            selectedTab = 1
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.xs) // Prevent shadow clipping
            }
            .padding(.horizontal, -MadiniaSpacing.xs) // Compensate for inner padding
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
                    ProgressPath()
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
                    ProgressPath()
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
