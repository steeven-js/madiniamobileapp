//
//  FormationsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Main view for the Formations tab displaying a list of all available formations.
/// Supports pull-to-refresh, loading/error states, and navigation to detail.
struct FormationsView: View {
    /// ViewModel managing formations data and loading state
    @State private var viewModel = FormationsViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Formations")
                .navigationDestination(for: Formation.self) { formation in
                    FormationDetailView(formation: formation)
                }
        }
        .task {
            await viewModel.loadFormations()
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingView(message: "Chargement des formations...")

        case .loaded:
            formationsList

        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.loadFormations() }
            }
        }
    }

    // MARK: - Formations List

    /// Grid columns for 2-column layout (Nuton-style)
    private let gridColumns = [
        GridItem(.flexible(), spacing: MadiniaSpacing.md),
        GridItem(.flexible(), spacing: MadiniaSpacing.md)
    ]

    private var formationsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                // Category filter chips
                categoryFilterSection

                // Section header
                Text(sectionTitle)
                    .font(MadiniaTypography.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, MadiniaSpacing.md)
                    .accessibilityAddTraits(.isHeader)

                // Formation cards grid or empty state
                if viewModel.filteredFormations.isEmpty {
                    emptyFilterState
                } else {
                    LazyVGrid(columns: gridColumns, spacing: MadiniaSpacing.md) {
                        ForEach(viewModel.filteredFormations) { formation in
                            NavigationLink(value: formation) {
                                FormationCard(formation: formation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, MadiniaSpacing.md)
                }
            }
            .padding(.vertical, MadiniaSpacing.md)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Category Filter Section

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MadiniaSpacing.xs) {
                // "All" chip
                CategoryChip(
                    name: "Toutes",
                    color: nil,
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectCategory(nil)
                }

                // Category chips
                ForEach(viewModel.categories, id: \.id) { category in
                    CategoryChip(
                        name: category.name,
                        color: category.color.flatMap { Color(hex: $0) },
                        isSelected: viewModel.selectedCategory?.id == category.id
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
        .padding(.vertical, MadiniaSpacing.xs)
    }

    // MARK: - Computed Properties

    private var sectionTitle: String {
        if let category = viewModel.selectedCategory {
            return category.name
        }
        return "Toutes les formations"
    }

    // MARK: - Empty State

    private var emptyFilterState: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Aucune formation dans cette catégorie")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

#Preview {
    FormationsView()
}

#Preview("Loading State") {
    NavigationStack {
        LoadingView(message: "Chargement des formations...")
            .navigationTitle("Formations")
    }
}

#Preview("Error State") {
    NavigationStack {
        ErrorView(message: "Erreur de connexion. Vérifiez votre connexion internet.") {
            print("Retry")
        }
        .navigationTitle("Formations")
    }
}
