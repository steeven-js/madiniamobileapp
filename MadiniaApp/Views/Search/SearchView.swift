//
//  SearchView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Navigation destination for all formations list
struct AllFormationsDestination: Hashable {
    let formations: [Formation]
}

/// Main search screen centralizing services, formations, and categories.
/// Replaces the old Formations tab with a unified search experience.
/// Based on Figma mockup "16 Search".
struct SearchView: View {
    /// ViewModel managing data and search state
    @Bindable private var viewModel = SearchViewModel()

    /// Navigation path for programmatic navigation
    @State private var navigationPath = NavigationPath()

    /// Controls sheet presentation for service detail
    @State private var selectedService: Service?

    /// Controls navigation to all formations
    @State private var showAllFormations = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .navigationTitle("Recherche")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: Formation.self) { formation in
                    FormationDetailView(formation: formation)
                }
                .navigationDestination(for: FormationCategory.self) { category in
                    CategoryListView(category: category, formations: viewModel.formations)
                }
                .navigationDestination(isPresented: $showAllFormations) {
                    AllFormationsListView(formations: viewModel.formations)
                }
        }
        .task {
            await viewModel.loadData()
        }
        .sheet(item: $selectedService) { service in
            ServiceDetailView(service: service)
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingView(message: "Chargement...")

        case .loaded(_):
            mainContent

        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.loadData() }
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                // Search bar
                SearchBar(text: $viewModel.searchQuery)
                    .padding(.horizontal, MadiniaSpacing.md)

                if viewModel.isSearching {
                    // Search results
                    searchResultsContent
                } else {
                    // Default sections
                    defaultSectionsContent
                }
            }
            .padding(.vertical, MadiniaSpacing.md)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Default Sections (No Search)

    private var defaultSectionsContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.xl) {
            // Categories section
            categoriesSection

            // Services section ("Nos Services")
            servicesSection

            // Formations section ("Nos Formations")
            formationsSection
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            SectionHeader(title: "Catégories") {
                // Navigate to categories grid (optional future feature)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.categories) { category in
                        CategoryCard(category: category) {
                            navigationPath.append(category)
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    // MARK: - Services Section

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            SectionHeader(title: "Nos Services") {
                // "Voir tout" for services - could show all services list
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.services) { service in
                        ServiceCard(service: service) {
                            selectedService = service
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    // MARK: - Formations Section

    private var formationsSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            SectionHeader(title: "Nos Formations") {
                // Navigate to all formations list
                showAllFormations = true
            }

            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(viewModel.formations.prefix(5)) { formation in
                    FormationRowCard(formation: formation) {
                        navigationPath.append(formation)
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }

    // MARK: - Search Results

    private var searchResultsContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
            if !viewModel.hasSearchResults {
                // No results
                noResultsView
            } else {
                // Categories results
                if !viewModel.filteredCategories.isEmpty {
                    searchCategoriesSection
                }

                // Services results
                if !viewModel.filteredServices.isEmpty {
                    searchServicesSection
                }

                // Formations results
                if !viewModel.filteredFormations.isEmpty {
                    searchFormationsSection
                }
            }
        }
    }

    private var noResultsView: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Aucun résultat pour \"\(viewModel.searchQuery)\"")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
    }

    private var searchCategoriesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Catégories")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.filteredCategories) { category in
                        CategoryCard(category: category) {
                            navigationPath.append(category)
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    private var searchServicesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Services")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.filteredServices) { service in
                        ServiceCard(service: service) {
                            selectedService = service
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    private var searchFormationsSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Formations")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.md)

            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(viewModel.filteredFormations) { formation in
                    FormationRowCard(formation: formation) {
                        navigationPath.append(formation)
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }
}

// MARK: - Previews

#Preview {
    SearchView()
}
